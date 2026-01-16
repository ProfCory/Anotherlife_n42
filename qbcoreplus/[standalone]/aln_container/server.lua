local QBCore = exports['qb-core']:GetCoreObject()

local AllowedConsumables = {
    water = true,
    sandwich = true,
    beer = true,
    joint = true,
    blunt = true,
    soda = true
}

-- LOAD OR CREATE CONTAINER
RegisterNetEvent('aln_container:server:Load', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid

    local row = MySQL.single.await(
        'SELECT * FROM aln_illegal_containers WHERE citizenid = ?',
        { cid }
    )

    if not row then
        row = {
            stash_id = 'aln_container_stash_' .. cid,
            cooler_id = 'aln_container_cooler_' .. cid
        }

        MySQL.insert.await(
            'INSERT INTO aln_illegal_containers (citizenid, stash_id, cooler_id) VALUES (?, ?, ?)',
            { cid, row.stash_id, row.cooler_id }
        )
    end

    -- Register stashes
    exports['qb-inventory']:AddStash(
        row.stash_id,
        'Illegal Container Stash',
        40,
        250000,
        false
    )

    exports['qb-inventory']:AddStash(
        row.cooler_id,
        'Container Cooler',
        12,
        20000,
        false
    )

    TriggerClientEvent('aln_container:client:Loaded', src, row.stash_id, row.cooler_id)
end)

-- DELETE CONTAINER (LEAVE + TAKE ALL)
RegisterNetEvent('aln_container:server:Delete', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    MySQL.update.await(
        'DELETE FROM aln_illegal_containers WHERE citizenid = ?',
        { Player.PlayerData.citizenid }
    )
end)

-- COOLER CONSUMABLE LOCK
RegisterNetEvent('aln_container:server:ValidateCooler', function(item)
    local src = source
    if not AllowedConsumables[item] then
        TriggerClientEvent('QBCore:Notify', src, 'Only consumables can go in the cooler', 'error')
        return false
    end
    return true
end)
