local QBCore = exports['qb-core']:GetCoreObject()
local currentJob = nil
local activeBlip = nil

-- 1. Initialize qb-target on Phone Models
exports['qb-target']:AddTargetModel(Config.PhoneModels, {
    options = {
        {
            type = "client",
            event = "jobs_payphone:client:OpenPhoneMenu",
            icon = "fas fa-user-secret",
            label = "Access Underground Network",
        },
    },
    distance = 2.5,
})

-- 2. Open Phone Menu
RegisterNetEvent('jobs_payphone:client:OpenPhoneMenu', function()
    QBCore.Functions.TriggerCallback('jobs_payphone:server:GetPlayerStatus', function(hasLicense, rep)
        local menu = {
            {
                header = "📞 Secure Line",
                isMenuHeader = true,
            }
        }

        if not hasLicense then
            menu[#menu+1] = {
                header = "Buy Criminal License",
                txt = "Cost: $"..Config.LicenseCost,
                params = {
                    event = "jobs_payphone:client:BuyLicense",
                }
            }
        else
            menu[#menu+1] = {
                header = "Current Status",
                txt = "Reputation: " .. rep,
                isMenuHeader = true
            }

            for tierLvl, tierData in ipairs(Config.Tiers) do
                local isLocked = rep < tierData.minRep
                local headerText = "Tier " .. tierLvl .. ": " .. tierData.label
                
                if isLocked then headerText = headerText .. " (Locked)" end

                menu[#menu+1] = {
                    header = headerText,
                    txt = isLocked and "Requires " .. tierData.minRep .. " Rep" or "View Jobs",
                    disabled = isLocked,
                    params = {
                        event = "jobs_payphone:client:OpenJobSubMenu",
                        args = {
                            tier = tierLvl
                        }
                    }
                }
            end
        end

        exports['qb-menu']:openMenu(menu)
    end)
end)

-- 3. Buy License Event
RegisterNetEvent('jobs_payphone:client:BuyLicense', function()
    TriggerServerEvent('jobs_payphone:server:PurchaseLicense')
end)

-- 4. Job Sub-Menu
RegisterNetEvent('jobs_payphone:client:OpenJobSubMenu', function(data)
    local tier = data.tier
    local jobs = Config.Tiers[tier].jobs
    local menu = {
        { header = "Available Contracts", isMenuHeader = true }
    }

    for _, job in ipairs(jobs) do
        menu[#menu+1] = {
            header = job.label,
            txt = "Payout: ~$" .. job.payout,
            params = {
                event = "jobs_payphone:client:StartJob",
                args = job
            }
        }
    end
    
    menu[#menu+1] = { header = "⬅ Go Back", params = { event = "jobs_payphone:client:OpenPhoneMenu" } }

    exports['qb-menu']:openMenu(menu)
end)

-- 5. Job Handling Logic
RegisterNetEvent('jobs_payphone:client:StartJob', function(jobData)
    if currentJob then 
        QBCore.Functions.Notify("You already have an active contract!", "error")
        return 
    end

    if jobData.type == "house_robbery" and GetResourceState('qb-house-robbery') ~= 'started' then
         QBCore.Functions.Notify("Job Unavailable: Missing Script (qb-house-robbery)", "error")
         return
    end

    currentJob = jobData
    QBCore.Functions.Notify("Contract Accepted: " .. jobData.label, "success")

    if jobData.type == "chop_shop" then
        StartChopShopJob()
    elseif jobData.type == "house_robbery" then
        TriggerEvent("qb-house-robbery:client:begin") 
        currentJob = nil 
    elseif jobData.type == "store_robbery" then
        QBCore.Functions.Notify("Go find a store register to rob.", "primary")
        SetNewWaypoint(24.45, -1346.75) 
        currentJob = nil
    end
end)

function StartChopShopJob()
    local dropLoc = Config.ChopDropoffs[math.random(#Config.ChopDropoffs)]
    SetNewWaypoint(dropLoc.x, dropLoc.y)
    
    QBCore.Functions.Notify("Steal a vehicle and bring it to the marked location.", "primary")
    
    activeBlip = AddBlipForCoord(dropLoc.x, dropLoc.y, dropLoc.z)
    SetBlipSprite(activeBlip, 227)
    SetBlipColour(activeBlip, 1)
    SetBlipRoute(activeBlip, true)

    CreateThread(function()
        while currentJob and currentJob.type == "chop_shop" do
            local plyPed = PlayerPedId()
            local plyCoords = GetEntityCoords(plyPed)
            local dist = #(plyCoords - dropLoc)

            if dist < 10.0 then
                if IsPedInAnyVehicle(plyPed, false) then
                    DrawText3D(dropLoc.x, dropLoc.y, dropLoc.z, "[E] Chop Vehicle")
                    if IsControlJustPressed(0, 38) then
                        local veh = GetVehiclePedIsIn(plyPed, false)
                        QBCore.Functions.DeleteVehicle(veh)
                        TriggerServerEvent("jobs_payphone:server:CompleteJob", currentJob)
                        CleanupJob()
                        break
                    end
                end
            end
            Wait(0)
        end
    end)
end

function CleanupJob()
    if activeBlip then RemoveBlip(activeBlip) end
    currentJob = nil
end

function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

-- 6. Manual Blip Command
RegisterNetEvent('jobs_payphone:client:AddTempBlip', function()
    local coords = GetEntityCoords(PlayerPedId())
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 817)
    SetBlipColour(blip, 2)
    SetBlipScale(blip, 0.7)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Payphone (Manual)")
    EndTextCommandSetBlipName(blip)
    QBCore.Functions.Notify("Payphone marked on GPS", "success")
end)