-- aln_hostilezones/client/boss.lua
Boss = {}
Boss.active = {} -- [zoneId] = { ped=, blip=, factionId=, tier=, spawnedAt=, lastBackup=, veh=, plate=, vehNetId= }

local function addBossBlip(ped)
    local b = AddBlipForEntity(ped)
    SetBlipSprite(b, Config.Bosses.blip.sprite)
    SetBlipColour(b, Config.Bosses.blip.color)
    SetBlipScale(b, Config.Bosses.blip.scale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Bosses.blip.label)
    EndTextCommandSetBlipName(b)
    return b
end

local function pickVehicleModel(factionId)
    local list = (Config.Bosses.vehicle.modelsByFaction and Config.Bosses.vehicle.modelsByFaction[factionId]) or nil
    if not list or #list == 0 then return nil end
    return list[math.random(1, #list)]
end

local function requestModel(model)
    local hash = GetHashKey(model)
    if not IsModelInCdimage(hash) then return nil end
    RequestModel(hash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do Wait(0) end
    if not HasModelLoaded(hash) then return nil end
    return hash
end

local function spawnVehicleNear(pos, modelName)
    local hash = requestModel(modelName)
    if not hash then return nil end
    local v = CreateVehicle(hash, pos.x, pos.y, pos.z, math.random() * 360.0, true, true)
    SetModelAsNoLongerNeeded(hash)
    if DoesEntityExist(v) then
        SetEntityAsMissionEntity(v, true, true)
        SetVehicleOnGroundProperly(v)
        SetVehicleDoorsLocked(v, 2) -- locked until key/kill
        SetVehicleEngineOn(v, true, true, false)
        return v
    end
    return nil
end

local function boostBoss(ped, faction, tier)
    SetPedMaxHealth(ped, 400)
    SetEntityHealth(ped, 400)

    local armorBase = (faction.armorByTier and faction.armorByTier[tier]) or 100
    SetPedArmour(ped, math.floor(armorBase * (Config.Bosses.armorMultiplier or 1.75)))

    local acc = math.floor(((faction.behavior and faction.behavior.accuracy) or 0.65) * 100 * (Config.Bosses.accuracyBonus or 1.1))
    SetPedAccuracy(ped, math.max(20, math.min(95, acc)))

    SetPedCombatAttributes(ped, 46, true)
    SetPedCombatAttributes(ped, 5, true)
    SetPedCombatAttributes(ped, 0, true)
    SetPedCombatAbility(ped, 2)
    SetPedCombatRange(ped, 2)

    -- Force "best" weapon for tier (last in tier list)
    if faction.weaponTiers and faction.weaponTiers[tier] and #faction.weaponTiers[tier] > 0 then
        local w = faction.weaponTiers[tier][#faction.weaponTiers[tier]]
        GiveWeaponToPed(ped, GetHashKey(w), 600, false, true)
    end
end

function Boss.Spawn(zoneId, ped, factionId, tier, spawnPos)
    local faction = Config.Factions[factionId]
    if not faction then return end

    boostBoss(ped, faction, tier)

    local blip = addBossBlip(ped)

    local veh, plate, vehNetId = nil, "", 0
    if Config.Bosses.vehicle.enabled and (math.random() < (Config.Bosses.vehicle.chance or 0.0)) then
        local model = pickVehicleModel(factionId)
        if model then
            local base = spawnPos or GetEntityCoords(ped)
            local vpos = Util.GroundZ(Util.RandomPointInRing(base, 3.0, Config.Bosses.vehicle.spawnRadius or 10.0))
            veh = spawnVehicleNear(vpos, model)
            if veh then
                plate = GetVehicleNumberPlateText(veh) or ""
                vehNetId = NetworkGetNetworkIdFromEntity(veh)
                SetNetworkIdCanMigrate(vehNetId, true)

                if Config.Bosses.vehicle.useAsCover then
                    TaskWarpPedIntoVehicle(ped, veh, -1)
                end
            end
        end
    end

    Boss.active[zoneId] = {
        ped = ped,
        blip = blip,
        factionId = factionId,
        tier = tier,
        spawnedAt = GetGameTimer(),
        lastBackup = 0,
        veh = veh,
        plate = plate,
        vehNetId = vehNetId,
    }

    TriggerEvent(Constants.Events.BossSpawned, zoneId, ped, factionId, tier, vehNetId, plate)

    -- backup call loop
    CreateThread(function()
        while DoesEntityExist(ped) and not IsEntityDead(ped) do
            Wait(1000)
            local data = Boss.active[zoneId]
            if not data then return end

            local aliveFor = (GetGameTimer() - data.spawnedAt) / 1000
            if aliveFor >= (Config.Bosses.callBackupAfterSeconds or 30) then
                local now = GetGameTimer()
                if now - data.lastBackup >= ((Config.Bosses.backupCooldownSeconds or 90) * 1000) then
                    data.lastBackup = now
                    TriggerEvent(Constants.Events.BossCalledBackup, zoneId, factionId, tier)
                end
            end
        end
    end)
end

-- death watcher
CreateThread(function()
    while true do
        Wait(1000)
        for zoneId, data in pairs(Boss.active) do
            if DoesEntityExist(data.ped) and IsEntityDead(data.ped) then
                if data.blip then RemoveBlip(data.blip) end

                -- unlock vehicle and "grant key" advisory (authorization in this resource)
                if data.veh and DoesEntityExist(data.veh) then
                    SetVehicleDoorsLocked(data.veh, 1) -- unlock
                end

                TriggerEvent(Constants.Events.BossKilled, zoneId, data.factionId, data.tier)
                TriggerEvent(Constants.Events.BossVehicleKey, zoneId, data.factionId, data.plate)

                Boss.active[zoneId] = nil
            end
        end
    end
end)
