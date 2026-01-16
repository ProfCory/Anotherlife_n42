local spawned = {} -- [shopId] = { staff = ped, customers = {ped1, ped2...} }

local function loadModel(model)
    local hash = (type(model) == "string") and joaat(model) or model
    if not IsModelInCdimage(hash) then return nil end
    RequestModel(hash)
    local timeout = GetGameTimer() + 8000
    while not HasModelLoaded(hash) do
        Wait(10)
        if GetGameTimer() > timeout then
            return nil
        end
    end
    return hash
end

local function safeDeletePed(ped)
    if ped and DoesEntityExist(ped) then
        SetEntityAsMissionEntity(ped, true, true)
        DeleteEntity(ped)
    end
end

local function draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if not onScreen then return end
    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)

    local factor = (#text) / 370
    DrawRect(_x, _y + 0.012, 0.015 + factor, 0.03, 0, 0, 0, 110)
end

local function showHelpText(msg)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, 1)
end

local function setupPedCommon(ped, heading)
    SetEntityHeading(ped, heading or 0.0)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdoll(ped, false)
    SetPedFleeAttributes(ped, 0, false)
    SetPedDropsWeaponsWhenDead(ped, false)
end

local function spawnStaff(shop)
    local s = shop.staff
    local hash = loadModel(s.model)
    if not hash then return nil end

    local ped = CreatePed(4, hash, s.coords.x, s.coords.y, s.coords.z - 1.0, s.coords.w, false, true)
    setupPedCommon(ped, s.coords.w)
    if s.scenario and s.scenario ~= "" then
        TaskStartScenarioInPlace(ped, s.scenario, 0, true)
    end
    SetModelAsNoLongerNeeded(hash)
    return ped
end

local function randomFloat(min, max)
    return min + math.random() * (max - min)
end

local function spawnCustomers(shop)
    if not shop.customers then return {} end

    local c = shop.customers
    local count = math.random(Config.CustomersMin, Config.CustomersMax)
    local spawnedCustomers = {}

    for i = 1, count do
        local model = c.models[math.random(1, #c.models)]
        local hash = loadModel(model)
        if hash then
            local angle = randomFloat(0.0, 6.28318)
            local radius = randomFloat(4.0, Config.CustomerWanderRadius)
            local x = c.areaCenter.x + math.cos(angle) * radius
            local y = c.areaCenter.y + math.sin(angle) * radius
            local z = c.areaCenter.z

            local heading = randomFloat(0.0, 360.0)
            local ped = CreatePed(4, hash, x, y, z - 1.0, heading, false, true)

            -- Customers should look alive, not frozen.
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedCanRagdoll(ped, true)
            SetPedFleeAttributes(ped, 0, false)

            local scenario = c.scenarios and c.scenarios[math.random(1, #c.scenarios)] or nil
            if scenario and scenario ~= "" then
                TaskStartScenarioInPlace(ped, scenario, 0, true)
            else
                TaskWanderStandard(ped, 10.0, 10)
            end

            SetModelAsNoLongerNeeded(hash)
            table.insert(spawnedCustomers, ped)
        end
        Wait(0)
    end

    return spawnedCustomers
end

local function spawnShopSet(shop)
    spawned[shop.id] = spawned[shop.id] or {}
    if spawned[shop.id].staff and DoesEntityExist(spawned[shop.id].staff) then return end

    local staff = spawnStaff(shop)
    local customers = {}
    if Config.SpawnCustomers then
        customers = spawnCustomers(shop)
    end

    spawned[shop.id].staff = staff
    spawned[shop.id].customers = customers
end

local function despawnShopSet(shop)
    local entry = spawned[shop.id]
    if not entry then return end

    safeDeletePed(entry.staff)
    if entry.customers then
        for _, ped in ipairs(entry.customers) do
            safeDeletePed(ped)
        end
    end

    spawned[shop.id] = nil
end

CreateThread(function()
    math.randomseed(GetGameTimer())

    while true do
        local plyPed = PlayerPedId()
        local plyCoords = GetEntityCoords(plyPed)
        local sleep = 800

        for _, shop in ipairs(Config.Shops) do
            local sCoords = vec3(shop.staff.coords.x, shop.staff.coords.y, shop.staff.coords.z)
            local dist = #(plyCoords - sCoords)

            if dist <= Config.StreamDistance then
                spawnShopSet(shop)
            elseif dist > (Config.StreamDistance + 25.0) then
                despawnShopSet(shop)
            end

            -- Near-hint + label
            local entry = spawned[shop.id]
            if entry and entry.staff and DoesEntityExist(entry.staff) then
                if dist <= 30.0 then sleep = 0 end

                if Config.Draw3DLabel and dist <= 15.0 then
                    local pedCoords = GetEntityCoords(entry.staff)
                    draw3DText(pedCoords.x, pedCoords.y, pedCoords.z + 1.05, shop.label)
                end

                if Config.ShowNearHint and dist <= Config.HintDistance then
                    showHelpText(("~INPUT_CONTEXT~ %s"):format(shop.hint or shop.label or ""))
                end
            end
        end

        Wait(sleep)
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    for _, shop in ipairs(Config.Shops) do
        despawnShopSet(shop)
    end
end)
