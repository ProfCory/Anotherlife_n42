local QBCore = exports['qb-core']:GetCoreObject()

local VendorState = {
    stopIndex = 1,
    phase = 'parked', -- parked|moving
    nextMoveAt = 0
}

local function isStopOpen(stop)
    local hour = os.date('*t').hour
    local s = stop.openHours.start
    local e = stop.openHours.stop
    if s <= e then
        return hour >= s and hour <= e
    end
    -- wraps midnight
    return hour >= s or hour <= e
end

local function pickNextOpenStop(fromIndex)
    for i = 1, #Config.Stops do
        local idx = ((fromIndex + i - 1) % #Config.Stops) + 1
        if isStopOpen(Config.Stops[idx]) then
            return idx
        end
    end
    return fromIndex
end

CreateThread(function()
    -- initialize
    VendorState.stopIndex = pickNextOpenStop(1)
    VendorState.phase = 'parked'
    VendorState.nextMoveAt = os.time() + Config.Stops[VendorState.stopIndex].dwellSeconds

    while true do
        Wait(1000)

        -- ensure we're always at an open stop (if time window changes)
        if not isStopOpen(Config.Stops[VendorState.stopIndex]) then
            VendorState.stopIndex = pickNextOpenStop(VendorState.stopIndex)
            VendorState.phase = 'parked'
            VendorState.nextMoveAt = os.time() + Config.Stops[VendorState.stopIndex].dwellSeconds
            TriggerClientEvent('aln_roaming_vendor:client:setState', -1, VendorState)
        end

        if os.time() >= VendorState.nextMoveAt then
            if VendorState.phase == 'parked' then
                -- move to next open stop
                local nextIdx = pickNextOpenStop(VendorState.stopIndex)
                if nextIdx == VendorState.stopIndex then
                    VendorState.nextMoveAt = os.time() + Config.Stops[VendorState.stopIndex].dwellSeconds
                else
                    VendorState.phase = 'moving'
                    VendorState.nextStopIndex = nextIdx
                    VendorState.nextMoveAt = os.time() + 45 -- moving time budget (clients do actual driving/teleport)
                end
            else
                -- arrive
                VendorState.stopIndex = VendorState.nextStopIndex or VendorState.stopIndex
                VendorState.nextStopIndex = nil
                VendorState.phase = 'parked'
                VendorState.nextMoveAt = os.time() + Config.Stops[VendorState.stopIndex].dwellSeconds
            end
            TriggerClientEvent('aln_roaming_vendor:client:setState', -1, VendorState)
        end
    end
end)

QBCore.Functions.CreateCallback('aln_roaming_vendor:server:getState', function(_, cb)
    cb(VendorState)
end)

-- BUY item
RegisterNetEvent('aln_roaming_vendor:server:buyItem', function(item, amount, deliveryMode, pickupNetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    amount = tonumber(amount) or 0
    if amount <= 0 then return end

    local cfg = Config.Items[item]
    if not cfg or not cfg.buy then
        TriggerClientEvent('QBCore:Notify', src, 'That item is not sold here.', 'error')
        return
    end

    if cfg.max and amount > cfg.max then
        TriggerClientEvent('QBCore:Notify', src, ('Max %d for %s.'):format(cfg.max, cfg.label or item), 'error')
        return
    end

    local price = cfg.buy * amount
    if Player.Functions.GetMoney(Config.PayAccount) < price then
        TriggerClientEvent('QBCore:Notify', src, 'Not enough money.', 'error')
        return
    end

    Player.Functions.RemoveMoney(Config.PayAccount, price, 'roaming-vendor-buy')

    deliveryMode = deliveryMode or Config.DefaultDeliveryMode
    if deliveryMode == "inventory" then
        local added = Player.Functions.AddItem(item, amount, false)
        if added then
            TriggerClientEvent('QBCore:Notify', src, ('Bought %dx %s'):format(amount, cfg.label or item), 'success')
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add', amount)
        else
            -- refund if inventory full
            Player.Functions.AddMoney(Config.PayAccount, price, 'roaming-vendor-refund')
            TriggerClientEvent('QBCore:Notify', src, 'Inventory full.', 'error')
        end
    else
        -- pickup crate mode: client spawns crate; server "binds" it to an order
        -- We store order temporarily by pickupNetId -> {citizenid,item,amount}
        if not pickupNetId then
            TriggerClientEvent('QBCore:Notify', src, 'Pickup crate missing.', 'error')
            Player.Functions.AddMoney(Config.PayAccount, price, 'roaming-vendor-refund')
            return
        end
        GlobalState['aln_vendor_orders'] = GlobalState['aln_vendor_orders'] or {}
        local orders = GlobalState['aln_vendor_orders']
        orders[tostring(pickupNetId)] = { cid = Player.PlayerData.citizenid, item = item, amount = amount }
        GlobalState['aln_vendor_orders'] = orders

        TriggerClientEvent('QBCore:Notify', src, ('Order placed. Pick it up.'):format(), 'success')
    end
end)

-- SELL item
RegisterNetEvent('aln_roaming_vendor:server:sellItem', function(item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    amount = tonumber(amount) or 0
    if amount <= 0 then return end

    local cfg = Config.Items[item]
    local sellPrice = cfg and cfg.sell or nil

    if not sellPrice then
        if not Config.AllowUnknownSell then
            TriggerClientEvent('QBCore:Notify', src, 'This vendor will not buy that.', 'error')
            return
        end
        sellPrice = Config.UnknownSellPrice
    end

    local has = Player.Functions.GetItemByName(item)
    if not has or (has.amount or 0) < amount then
        TriggerClientEvent('QBCore:Notify', src, 'You do not have that amount.', 'error')
        return
    end

    Player.Functions.RemoveItem(item, amount)
    Player.Functions.AddMoney(Config.PayAccount, sellPrice * amount, 'roaming-vendor-sell')

    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove', amount)
    TriggerClientEvent('QBCore:Notify', src, ('Sold %dx %s'):format(amount, (cfg and cfg.label) or item), 'success')
end)

-- PICKUP from crate
RegisterNetEvent('aln_roaming_vendor:server:pickupOrder', function(pickupNetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local orders = GlobalState['aln_vendor_orders'] or {}
    local key = tostring(pickupNetId)
    local ord = orders[key]
    if not ord then
        TriggerClientEvent('QBCore:Notify', src, 'Nothing in this crate.', 'error')
        return
    end

    if ord.cid ~= Player.PlayerData.citizenid then
        TriggerClientEvent('QBCore:Notify', src, 'Not your order.', 'error')
        return
    end

    local ok = Player.Functions.AddItem(ord.item, ord.amount, false)
    if not ok then
        TriggerClientEvent('QBCore:Notify', src, 'Inventory full.', 'error')
        return
    end

    orders[key] = nil
    GlobalState['aln_vendor_orders'] = orders

    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[ord.item], 'add', ord.amount)
    TriggerClientEvent('aln_roaming_vendor:client:deletePickup', -1, pickupNetId)
    TriggerClientEvent('QBCore:Notify', src, 'Picked up your order.', 'success')
end)
