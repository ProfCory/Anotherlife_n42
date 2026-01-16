Config = Config or {}

-- Turn off chat spam while testing
Config.Debug = true

-- Criminal XP / Level bands
Config.Criminal = {
    XPMax = 15000,
    Bands = {
        { max = 500,   level = 1,  mod = -1 },
        { max = 1000,  level = 2,  mod = -1 },
        { max = 2000,  level = 3,  mod = 0  },
        { max = 3000,  level = 4,  mod = 0  },
        { max = 4500,  level = 5,  mod = 1  },
        { max = 6000,  level = 6,  mod = 1  },
        { max = 8000,  level = 7,  mod = 2  },
        { max = 10000, level = 8,  mod = 2  },
        { max = 12500, level = 9,  mod = 3  },
        { max = 15000, level = 10, mod = 3  },
    },

    SuccessXpPerDC = 10,
    FailXpPerDC = 0,

    NextAdvEnabled = true,
    NextAdvTTLSeconds = 300,

    ToolBreak = {
        Enabled = true,
        Base = 10,
        PerDc = 2,
        Min = 10,
        Max = 40,
        Nat1BreakChance = 100
    },

    CritFailWantedStars = 2,
    SpawnCopsOnNat1 = true,
    CopSpawn = {
        Count = 2,
        Radius = 35.0,
        Weapon = `WEAPON_PISTOL`
    },
    WantedDisThreshold = 1,
}

-- Dice-gated action definitions used by the radial "Ask the DM" submenu
Config.Actions = {
    ['generic.check'] = {
        label = 'Skill Check',
        baseDC = 10,
        requiresTool = false,
        toolGivesAdv = false,
    },

    -- Vehicle
    ['vehicle.entry.lockpick'] = {
        label = 'Lockpick Vehicle',
        baseDC = 12,
        requiresTool = false,
        toolGivesAdv = true,
    },
    ['vehicle.entry.smash'] = {
        label = 'Smash Window',
        baseDC = 11,
        requiresTool = false,
        toolGivesAdv = false,
    },
    ['vehicle.hotwire'] = {
        label = 'Hotwire Vehicle',
        baseDC = 14,
        requiresTool = false,
        toolGivesAdv = true,
    },

    -- "Ask the DM" utilities (dice gate only)
    ['hack.panel'] = {
        label = 'Hack Panel',
        baseDC = 15,
        requiresTool = false,
        toolGivesAdv = true,
    },
    ['pinpad.check'] = {
        label = 'Pinpad',
        baseDC = 14,
        requiresTool = false,
        toolGivesAdv = true,
    },
    ['safecrack.check'] = {
        label = 'Safecracking',
        baseDC = 16,
        requiresTool = false,
        toolGivesAdv = true,
    },
}

-- Optional wiring: drop real events in here later (no more code edits needed)
-- type: 'client' | 'server'
Config.Integration = {
    hacking = { type = 'client', event = '' },
    pinpad  = { type = 'client', event = '' },
    safe    = { type = 'client', event = '' },
}

-- Vehicle Difficulty Tuning
Config.VehicleClassDC = {
    [0]  = 12, [1]  = 12, [2]  = 13, [3]  = 12, [4]  = 13,
    [5]  = 14, [6]  = 15, [7]  = 18, [8]  = 13, [9]  = 13,
    [10] = 12, [11] = 12, [12] = 12, [13] = 10, [14] = 13,
    [15] = 15, [16] = 15, [17] = 12, [18] = 18, [19] = 18,
    [20] = 16, [21] = 15, [22] = 12
}

Config.ValueBumps = {
    { min = 20000,  add = 1 },
    { min = 60000,  add = 2 },
    { min = 150000, add = 3 },
}

Config.Tools = {
    lockpick_basic  = { item = 'lockpick',           tier = 'basic' },
    lockpick_adv    = { item = 'advancedlockpick',   tier = 'adv'   },
    hacker_basic    = { item = 'hacking_device',     tier = 'basic' },
    hacker_adv      = { item = 'hacking_device_adv', tier = 'adv'   },
}
