Selector = {}

local Config = Config

function Selector.PickFaction(zoneId)
    local zone = Config.Zones[zoneId]
    if not zone then return nil end

    local total = 0
    for _, f in ipairs(zone.factionsWeighted or {}) do
        total += f.weight
    end

    local roll = math.random() * total
    local acc = 0

    for _, f in ipairs(zone.factionsWeighted) do
        acc += f.weight
        if roll <= acc then
            return f.id
        end
    end

    return zone.factionsWeighted[1]?.id
end

function Selector.AreRivals(a, b)
    for _, pair in ipairs(Config.Rivalries or {}) do
        if (pair[1] == a and pair[2] == b) or (pair[1] == b and pair[2] == a) then
            return true
        end
    end
    return false
end
