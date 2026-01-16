local QBCore = exports['qb-core']:GetCoreObject()

local CurrentState = nil
local Vendor = {
    veh = nil,
    driver = nil,
    targetAdded = false,
    isDriving = false,
    blip = nil,
}
local PickupCrates = {}

local function dbg(msg)
    if Config.Debug then
        print(('[aln_roaming_vendor] %s'):format(msg))
    end
end

-- ======================
-- UTILITIES
-- ======================

local function loadModel(model)
    local hash = joaat(model)
    if not IsModelInCdimage(hash) then return nil end
    RequestModel(hash)
    local timeout = GetGameTimer() + 8000
    while not HasModelLoaded(hash) do
        Wait(10)
        if GetGameTimer() > timeout then return nil end
    end
    return hash
end

local function safeDelete(ent)
    if ent and DoesEntityExist(ent) then
        SetEntityAsMissionEntity(ent, true, true)
        DeleteEntity(ent)
    end
end

local function removeBlip()
    if Vendor.blip and DoesBlipExist(Vendor.blip) then
        RemoveBlip(Vendor.blip)
    end
    Vendor.blip = nil
end

-- ======================
-- BLIP HANDLING
-- ======================

local function updateVendorBlip()
    if not Vendor.veh or not DoesEntityExist(Vendor.veh) then
        removeBlip()
        return
    end

    local playerPed = PlayerPedId()
    local pcoords = GetEntityCoords(playerPed)
    local vcoords = GetEntityCoords(Vendor.veh)
    local dist = #(pcoords - vcoords)

    if dist <= Config.VendorBlipRadius then
        if not Vendor.blip then
            Vendor.blip = AddBlipForEntity(Vendor.veh)
            SetBlipSprite(Vendor.blip, Config.VendorBlipSprite)
            SetBlipScale(Vendor.blip, Config.VendorBlipScale)
            SetBlipColour(Vendor.blip, Config.VendorBlipColor)
            SetBlipAsShortRange(Vendor.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.VendorBlipLabel)
            EndTextCommandSetBlipName(Vendor.blip)
        end
    else
        removeBlip()
    end
end

-- ======================
-- VENDOR SPAWN / DESPAWN
-- ======================

local function spawnVendorAtStop(stop)
    local vHash = loadModel(Config.VendorVehicleModel)
    local pHash = loadModel(Config.DriverPedModel)
    if not vHash or not pHash then return end

    local c = stop.coords
    local veh = CreateVehicle(vHash, c.x, c.y, c.z, c.w, false, true)
    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleOnGroundProperly(veh)
    SetVehicleDoorsLocked(veh, 2)
    SetVehicleEngineOn(veh, true, true, false)

    local ped = CreatePedInsideVehicle(veh, 4, pHash, -1, false, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdoll(ped, false)
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_CLIPBOARD', 0, true)

    Vendor.veh = veh
    Vendor.driver = ped
    Vendor.isDriving = false

    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                icon = 'fas fa-store',
                label = Config.TargetLabel,
                action = function()
                    TriggerEvent('aln_roaming_vendor:client:openMenu')
                end
            },
        },
        distance = 2.5
    })

    Vendor.targetAdded = true
end

local function despawnVendor()
    safeDelete(Vendor.driver)
    safeDelete(Vendor.veh)
    removeBlip()
    Vendor.driver = nil
    Vendor.veh = nil
    Vendor.targetAdded = false
    Vendor.isDriving = false
end

-- ======================
-- MOVEMENT
-- ======================

local function driveToStop(nextStop)
    if not Vendor.veh or not Vendor.driver or Vendor.isDriving then return end
    Vendor.isDriving = true

    ClearPedTasks(Vendor.driver)
    SetPedIntoVehicle(Vendor.driver, Vendor.veh, -1)

    TaskVehicleDriveToCoordLongrange(
        Vendor.driver,
        Vendor.veh,
        nextStop.coords.x,
        nextStop.coords.y,
        nextStop.coords.z,
        Config.DriveSpeed,
        Config.DriveStyle,
        8.0
    )
end

-- ======================
-- MAIN LOOP
-- ======================

local function ensureVendor()
    if not CurrentState then return end
    local stop = Config.Stops[CurrentState.stopIndex]
    if not stop then return end

    local playerPed = PlayerPedId()
    local pcoords = GetEntityCoords(playerPed)
    local stopCoords = vec3(stop.coords.x, stop.coords.y, stop.coords.z)
    local dist = #(pcoords - stopCoords)

    if dist > Config.StreamDistance then
        if Vendor.veh or Vendor.driver then
            despawnVendor()
        end
        return
    end

    if not Vendor.veh or not DoesEntityExist(Vendor.veh) then
        spawnVendorAtStop(stop)
    end

    if CurrentState.phase == 'moving' and CurrentState.nextStopIndex then
        local nextStop = Config.Stops[CurrentState.nextStopIndex]
        if nextStop then
            if Config.UseRealDriving then
                driveToStop(nextStop)
            else
                DoScreenFadeOut(250)
                Wait(250)
                SetEntityCoords(Vendor.veh, nextStop.coords.x, nextStop.coords.y, nextStop.coords.z, false, false, false, true)
                SetEntityHeading(Vendor.veh, nextStop.coords.w)
                SetVehicleOnGroundProperly(Vendor.veh)
                Vendor.isDriving = false
                Wait(150)
                DoScreenFadeIn(250)
            end
        end
    else
        Vendor.isDriving = false
        if Vendor.veh then
            SetEntityHeading(Vendor.veh, stop.coords.w)
        end
    end

    updateVendorBlip()
end

-- ======================
-- STATE SYNC
-- ======================

RegisterNetEvent('aln_roaming_vendor:client:setState', function(state)
    CurrentState = state
end)

CreateThread(function()
    QBCore.Functions.TriggerCallback('aln_roaming_vendor:server:getState', function(state)
        CurrentState = state
    end)

    while true do
        ensureVendor()
        Wait(1000)
    end
end)

-- ======================
-- CLEANUP
-- ======================

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    despawnVendor()
    for _, ent in pairs(PickupCrates) do
        safeDelete(ent)
    end
end)
