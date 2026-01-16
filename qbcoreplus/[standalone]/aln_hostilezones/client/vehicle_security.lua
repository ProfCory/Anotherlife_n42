-- aln_hostilezones/client/vehicle_security.lua
VehicleSec = {}
VehicleSec.authorizedPlates = {}  -- [plate]=true
VehicleSec.armedVehicles = {}     -- [plate]={ factionId=..., rigged=true, armedAt=..., detonateAt=... }

local function plateOf(veh)
    local p = GetVehicleNumberPlateText(veh)
    if not p then return "" end
    return (p:gsub("^%s*(.-)%s*$", "%1"))
end

local function notifyBeep(veh)
    if not Config.VehicleRigging.warningBeep then return end
    for i=1,3 do
        StartVehicleHorn(veh, 100, GetHashKey("HELDDOWN"), false)
        Wait(220)
    end
end

function VehicleSec.AuthorizePlate(plate)
    if plate and plate ~= "" then
        VehicleSec.authorizedPlates[plate] = true
        TriggerEvent(Constants.Events.VehicleAuthorized, plate)
    end
end

-- mark a vehicle as potentially rigged
function VehicleSec.ArmVehicle(veh, factionId, rigged)
    if not DoesEntityExist(veh) then return end
    local plate = plateOf(veh)
    if plate == "" then return end
    VehicleSec.armedVehicles[plate] = { factionId = factionId, rigged = rigged }
    TriggerEvent(Constants.Events.VehicleArmed, plate, factionId, rigged)
end

local function shouldRig(factionId)
    local base = Config.VehicleRigging.baseRigChance or 0.0
    local bonus = (Config.VehicleRigging.factionRigChanceBonus and Config.VehicleRigging.factionRigChanceBonus[factionId]) or 0.0
    local chance = math.max(0.0, math.min(1.0, base + bonus))
    return math.random() < chance
end

-- Called when boss vehicle is created (or later for faction vehicles)
RegisterNetEvent(Constants.Events.BossSpawned, function(zoneId, ped, factionId, tier, vehNetId, plate)
    -- optional: if we got a vehicle net id, arm it
    if vehNetId and vehNetId ~= 0 then
        local veh = NetToVeh(vehNetId)
        if DoesEntityExist(veh) then
            local rigged = Config.VehicleRigging.enabled and shouldRig(factionId)
            VehicleSec.ArmVehicle(veh, factionId, rigged)
        end
    end
end)

-- When boss dies, authorize the boss vehicle plate (if provided via BossVehicleKey)
AddEventHandler(Constants.Events.BossVehicleKey, function(zoneId, factionId, plate)
    if plate and plate ~= "" then
        VehicleSec.AuthorizePlate(plate)
    end
end)

-- Runtime: if player enters a rigged vehicle without authorization -> explode
CreateThread(function()
    while true do
        Wait(250)
        if not Config.VehicleRigging.enabled then goto continue end

        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            if GetPedInVehicleSeat(veh, -1) == ped then
                local plate = plateOf(veh)
                local meta = VehicleSec.armedVehicles[plate]
                if meta and meta.rigged and not VehicleSec.authorizedPlates[plate] then
                    -- arm/detonate schedule per entry
                    if not meta.armedAt then
                        meta.armedAt = GetGameTimer()
                        meta.detonateAt = meta.armedAt + math.floor((Config.VehicleRigging.armDelaySeconds + Config.VehicleRigging.detonateAfterSeconds) * 1000)
                        notifyBeep(veh)
                    else
                        if GetGameTimer() >= meta.detonateAt then
                            local vpos = GetEntityCoords(veh)
                            AddExplosion(vpos.x, vpos.y, vpos.z, 2, 1.0, true, false, 1.0)
                            -- prevent repeated explosions
                            meta.rigged = false
                        end
                    end
                end
            end
        end

        ::continue::
    end
end)
