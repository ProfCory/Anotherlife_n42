-- aln_hostilezones/client/director.lua
-- Master director for hostile zones:
-- waves, bosses, AI-vs-AI skirmishes, clears, interiors
-- Standalone, PVE-first, event-driven

Director = {}
Director.zoneRuntime = {}
Director.playerZone = nil
Director.doors = {}          -- [zoneId] = { {pos, shellId, expiresAt} }
Director.lastSkirmishRollAt = 0

Boss = Boss or {}            -- boss.lua populates this

---------------------------------------------------------
-- Time helpers
---------------------------------------------------------
local function worldHour()
    if GetClockHours then return GetClockHours() end
    return os.date("*t").hour
end

local function isNight()
    local h = worldHour()
    return (h >= Config.Time.NightStartHour or h <= Config.Time.NightEndHour)
end

local function timeMult()
    return isNight() and Config.Time.Night or Config.Time.Day
end

---------------------------------------------------------
-- Zone helpers
---------------------------------------------------------
local function getBudget(tier)
    return Config.Tiers.Budgets[tier] or Config.Tiers.Budgets[1]
end

local function pickCore(zone)
    if not zone.cores or #zone.cores == 0 then return nil end
    return zone.cores[math.random(1, #zone.cores)]
end

local function spawnPosNearCore(zone)
    local core = pickCore(zone)
    local origin = core and core.center or zone.center
    local minR = core and (core.radius * 0.6) or (zone.radius * 0.35)
    local maxR = core and (core.radius * 1.1) or (zone.radius * 0.7)
    return Util.GroundZ(Util.RandomPointInRing(origin, minR, maxR)), core
end

---------------------------------------------------------
-- Ped spawning
---------------------------------------------------------
local function requestModel(model)
    local hash = GetHashKey(model)
    if not IsModelInCdimage(hash) then return nil end
    RequestModel(hash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do Wait(0) end
    if not HasModelLoaded(hash) then return nil end
    return hash
end

local function spawnPed(pos, model)
    local hash = requestModel(model)
    if not hash then return nil end
    local ped = CreatePed(26, hash, pos.x, pos.y, pos.z, math.random() * 360.0, true, true)
    SetModelAsNoLongerNeeded(hash)
    if DoesEntityExist(ped) then
        SetEntityAsMissionEntity(ped, true, true)
        return ped
    end
    return nil
end

---------------------------------------------------------
-- Cleanup
---------------------------------------------------------
local function cleanupDead(zoneId)
    local rt = Director.zoneRuntime[zoneId]
    if not rt then return end

    local alive = {}
    for _, ped in ipairs(rt.peds) do
        if DoesEntityExist(ped) and not IsEntityDead(ped) then
            alive[#alive+1] = ped
        else
            if DoesEntityExist(ped) then DeleteEntity(ped) end
        end
    end
    rt.peds = alive
end

---------------------------------------------------------
-- Event passthrough
---------------------------------------------------------
local function emit(eventName, ...)
    TriggerEvent(eventName, ...)
end

---------------------------------------------------------
-- Tier updates from server
---------------------------------------------------------
RegisterNetEvent(Constants.Events.TierChanged, function(zoneId, tier, heat, factionId)
    Director.zoneRuntime[zoneId] = Director.zoneRuntime[zoneId] or {
        tier = tier,
        heat = heat,
        factionId = factionId,
        peds = {},
        lastWaveAt = 0,
        quietSince = nil,
        forcedWaveCount = nil,
        bossSpawned = false,
    }

    local rt = Director.zoneRuntime[zoneId]
    rt.tier = tier
    rt.heat = heat
    rt.factionId = factionId
end)

---------------------------------------------------------
-- Zone enter / exit
---------------------------------------------------------
function Director.OnEnter(zoneId)
    Director.playerZone = zoneId
    emit(Constants.Events.ZoneEntered, zoneId)

    local z = Config.Zones[zoneId]
    if z and z.cores then
        for _, c in ipairs(z.cores) do
            if c.jurisdiction then
                emit(Constants.Events.Jurisdiction, zoneId, c.jurisdiction.mode, c.jurisdiction.factor)
            end
        end
    end
end

function Director.OnExit(zoneId)
    emit(Constants.Events.ZoneLeft, zoneId)
    if Director.playerZone == zoneId then
        Director.playerZone = nil
    end
end

---------------------------------------------------------
-- Boss spawning
---------------------------------------------------------
local function trySpawnBoss(zoneId, z, rt)
    if rt.bossSpawned or Boss.active[zoneId] then return end
    if not z.cores then return end

    for _, core in ipairs(z.cores) do
        if core.bossSlots and core.bossSlots > 0 then
            local faction = Config.Factions[rt.factionId]
            if not faction then return end

            local pos = Util.GroundZ(core.center)
            local model = faction.pedModels[math.random(1, #faction.pedModels)]
            local ped = spawnPed(pos, model)
            if ped then
                AI.SetupPed(ped, faction, rt.tier)
                Boss.Spawn(zoneId, ped, rt.factionId, rt.tier)
                rt.peds[#rt.peds+1] = ped
                rt.bossSpawned = true
            end
            return
        end
    end
end

---------------------------------------------------------
-- Wave spawning (linger-based)
---------------------------------------------------------
local function tryWave(zoneId, playerPed)
    local z = Config.Zones[zoneId]
    local rt = Director.zoneRuntime[zoneId]
    if not z or not rt then return end

    cleanupDead(zoneId)

    local faction = Config.Factions[rt.factionId]
    if not faction then return end

    local tier = rt.tier or z.baseTier or 0
    if tier <= 0 then return end

    local budget = getBudget(tier)
    local tm = timeMult()
    local maxAlive = math.floor((budget.maxAlive or 0) * (tm.spawnBudgetMult or 1.0))

    if #rt.peds >= maxAlive then return end

    local now = GetGameTimer()
    local cd = (budget.waveCooldownSec or 60) * 1000
    if now - rt.lastWaveAt < cd then return end

    -- Boss first
    trySpawnBoss(zoneId, z, rt)

    local waveSize = rt.forcedWaveCount or budget.waveSize or 2
    rt.forcedWaveCount = nil
    waveSize = math.min(waveSize, maxAlive - #rt.peds)
    if waveSize <= 0 then return end

    rt.lastWaveAt = now

    for i=1, waveSize do
        local spawnPos = spawnPosNearCore(z)
        local model = faction.pedModels[math.random(1, #faction.pedModels)]
        local ped = spawnPed(spawnPos, model)
        if ped then
            AI.SetupPed(ped, faction, tier)
            AI.TaskEngage(ped, playerPed)
            rt.peds[#rt.peds+1] = ped
        end
    end

    emit(Constants.Events.WaveSpawned, zoneId, tier, waveSize, rt.factionId)
end

---------------------------------------------------------
-- Boss backup call listener
---------------------------------------------------------
AddEventHandler(Constants.Events.BossCalledBackup, function(zoneId, factionId, tier)
    local rt = Director.zoneRuntime[zoneId]
    if not rt then return end

    local budget = getBudget(tier)
    local extra = math.floor((budget.waveSize or 3) * Config.Bosses.reinforcement.waveMultiplier)

    rt.forcedWaveCount = extra
    rt.lastWaveAt = 0 -- force immediate spawn
end)

---------------------------------------------------------
-- Zone cleared detection
---------------------------------------------------------
local function checkCleared(zoneId)
    local z = Config.Zones[zoneId]
    local rt = Director.zoneRuntime[zoneId]
    if not z or not rt then return end

    cleanupDead(zoneId)

    if #rt.peds == 0 and not Boss.active[zoneId] then
        if not rt.quietSince then
            rt.quietSince = GetGameTimer()
        end

        if GetGameTimer() - rt.quietSince >= (Config.Clearing.holdSeconds * 1000) then
            TriggerServerEvent("aln_hostiles:zoneCleared", zoneId)
            emit(Constants.Events.ZoneCleared, zoneId, rt.factionId, rt.tier)

            Director.ArmInteriors(zoneId)
            rt.quietSince = nil
        end
    else
        rt.quietSince = nil
    end
end

---------------------------------------------------------
-- Interior / door arming
---------------------------------------------------------
function Director.ArmInteriors(zoneId)
    local z = Config.Zones[zoneId]
    local rt = Director.zoneRuntime[zoneId]
    if not z or not rt or not z.interiors or not Config.Interiors.enabled then return end

    for _, entry in ipairs(z.interiors) do
        if rt.tier >= (entry.tierRequired or 99) and math.random() < (entry.chance or 0) then
            local shell = Config.Interiors.shells[entry.shellId]
            if shell then
                local core = pickCore(z)
                local base = core and core.center or z.center
                local pos = Util.GroundZ(Util.RandomPointInRing(base, 6.0, 18.0))

                Director.doors[zoneId] = Director.doors[zoneId] or {}
                Director.doors[zoneId][#Director.doors[zoneId]+1] = {
                    pos = pos,
                    shellId = entry.shellId,
                    expiresAt = GetGameTimer() + (10 * 60 * 1000),
                }

                emit(Constants.Events.InteriorAvailable, zoneId, entry.shellId)
            end
        end
    end
end

---------------------------------------------------------
-- Door interaction loop (hooks only)
---------------------------------------------------------
CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        for zoneId, list in pairs(Director.doors) do
            for i = #list, 1, -1 do
                local d = list[i]
                if GetGameTimer() > d.expiresAt then
                    table.remove(list, i)
                else
                    if Util.Distance(pos, d.pos) < 25.0 then
                        Util.DrawSmallMarker(d.pos, 0, 200, 255)
                    end
                    if Util.Distance(pos, d.pos) < 1.8 and IsControlJustPressed(0, 38) then
                        emit(Constants.Events.InteriorEntered, zoneId, d.shellId)
                        table.remove(list, i)
                    end
                end
            end
        end
    end
end)

---------------------------------------------------------
-- Overlap skirmishes (AI vs AI, night-biased)
---------------------------------------------------------
local function trySkirmish(playerPos)
    if not Config.Skirmishes.enabled or not isNight() then return end
    if GetGameTimer() - Director.lastSkirmishRollAt < 60000 then return end
    Director.lastSkirmishRollAt = GetGameTimer()

    if math.random() > (Config.Skirmishes.baseChancePerMinuteNight * Config.Time.Night.skirmishChanceMult) then
        return
    end

    local nearby = {}
    for zoneId, zone in pairs(Config.Zones) do
        if Util.Distance(playerPos, zone.center) <= (zone.radius + 200.0) then
            nearby[#nearby+1] = zoneId
        end
    end

    for i=1,#nearby do
        for j=i+1,#nearby do
            local aId, bId = nearby[i], nearby[j]
            local a, b = Config.Zones[aId], Config.Zones[bId]
            if a and b and Util.ZoneOverlap(a, b) then
                local ar, br = Director.zoneRuntime[aId], Director.zoneRuntime[bId]
                if ar and br and ar.factionId ~= br.factionId then
                    if Selector.AreRivals(ar.factionId, br.factionId) then
                        Director.SpawnSkirmish(Util.OverlapPoint(a,b), ar.factionId, br.factionId, math.max(ar.tier, br.tier))
                        return
                    end
                end
            end
        end
    end
end

---------------------------------------------------------
-- Skirmish spawn
---------------------------------------------------------
function Director.SpawnSkirmish(point, factionAId, factionBId, tier)
    local fA = Config.Factions[factionAId]
    local fB = Config.Factions[factionBId]
    if not fA or not fB then return end

    local sz = math.random(Config.Skirmishes.groupSize.min, Config.Skirmishes.groupSize.max)

    local leaderA, leaderB = nil, nil

    for i=1,sz do
        local pA = Util.GroundZ(Util.RandomPointInRing(point, 18, 35))
        local pB = Util.GroundZ(Util.RandomPointInRing(point, 18, 35))

        local pedA = spawnPed(pA, fA.pedModels[math.random(#fA.pedModels)])
        local pedB = spawnPed(pB, fB.pedModels[math.random(#fB.pedModels)])

        if pedA then AI.SetupPed(pedA, fA, tier); leaderA = leaderA or pedA end
        if pedB then AI.SetupPed(pedB, fB, tier); leaderB = leaderB or pedB end
    end

    if leaderA and leaderB then
        AI.TaskEngage(leaderA, leaderB)
        AI.TaskEngage(leaderB, leaderA)
    end
end

---------------------------------------------------------
-- Main tick
---------------------------------------------------------
CreateThread(function()
    while true do
        Wait(1000)
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        if Director.playerZone then
            tryWave(Director.playerZone, ped)
            checkCleared(Director.playerZone)
        end

        trySkirmish(pos)
    end
end)
