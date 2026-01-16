local QBCore = exports['qb-core']:GetCoreObject()

local function has(item)
    return QBCore.Functions.HasItem(item)
end

local function notify(msg, t)
    TriggerEvent('QBCore:Notify', msg, t or 'primary')
end

-- =====================================================
-- SMOKING
-- =====================================================

RegisterNetEvent('aln_consumables:client:Smoke', function(data)
    if not has('lighter') then
        notify('You need a lighter.', 'error')
        return
    end

    TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_SMOKING', 0, true)
    Wait(8000)
    ClearPedTasks(PlayerPedId())

    if data.type == 'joint' then
        TriggerEvent('aln_status:client:Add', 'stoned', 25)
        TriggerServerEvent('hud:server:RelieveStress', 10)
    elseif data.type == 'blunt' then
        TriggerEvent('aln_status:client:Add', 'stoned', 40)
        TriggerServerEvent('hud:server:RelieveStress', 15)
    end
end)

-- =====================================================
-- GENERIC CONSUME
-- =====================================================

RegisterNetEvent('aln_consumables:client:Consume', function(e)
    if e.thirst then
        TriggerServerEvent('hud:server:RelieveThirst', math.abs(e.thirst))
    end
    if e.hunger then
        TriggerServerEvent('hud:server:RelieveHunger', math.abs(e.hunger))
    end
    if e.stress then
        TriggerServerEvent('hud:server:RelieveStress', e.stress)
    end

    if e.fatigue then
        TriggerEvent('aln_status:client:Add', 'fatigue', e.fatigue)
    end
    if e.drunk then
        TriggerEvent('aln_status:client:Add', 'drunk', e.drunk)
    end
    if e.stoned then
        TriggerEvent('aln_status:client:Add', 'stoned', e.stoned)
    end
    if e.tripping then
        TriggerEvent('aln_status:client:Add', 'tripping', e.tripping)
    end
    if e.drugged then
        TriggerEvent('aln_status:client:Add', 'drugged', e.drugged)
    end
end)
