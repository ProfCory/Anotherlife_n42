Config = {}
Config.Debug = false -- Set to true to see print statements for debugging

-- Interaction Settings
Config.LicenseCost = 1000
Config.PhoneModels = {
    'prop_phonebox_04',
    'prop_phonebox_01',
    'prop_phonebox_02',
    'prop_phonebox_03',
    -- Add other phone models here
}

-- Reputation / XP Settings
-- You can use 'criminal_rep' or existing metadata.
-- If the player lacks the metadata, the script will initialize it at 0.
Config.RepType = 'criminal_rep' 

-- Job Tiers
Config.Tiers = {
    [1] = {
        label = "Street Hustler",
        minRep = 0,
        jobs = {
            { type = "house_robbery", label = "House Robbery Tip", payout = 200 },
            { type = "chop_shop", label = "Steal & Chop Vehicle", payout = 350 }
        }
    },
    [2] = {
        label = "Associate",
        minRep = 500,
        jobs = {
            { type = "store_robbery", label = "Business Hit", payout = 800 },
            { type = "truck_robbery", label = "Armored Truck Route", payout = 1200 }
        }
    },
    [3] = {
        label = "Enforcer",
        minRep = 1500,
        jobs = {
            { type = "hit_gang", label = "Gang Leader Hit", payout = 2500 },
            { type = "hit_silent", label = "Silent Assassination", payout = 3000 }
        }
    },
    [4] = {
        label = "Kingpin",
        minRep = 5000,
        jobs = {
            { type = "hit_politician", label = "Assassinate Official", payout = 10000, multiStage = true }
        }
    }
}

-- Locations for Chop Shop (Randomly selected)
Config.ChopDropoffs = {
    vector3(472.0, -1885.0, 26.0), -- Example: Cypress Flats
    vector3(-420.0, -1680.0, 19.0) -- Example: Scrapyard
}

-- Pre-defined payphone locations for Blips (Optional if you want static blips)
Config.StaticPhones = {
    vector3(123.45, 123.45, 123.45), -- Add real coords here
}