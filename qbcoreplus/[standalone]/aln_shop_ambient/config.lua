Config = {}

-- If true, shows a small help text when you are near a shop ped.
Config.ShowNearHint = true

-- If true, draws a small 3D label above the staff NPC.
Config.Draw3DLabel = true

-- Spawn extra ambient “customers” near each shop.
Config.SpawnCustomers = true

-- How far away to stream/spawn peds (client-side).
Config.StreamDistance = 80.0

-- Hint distance from staff ped.
Config.HintDistance = 8.0

-- Customer count range per shop.
Config.CustomersMin = 2
Config.CustomersMax = 5

-- If you want customers to be less “busy”, lower this number.
Config.CustomerWanderRadius = 18.0

-- Shops list (examples — replace coords with your own).
Config.Shops = {
    {
        id = "clothing_pillbox",
        label = "Clothing Store",
        hint = "Clothing store is here",
        staff = {
            model = "s_f_y_shop_low", -- clothing clerk vibe
            coords = vec4(72.3, -1399.1, 29.4, 270.0),
            scenario = "WORLD_HUMAN_STAND_IMPATIENT",
        },
        customers = {
            areaCenter = vec3(73.3, -1398.0, 29.4),
            models = { "a_f_y_hipster_02", "a_m_y_hipster_01", "a_m_m_business_01" },
            scenarios = { "WORLD_HUMAN_STAND_MOBILE", "WORLD_HUMAN_WINDOW_SHOP_BROWSE", "WORLD_HUMAN_STAND_IMPATIENT" },
        }
    },

    {
        id = "pdm",
        label = "Premium Deluxe Motorsport",
        hint = "Car dealer is here",
        staff = {
            model = "s_m_m_autoshop_01",
            coords = vec4(-33.7, -1102.1, 26.4, 72.0),
            scenario = "WORLD_HUMAN_CLIPBOARD",
        },
        customers = {
            areaCenter = vec3(-36.0, -1105.0, 26.4),
            models = { "a_m_y_business_03", "a_f_y_business_02", "a_m_m_business_01" },
            scenarios = { "WORLD_HUMAN_STAND_MOBILE", "WORLD_HUMAN_CLIPBOARD", "WORLD_HUMAN_TOURIST_MAP" },
        }
    },
}
