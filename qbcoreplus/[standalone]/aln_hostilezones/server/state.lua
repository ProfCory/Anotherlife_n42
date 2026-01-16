-- aln_hostilezones/server/state.lua
ZoneState = {}

local Config = Config
local HeatCfg = Config.Heat
local TierCfg = Config.Tiers

local function now() return os.time() end

function ZoneState.Init()
    ZoneState.zones = {}

    for zoneId, zone in pairs(Config.Zones) do
        ZoneState.zones[zoneId] = {
            heat = 0,
            tier = zone.baseTier or 0,
            activeFaction = nil,
            cooldownUntil = 0,
            lastTier = -1,
        }
    end

    MySQL.query('SELECT * FROM aln_hostilezones_state', {}, function(rows)
        for _, row in ipairs(rows) do
            if ZoneState.zones[row.zone_id] then
                ZoneState.zones[row.zone_id].cooldownUntil = row.cooldown_until
                ZoneState.zones[row.zone_id].activeFaction = row.last_faction
            end
        end
        print('[aln_hostilezones] Loaded cooldown persistence')
    end)
end

function ZoneState.IsOnCooldown(zoneId)
    local z = ZoneState.zones[zoneId]
    if not z then return false end
    return z.cooldownUntil > now()
end

function ZoneState.SetCooldown(zoneId, factionId)
    local untilTs = now() + (Config.Clearing.cooldownInGameHours * 60)
    local z = ZoneState.zones[zoneId]
    if not z then return end

    z.cooldownUntil = untilTs

    MySQL.insert([[
        INSERT INTO aln_hostilezones_state (zone_id, last_cleared_at, cooldown_until, last_faction)
        VALUES (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            last_cleared_at = VALUES(last_cleared_at),
            cooldown_until = VALUES(cooldown_until),
            last_faction = VALUES(last_faction)
    ]], { zoneId, now(), untilTs, factionId or z.activeFaction })
end

function ZoneState.AddHeat(zoneId, amount)
    local z = ZoneState.zones[zoneId]
    if not z or ZoneState.IsOnCooldown(zoneId) then return end
    z.heat = math.min(HeatCfg.MaxHeat, z.heat + amount)
end

function ZoneState.DecayHeat()
    for _, z in pairs(ZoneState.zones) do
        z.heat = math.max(0, z.heat - HeatCfg.DecayPerSecond)
    end
end

local function tierFromHeat(heat)
    for _, band in ipairs(TierCfg.HeatToTierDelta) do
        if heat >= band.min and heat <= band.max then return band.add end
    end
    return 0
end

function ZoneState.RecomputeTier(zoneId, timeMod)
    local z = ZoneState.zones[zoneId]
    local zone = Config.Zones[zoneId]
    if not z or not zone then return end

    local base = zone.baseTier or 0
    local add = tierFromHeat(z.heat)
    local tier = math.min(zone.maxTier or 5, base + add + (timeMod or 0))
    z.tier = math.max(0, tier)
end
