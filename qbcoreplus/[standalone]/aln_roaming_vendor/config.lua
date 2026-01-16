Config = {}

-- Core settings
Config.Debug = false
Config.StreamDistance = 160.0

-- Vendor entity
Config.VendorVehicleModel = 'burrito3'          -- van
Config.DriverPedModel = 's_m_m_dockwork_01'     -- vendor driver ped

-- qb-target label
Config.TargetLabel = "Roaming Vendor"

-- Delivery modes: "inventory" or "pickup"
-- You can also let player choose per order; this is the default.
Config.DefaultDeliveryMode = "pickup"

-- Where to place a pickup crate relative to the vendor vehicle
Config.PickupCrateModel = 'prop_box_wood02a_pu'
Config.PickupCrateOffset = vec3(-1.2, -2.2, 0.0)  -- behind-left of vehicle

-- Item catalog (this is the practical solution to “any item”)
-- If you truly want “any item”, you still need a pricing rule. This supports:
--   - explicit prices per item
--   - fallback price multiplier by item weight is not reliable across inventories
Config.Items = {
    ['water'] = { label = 'Water', buy = 20, sell = 10, max = 50 },
    ['sandwich'] = { label = 'Sandwich', buy = 35, sell = 15, max = 50 },
    ['lockpick'] = { label = 'Lockpick', buy = 250, sell = 90, max = 10 },
    ['phone'] = { label = 'Burner Phone', buy = 600, sell = 200, max = 2 },
}

-- If true, allow selling items not in Config.Items at a low default rate (not recommended)
Config.AllowUnknownSell = false
Config.UnknownSellPrice = 5

-- Money type: 'cash' or 'bank' depending on your economy
Config.PayAccount = 'cash'

-- Route stops: vehicle will park at these.
-- Each stop has:
--  - coords (vec4)
--  - openHours: {start=, stop=} in 0-23 (in-game time)
--  - dwellSeconds: how long it stays parked (real seconds)
Config.Stops = {
    {
        name = "Sandy - 24/7 Lot",
        coords = vec4(1962.9, 3743.2, 32.3, 30.0),
        openHours = { start = 6, stop = 11 },
        dwellSeconds = 240
    },
    {
        name = "Vespucci - Parking",
        coords = vec4(-1168.2, -1472.3, 4.4, 125.0),
        openHours = { start = 12, stop = 16 },
        dwellSeconds = 240
    },
    {
        name = "Mirror Park - Corner",
        coords = vec4(1152.5, -428.6, 67.0, 80.0),
        openHours = { start = 17, stop = 22 },
        dwellSeconds = 240
    },
}

-- Driving between stops
Config.DriveStyle = 786603        -- safe-ish
Config.DriveSpeed = 18.0          -- m/s-ish
Config.UseRealDriving = true      -- true = AI drives; false = fade+teleport between stops

-- Vendor map blip (proximity-based)
Config.VendorBlipRadius = 3200.0        -- ≈ 2 miles
Config.VendorBlipSprite = 280           -- store / vendor
Config.VendorBlipScale  = 0.8
Config.VendorBlipColor  = 2             -- green
Config.VendorBlipLabel  = 'Roaming Vendor'
