-- aln_hostilezones/client/ai.lua
AI = {}
AI.RelGroups = {}

local function ensureRelGroup(name)
    if AI.RelGroups[name] then return AI.RelGroups[name] end
    local groupHash = AddRelationshipGroup(name)
    AI.RelGroups[name] = groupHash
    return groupHash
end

function AI.InitRelationships()
    -- Create groups
    for id, f in pairs(Config.Factions) do
        ensureRelGroup(f.relationshipGroup or ("ALN_" .. id))
    end

    -- Default: factions neutral to each other, hate player when engaged
    for idA, fA in pairs(Config.Factions) do
        local gA = ensureRelGroup(fA.relationshipGroup or ("ALN_" .. idA))
        SetRelationshipBetweenGroups(3, gA, GetHashKey("PLAYER")) -- hate player (activated by tasks)
        SetRelationshipBetweenGroups(3, GetHashKey("PLAYER"), gA)

        for idB, fB in pairs(Config.Factions) do
            local gB = ensureRelGroup(fB.relationshipGroup or ("ALN_" .. idB))
            if idA ~= idB then
                SetRelationshipBetweenGroups(2, gA, gB) -- neutral
            end
        end
    end

    -- Rivalries: hate
    for _, pair in ipairs(Config.Rivalries or {}) do
        local a = Config.Factions[pair[1]]
        local b = Config.Factions[pair[2]]
        if a and b then
            local gA = ensureRelGroup(a.relationshipGroup)
            local gB = ensureRelGroup(b.relationshipGroup)
            SetRelationshipBetweenGroups(5, gA, gB) -- hate
            SetRelationshipBetweenGroups(5, gB, gA)
        end
    end
end

local function giveWeapon(ped, weapon)
    GiveWeaponToPed(ped, GetHashKey(weapon), 250, false, true)
end

function AI.PickWeapon(faction, tier)
    local tbl = faction.weaponTiers and faction.weaponTiers[tier]
    if not tbl or #tbl == 0 then return "WEAPON_PISTOL" end
    return tbl[math.random(1, #tbl)]
end

function AI.MaybeGiveThrowable(ped, faction, tier)
    local t = faction.throwablesByTier and faction.throwablesByTier[tier]
    if not t or #t == 0 then return end
    if math.random() < 0.25 then
        giveWeapon(ped, t[math.random(1, #t)])
    end
end

function AI.SetupPed(ped, faction, tier)
    local relName = faction.relationshipGroup
    local relHash = AI.RelGroups[relName] or AddRelationshipGroup(relName)
    SetPedRelationshipGroupHash(ped, relHash)

    SetPedCombatAttributes(ped, 46, true)   -- BF_CanFightArmedPedsWhenNotArmed
    SetPedCombatAttributes(ped, 5, true)    -- BF_AlwaysFight
    SetPedCombatAttributes(ped, 0, true)    -- BF_CanUseCover
    SetPedCombatAbility(ped, 2)
    SetPedCombatRange(ped, 2)
    SetPedFleeAttributes(ped, 0, false)

    local acc = math.floor((faction.behavior.accuracy or 0.60) * 100)
    SetPedAccuracy(ped, math.max(10, math.min(95, acc)))

    local armor = faction.armorByTier and faction.armorByTier[tier] or 0
    SetPedArmour(ped, armor)

    local weapon = AI.PickWeapon(faction, tier)
    giveWeapon(ped, weapon)
    AI.MaybeGiveThrowable(ped, faction, tier)
end

function AI.TaskEngage(ped, targetPed)
    if not DoesEntityExist(ped) or IsEntityDead(ped) then return end
    TaskCombatPed(ped, targetPed, 0, 16)
end
