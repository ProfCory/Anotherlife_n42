Config = {}
Config.StressChance = 0.1 -- Default: 10% -- Percentage Stress Chance When Shooting (0-1)
Config.UseMPH = true -- If true speed math will be done as MPH, if false KPH will be used
Config.MinimumStress = 60 -- Minimum Stress Level For Screen Shaking
Config.MinimumSpeedUnbuckled = 45 -- Going Over This Speed Will Cause Stress
Config.MinimumSpeed = 120 -- Going Over This Speed Will Cause Stress

-- Stress

Config.WhitelistedWeapons = {
    'weapon_petrolcan',
    'weapon_hazardcan',
    'weapon_fireextinguisher'
}

Config.Intensity = {
    ["shake"] = {
        [1] = {
            min = 50,
            max = 60,
            intensity = 0.12,
        },
        [2] = {
            min = 60,
            max = 70,
            intensity = 0.17,
        },
        [3] = {
            min = 70,
            max = 80,
            intensity = 0.22,
        },
        [4] = {
            min = 80,
            max = 90,
            intensity = 0.28,
        },
        [5] = {
            min = 90,
            max = 100,
            intensity = 0.32,
        },
    }
}

Config.EffectInterval = {
    [1] = {
        min = 50,
        max = 60,
        timeout = math.random(50000, 60000)
    },
    [2] = {
        min = 60,
        max = 70,
        timeout = math.random(40000, 50000)
    },
    [3] = {
        min = 70,
        max = 80,
        timeout = math.random(30000, 40000)
    },
    [4] = {
        min = 80,
        max = 90,
        timeout = math.random(20000, 30000)
    },
    [5] = {
        min = 90,
        max = 100,
        timeout = math.random(15000, 20000)
    }
}

-- =========================================================
-- Retro Digital Dash (Vehicle HUD enhancement)
-- =========================================================
Config.RetroDash = {
    Enabled = true,              -- Enables the 80s/90s VFD-style dash in qb-hud
    HideDefaultVehicleHud = false, -- If true, hides the stock qb-hud vehicle circles/street line
    MaxSpeed = 180,              -- MPH/KPH cap for the speed ring scaling (uses Config.UseMPH)
    FuelSegments = 6,            -- Number of segments for the fuel bar
    SpeedSmoothingAlpha = 0.20,  -- 0.0-1.0 : higher = snappier, lower = smoother
}
