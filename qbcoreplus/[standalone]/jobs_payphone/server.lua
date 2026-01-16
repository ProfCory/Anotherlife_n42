local QBCore = exports['qb-core']:GetCoreObject()

-- 1. Callback to check License and Rep
QBCore.Functions.CreateCallback('jobs_payphone:server:GetPlayerStatus', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local hasLicense = false
    if Player.Functions.GetItemByName('lawyerpass') then
        hasLicense = true
    elseif Player.PlayerData.metadata['licences'] and Player.PlayerData.metadata['licences']['criminal'] then
        hasLicense = true
    end

    local rep = Player.PlayerData.metadata[Config.RepType] or 0
    cb(hasLicense, rep)
end)

-- 2. Purchase License
RegisterNetEvent('jobs_payphone:server:PurchaseLicense', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.Functions.RemoveMoney('cash', Config.LicenseCost, "bought-crim-license") then
        if QBCore.Shared.Items['lawyerpass'] then
            Player.Functions.AddItem('lawyerpass', 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['lawyerpass'], "add")
        else
            local licences = Player.PlayerData.metadata['licences']
            licences['criminal'] = true
            Player.Functions.SetMetaData('licences', licences)
        end
        
        if not Player.PlayerData.metadata[Config.RepType] then
            Player.Functions.SetMetaData(Config.RepType, 0)
        end

        TriggerClientEvent('QBCore:Notify', src, "You bought a burner license. Welcome to the network.", "success")
        TriggerClientEvent('jobs_payphone:client:OpenPhoneMenu', src)
    else
        TriggerClientEvent('QBCore:Notify', src, "Not enough cash.", "error")
    end
end)

-- 3. Complete Job & Payout
RegisterNetEvent('jobs_payphone:server:CompleteJob', function(jobData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if jobData and jobData.payout then
        Player.Functions.AddMoney('cash', jobData.payout, "crim-job-payout")
        
        local currentRep = Player.PlayerData.metadata[Config.RepType] or 0
        local xpGain = math.random(10, 20)
        Player.Functions.SetMetaData(Config.RepType, currentRep + xpGain)
        
        TriggerClientEvent('QBCore:Notify', src, "Job Complete. +$"..jobData.payout.." | +"..xpGain.." Rep", "success")
    end
end)