local QBCore = exports['qb-core']:GetCoreObject()

local function usable(item, event, data)
    QBCore.Functions.CreateUseableItem(item, function(src)
        TriggerClientEvent(event, src, data)
    end)
end

local function hasAndRemove(src, req)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end

    for _, r in pairs(req) do
        local it = Player.Functions.GetItemByName(r.name)
        if not it or it.amount < r.amount then
            return false
        end
    end

    for _, r in pairs(req) do
        Player.Functions.RemoveItem(r.name, r.amount)
    end

    return true
end

local function give(src, items)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    for _, it in pairs(items) do
        Player.Functions.AddItem(it.name, it.amount)
    end
end

-- =====================================================
-- CRAFTING
-- =====================================================

RegisterNetEvent('aln_consumables:server:RollJoint', function(weed)
    local src = source
    if not hasAndRemove(src, {
        { name = weed, amount = 1 },
        { name = 'rolling_paper', amount = 1 }
    }) then
        TriggerClientEvent('QBCore:Notify', src, 'Missing weed or rolling papers.', 'error')
        return
    end

    give(src, { { name = 'joint', amount = 3 } })
    TriggerClientEvent('QBCore:Notify', src, 'You rolled 3 joints.', 'success')
end)

RegisterNetEvent('aln_consumables:server:RollBlunt', function(weed)
    local src = source
    if not hasAndRemove(src, {
        { name = weed, amount = 1 },
        { name = 'bluntwrap', amount = 1 }
    }) then
        TriggerClientEvent('QBCore:Notify', src, 'Missing weed or blunt wrap.', 'error')
        return
    end

    give(src, { { name = 'blunt', amount = 2 } })
    TriggerClientEvent('QBCore:Notify', src, 'You rolled 2 blunts.', 'success')
end)

-- =====================================================
-- USEABLE ITEMS
-- =====================================================

-- Smoking
usable('joint', 'aln_consumables:client:Smoke', { type = 'joint' })
usable('blunt', 'aln_consumables:client:Smoke', { type = 'blunt' })

-- Cannabis products
usable('shatter', 'aln_consumables:client:Consume', { stoned = 50 })
usable('keef', 'aln_consumables:client:Consume', { stoned = 30 })
usable('driedcannabis', 'aln_consumables:client:Consume', { stoned = 20 })
usable('cannabutter', 'aln_consumables:client:Consume', { stoned = 60, hunger = -20 })
usable('butter', 'aln_consumables:client:Consume', { hunger = -10 })

-- Blunt variants
usable('leanblunts', 'aln_consumables:client:Consume', { stoned = 35, drugged = 10 })
usable('dextroblunts', 'aln_consumables:client:Consume', { stoned = 25, fatigue = -15 })
usable('mdwoods', 'aln_consumables:client:Consume', { stoned = 40 })

-- Psychedelics / drugs
usable('shrooms', 'aln_consumables:client:Consume', { tripping = 60 })
usable('xtc_baggy', 'aln_consumables:client:Consume', { tripping = 40, fatigue = -20 })
usable('oxy', 'aln_consumables:client:Consume', { drugged = 35 })
usable('adderal', 'aln_consumables:client:Consume', { fatigue = -30, stress = -10 })
usable('adderalprescription', 'aln_consumables:client:Consume', { fatigue = -20 })
usable('morphine', 'aln_consumables:client:Consume', { drugged = 45 })
usable('morphineprescription', 'aln_consumables:client:Consume', { drugged = 30 })
usable('reddextro', 'aln_consumables:client:Consume', { fatigue = -25 })

-- Alcohol / drinks
usable('beer', 'aln_consumables:client:Consume', { drunk = 15, thirst = -10 })
usable('coffee', 'aln_consumables:client:Consume', { fatigue = -20, stress = 5 })
usable('cola', 'aln_consumables:client:Consume', { thirst = -15, fatigue = -5 })

-- Medical
usable('painkillers', 'aln_consumables:client:Consume', { stress = -10 })
