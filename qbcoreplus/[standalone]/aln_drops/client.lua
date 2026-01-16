local QBCore = exports['qb-core']:GetCoreObject()

local AUTO_PICKUP_RADIUS = 2.5
local ITEM_LIFETIME_MS = 5 * 60 * 1000 -- 5 minutes

local spawnedLoot = {}

-- =====================================================
-- UTILS
-- =====================================================

local function distance(a, b)
    return #(a - b)
end

local function isAmmoItem(name)
    return name:find('_ammo') ~= nil
end

local function isWeaponItem(name)
    return name:find('weapon_') ~= nil
end

local function shakeEntity(ent)
    if not DoesEntityExist(ent) then return end
    local coords = GetEntityCoords(ent)
    SetEntityCoords(ent, coords.x + 0.05, coords.y, coords.z, false, false, false, false)
    Wait(80)
    SetEntityCoords(ent, coords.x - 0.05, coords.y, coords.z, false, false, false, false)
end

-- =====================================================
-- AUTO PICKUP CHECK
-- =====================================================

local function tryAutoPickup(loot)
    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)

    if distance(pcoords, loot.coords) > AUTO_PICKUP_RADIUS then
        return false
    end

    -- Cash always auto
    if loot.cash and loot.cash > 0 then
        TriggerServerEvent('aln_drops:server:LootBagTakeAll', loot.id)
        return true
    end

    local itemCount = 0
    local hasWeapon = false
    local hasAmmoOnly = true

    for _, item in pairs(loot.items or {}) do
        itemCount = itemCount + 1
        if isWeaponItem(item.name) then
            hasWeapon = true
        end
        if not isAmmoItem(item.name) then
            hasAmmoOnly = false
        end
    end

    -- Ammo-only drops
    if itemCount > 0 and hasAmmoOnly then
        TriggerServerEvent('aln_drops:server:LootBagTakeAll', loot.id)
        return true
    end

    -- Single non-weapon item: try pickup
    if itemCount == 1 and not hasWeapon then
        TriggerServerEvent('aln_drops:server:LootBagTakeAll', loot.id)
        return true
    end

    return false
end

-- =====================================================
-- LOOT SPAWN
-- =====================================================

RegisterNetEvent('aln_drops:client:CreateLootBag', function(loot)
    if not loot or not loot.id or spawnedLoot[loot.id] then return end

    -- Try auto pickup first
    if tryAutoPickup(loot) then return end

    -- Spawn physical loot object
    local model = `prop_ld_flow_bottle`
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local obj = CreateObject(model, loot.coords.x, loot.coords.y, loot.coords.z - 0.95, false, false, false)
    FreezeEntityPosition(obj, true)
    PlaceObjectOnGroundProperly(obj)

    spawnedLoot[loot.id] = {
        object = obj,
        created = GetGameTimer(),
        loot = loot
    }

    -- Despawn after lifetime
    CreateThread(function()
        Wait(ITEM_LIFETIME_MS)
        if spawnedLoot[loot.id] then
            DeleteEntity(obj)
            spawnedLoot[loot.id] = nil
            TriggerServerEvent('aln_drops:server:CleanupCorpse', loot.id)
        end
    end)
end)

-- =====================================================
-- INTERACTION LOOP
-- =====================================================

CreateThread(function()
    while true do
        Wait(250)
        local ped = PlayerPedId()
        local pcoords = GetEntityCoords(ped)

        for id, data in pairs(spawnedLoot) do
            local obj = data.object
            if not DoesEntityExist(obj) then
                spawnedLoot[id] = nil
            else
                local ocoords = GetEntityCoords(obj)
                if distance(pcoords, ocoords) < AUTO_PICKUP_RADIUS then
                    -- Try again in case inventory space changed
                    if tryAutoPickup(data.loot) then
                        DeleteEntity(obj)
                        spawnedLoot[id] = nil
                    end
                end
            end
        end
    end
end)

-- =====================================================
-- INVENTORY FULL FEEDBACK
-- =====================================================

RegisterNetEvent('aln_drops:client:PickupFailed', function(lootId)
    local data = spawnedLoot[lootId]
    if data and DoesEntityExist(data.object) then
        shakeEntity(data.object)
        QBCore.Functions.Notify('Inventory full', 'error')
    end
end)
