local QBCore = exports['qb-core']:GetCoreObject()

-- =========================================================
-- Helpers
-- =========================================================

local function notify(msg, ntype)
    TriggerEvent('QBCore:Notify', msg, ntype or 'primary')
end

local function doSleep(kind)
    local duration = Config.SleepDurations[kind] or 20
    local cycles = 1

    DoScreenFadeOut(800)
    Wait(1200)

    TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_BUM_SLUMPED', 0, true)
    Wait(duration * 1000)

    ClearPedTasks(PlayerPedId())
    DoScreenFadeIn(800)

    -- Tell status system what kind of sleep this was
    TriggerEvent('aln_status:client:Sleep', kind, cycles)

    notify('You feel more rested.', 'success')
end

-- =========================================================
-- Coffee
-- =========================================================

local function buyCoffee()
    QBCore.Functions.TriggerCallback('aln_sleep:server:tryPay', function(ok)
        if not ok then
            notify('Not enough money.', 'error')
            return
        end

        TriggerEvent('aln_status:client:Add', 'fatigue', -Config.Coffee.FatigueReduction)
        notify('Coffee perks you up.', 'success')
    end, Config.CoffeePrice)
end

-- =========================================================
-- Motels (good sleep, but not perfect)
-- =========================================================

local function registerMotels()
    for i, m in ipairs(Config.Motels) do
        exports['qb-target']:AddCircleZone(
            ('aln_motel_%d'):format(i),
            vector3(m.coords.x, m.coords.y, m.coords.z),
            1.0,
            { name = ('aln_motel_%d'):format(i), useZ = true },
            {
                options = {
                    {
                        icon = 'fas fa-bed',
                        label = ('Sleep ($%d)'):format(Config.MotelPrice),
                        action = function()
                            QBCore.Functions.TriggerCallback('aln_sleep:server:tryPay', function(ok)
                                if not ok then
                                    notify('Not enough money.', 'error')
                                    return
                                end
                                doSleep('motel')
                            end, Config.MotelPrice)
                        end
                    }
                },
                distance = Config.TargetDistance
            }
        )
    end
end

-- =========================================================
-- Coffee spots
-- =========================================================

local function registerCoffee()
    for i, c in ipairs(Config.CoffeeSpots) do
        exports['qb-target']:AddCircleZone(
            ('aln_coffee_%d'):format(i),
            vector3(c.coords.x, c.coords.y, c.coords.z),
            1.0,
            { name = ('aln_coffee_%d'):format(i), useZ = true },
            {
                options = {
                    {
                        icon = 'fas fa-mug-hot',
                        label = ('Coffee ($%d)'):format(Config.CoffeePrice),
                        action = buyCoffee
                    }
                },
                distance = Config.TargetDistance
            }
        )
    end
end

-- =========================================================
-- Radial actions
-- =========================================================

-- Short rest: quick breather, not real sleep
RegisterNetEvent('aln_sleep:client:ShortRest', function()
    DoScreenFadeOut(400)
    Wait(600)

    TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_STAND_MOBILE', 0, true)
    Wait(8000)

    ClearPedTasks(PlayerPedId())
    DoScreenFadeIn(400)

    TriggerEvent('aln_status:client:Add', 'fatigue', -10)
    TriggerServerEvent('hud:server:RelieveStress', 5)

    notify('You take a moment to catch your breath.', 'success')
end)

-- Crash pad: same quality as vehicle sleep, no cops
RegisterNetEvent('aln_sleep:client:CrashHere', function()
    doSleep('vehicle') -- intentional: low-quality rest
end)

-- Vehicle sleep: risky, cops may notice
RegisterNetEvent('aln_sleep:client:VehicleSleep', function()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        notify('You need to be in a vehicle.', 'error')
        return
    end

    doSleep('vehicle')

    if math.random() < Config.VehicleSleep.CopChance then
        SetPlayerWantedLevel(PlayerId(), Config.VehicleSleep.WantedLevel, false)
        SetPlayerWantedLevelNow(PlayerId(), false)
        notify('Police notice your suspicious vehicle...', 'error')
    end
end)

-- =========================================================
-- Init
-- =========================================================

CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do
        Wait(500)
    end

    registerMotels()
    registerCoffee()
end)
