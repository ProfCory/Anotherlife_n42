-- aln_hostilezones/client/interiors.lua
-- Standalone shell generator + interior combat spawns.
-- Triggered by Director door markers (InteriorEntered).
-- No inventory. Emits LootHint + InteriorCleared.

Interiors = {}
Interiors.active = nil

local function requestModel(model)
    local hash = GetHashKey(model)
    if not IsModelInCdimage(hash) then return nil end
    RequestModel(hash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do Wait(0) end
    if not HasModelLoaded(hash) then return nil end
    return hash
end

local function spawnShellObject(model, pos, heading)
    local hash = requestModel(model)
    if not hash then return nil end
    local obj = CreateObject(hash, pos.x, pos.y, pos.z, false, false, false)
    SetModelAsNoLongerNeeded(hash)
    if DoesEntityExist(obj) then
        SetEntityHeading(obj, heading or 0.0)
        FreezeEntityPosition(obj, true)
        return obj
    end
    return nil
end

local function randomInstanceCoords()
    -- spread instances so you can chain-run without overlap
    local x = 1000.0 + math.random() * 1200.0
    local y = 1000.0 + math.random() * 1200.0
    local z = Config.InteriorGameplay.instanceZ or 950.0
    return vec3(x, y, z)
end

local function spawnInteriorEnemies(zoneId, factionId, tier, basePos)
    if not Config.InteriorGameplay.spawnEnemies then return {} end
    local faction = Config.Factions[factionId]
    if not faction then return {} end

    local band = Config.InteriorGameplay.enemyCountByTier[tier] or { min=2, max=4 }
    local count = math.random(band.min, band.max)

    local peds = {}
    for i=1,count do
        local model = faction.pedModels[math.random(1, #faction.pedModels)]
        local hash = requestModel(model)
        if hash then
            local p = Util.GroundZ(Util.RandomPointInRing(basePos, 3.0, 10.0))
            local ped = CreatePed(26, hash, p.x, p.y, p.z, math.random() * 360.0, true, true)
            SetModelAsNoLongerNeeded(hash)
            if DoesEntityExist(ped) then
                SetEntityAsMissionEntity(ped, true, true)
                AI.SetupPed(ped, faction, tier)
                AI.TaskEngage(ped, PlayerPedId())
                peds[#peds+1] = ped
            end
        end
    end

    -- Optional interior boss
    local chance = (Config.InteriorGameplay.bossChanceAtTier and Config.InteriorGameplay.bossChanceAtTier[tier]) or 0.0
    if math.random() < chance then
        local model = faction.pedModels[math.random(1, #faction.pedModels)]
        local hash = requestModel(model)
        if hash then
            local p = Util.GroundZ(Util.RandomPointInRing(basePos, 2.0, 6.0))
            local bped = CreatePed(26, hash, p.x, p.y, p.z, math.random() * 360.0, true, true)
            SetModelAsNoLongerNeeded(hash)
            if DoesEntityExist(bped) then
                SetEntityAsMissionEntity(bped, true, true)
                AI.SetupPed(bped, faction, tier)
                -- use Boss system without vehicle for interior (spawnPos provided)
                Boss.Spawn(("interior:"..zoneId), bped, factionId, tier, basePos)
                peds[#peds+1] = bped
            end
        end
    end

    return peds
end

local function cleanupPeds(peds)
    for _, ped in ipairs(peds or {}) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
end

local function isAllDead(peds)
    for _, ped in ipairs(peds or {}) do
        if DoesEntityExist(ped) and not IsEntityDead(ped) then return false end
    end
    return true
end

local function teleportPlayer(pos, heading)
    local ped = PlayerPedId()
    DoScreenFadeOut(250)
    while not IsScreenFadedOut() do Wait(0) end
    SetEntityCoords(ped, pos.x, pos.y, pos.z, false, false, false, true)
    if heading then SetEntityHeading(ped, heading) end
    Wait(150)
    DoScreenFadeIn(250)
end

AddEventHandler(Constants.Events.InteriorEntered, function(zoneId, shellId)
    if not Config.InteriorGameplay.enabled then return end
    if Interiors.active then return end

    local shellDef = Config.Interiors.shells[shellId]
    if not shellDef then return end

    local rt = Director and Director.zoneRuntime and Director.zoneRuntime[zoneId] or nil
    local factionId = (rt and rt.factionId) or "locals"
    local tier = (rt and rt.tier) or 2

    -- remember where we came from
    local ped = PlayerPedId()
    local returnPos = GetEntityCoords(ped)
    local returnHeading = GetEntityHeading(ped)

    -- spawn shell in an isolated spot
    local base = randomInstanceCoords()
    local shellObj = spawnShellObject(shellDef.model, base, 0.0)
    if not shellObj then return end

    -- entry point is just near base; you can tune offsets per shell later
    local entry = base + vec3(0.0, 0.0, 1.0)
    teleportPlayer(entry, 0.0)

    -- spawn interior enemies
    local enemyPeds = spawnInteriorEnemies(zoneId, factionId, tier, base)

    -- emit loot hint for adapters (drops/tools/safes)
    if Config.InteriorGameplay.emitLootHint then
        TriggerEvent(Constants.Events.LootHint, zoneId, shellId, tier, base)
    end

    Interiors.active = {
        zoneId = zoneId,
        shellId = shellId,
        shellObj = shellObj,
        base = base,
        returnPos = returnPos,
        returnHeading = returnHeading,
        enemies = enemyPeds,
        enteredAt = GetGameTimer(),
    }

    -- main interior loop: exit + clear detection
    CreateThread(function()
        while Interiors.active do
            Wait(0)

            local ap = Interiors.active
            if not ap then return end

            -- exit prompt marker
            local ppos = GetEntityCoords(PlayerPedId())
            if Util.Distance(ppos, ap.base) < 25.0 then
                Util.DrawSmallMarker(ap.base + vec3(1.2, 0.0, 1.0), 255, 255, 0)
            end

            -- exit key
            if IsControlJustPressed(0, Config.InteriorGameplay.exitKey) then
                -- do not require clear to exit; if you want “locked until clear”, change here.
                cleanupPeds(ap.enemies)
                if DoesEntityExist(ap.shellObj) then DeleteEntity(ap.shellObj) end
                teleportPlayer(ap.returnPos, ap.returnHeading)
                TriggerEvent(Constants.Events.InteriorCleared, ap.zoneId, ap.shellId)
                Interiors.active = nil
                return
            end

            -- auto-clear signal when enemies dead (for loot scripts)
            if ap.enemies and #ap.enemies > 0 and isAllDead(ap.enemies) then
                -- emit once then remove list
                TriggerEvent(Constants.Events.InteriorCleared, ap.zoneId, ap.shellId)
                ap.enemies = {}
            end
        end
    end)
end)
