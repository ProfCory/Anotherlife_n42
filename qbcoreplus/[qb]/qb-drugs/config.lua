Config = {
    Debug = false,
    NearbyDeliveries = false,
    DeliveryWithin = 2000,

    -- =====================================================
    -- DEALER NPCs (raw materials + tools only)
    -- =====================================================
    Dealers = {

        {
            name = "Eli Greenleaf",
            coords = vector4(-1172.3, -1572.8, 4.66, 215.0),
            ped = "a_m_y_hipster_01",
            scenario = "WORLD_HUMAN_SMOKING",
            products = {
                { name = "weed_whitewidow", price = 25 },
                { name = "weed_skunk", price = 25 },
                { name = "rolling_paper", price = 5 },
                { name = "lighter", price = 10 },
            }
        },

        {
            name = "Sunny Vee",
            coords = vector4(-1477.6, -676.2, 29.04, 90.0),
            ped = "a_m_y_beach_03",
            scenario = "WORLD_HUMAN_DRUG_DEALER",
            products = {
                { name = "weed_purplehaze", price = 30 },
                { name = "weed_ogkush", price = 35 },
                { name = "rolling_paper", price = 5 },
                { name = "lighter", price = 10 },
                { name = "xtcbaggy", price = 120 },
                { name = "acid", price = 160 },
            }
        },

        {
            name = "Marcus Flint",
            coords = vector4(117.9, -1943.6, 20.7, 50.0),
            ped = "g_m_y_famdnf_01",
            scenario = "WORLD_HUMAN_GUARD_STAND",
            products = {
                { name = "crack_baggy", price = 90 },
                { name = "cokebaggy", price = 200 },
                { name = "painkillers", price = 60 },
            }
        },

        {
            name = "Old Man Rigs",
            coords = vector4(861.3, -2535.7, 28.4, 175.0),
            ped = "g_m_m_chicold_01",
            scenario = "WORLD_HUMAN_DRUG_DEALER",
            products = {
                { name = "meth", price = 250 },
                { name = "painkillers", price = 70 },
            }
        },

        {
            name = "Victor Black",
            coords = vector4(-565.4, 276.2, 83.1, 180.0),
            ped = "a_m_m_business_01",
            scenario = "WORLD_HUMAN_STAND_MOBILE",
            products = {
                { name = "cokebaggy", price = 260 },
            }
        },

        {
            name = "Dusty Ray",
            coords = vector4(1389.7, 3604.4, 38.9, 200.0),
            ped = "a_m_m_hillbilly_01",
            scenario = "WORLD_HUMAN_DRUG_DEALER",
            products = {
                { name = "weed_amnesia", price = 22 },
                { name = "rolling_paper", price = 6 },
                { name = "lighter", price = 12 },
                { name = "meth", price = 220 },
            }
        },

        {
            name = "North Shore Nick",
            coords = vector4(-102.3, 6331.6, 31.5, 45.0),
            ped = "a_m_m_tramp_01",
            scenario = "WORLD_HUMAN_SMOKING",
            products = {
                { name = "weed_skunk", price = 20 },
                { name = "rolling_paper", price = 5 },
                { name = "lighter", price = 10 },
                { name = "crack_baggy", price = 85 },
            }
        },

        {
            name = "Harbor Ghost",
            coords = vector4(1236.9, -3230.7, 6.0, 270.0),
            ped = "g_m_y_lost_01",
            scenario = "WORLD_HUMAN_STAND_MOBILE",
            products = {
                { name = "weed_ogkush", price = 35 },
                { name = "rolling_paper", price = 6 },
                { name = "lighter", price = 12 },
                { name = "cokebaggy", price = 230 },
                { name = "acid", price = 180 },
            }
        },

        {
            name = "Lucy Kaleidoscope",
            coords = vector4(251.1, -1020.6, 29.3, 180.0),
            ped = "a_f_y_hipster_02",
            scenario = "WORLD_HUMAN_STAND_IMPATIENT",
            products = {
                { name = "acid", price = 170 },
                { name = "xtcbaggy", price = 140 },
            }
        },
    },

    UseTarget = GetConvar('UseTarget', 'false') == 'true',
    PoliceCallChance = 75,

    -- =====================================================
    -- SHOP CONFIG (wholesale / grower access)
    -- =====================================================
    Products = {
        { name = 'weed_whitewidow', price = 15, amount = 150, type = 'item', slot = 1, minrep = 0 },
        { name = 'weed_skunk', price = 15, amount = 150, type = 'item', slot = 2, minrep = 20 },
        { name = 'weed_purplehaze', price = 15, amount = 150, type = 'item', slot = 3, minrep = 40 },
        { name = 'weed_ogkush', price = 15, amount = 150, type = 'item', slot = 4, minrep = 60 },
        { name = 'weed_amnesia', price = 15, amount = 150, type = 'item', slot = 5, minrep = 80 },

        { name = 'weed_whitewidow_seed', price = 15, amount = 150, type = 'item', slot = 6, minrep = 100 },
        { name = 'weed_skunk_seed', price = 15, amount = 150, type = 'item', slot = 7, minrep = 120 },
        { name = 'weed_purplehaze_seed', price = 15, amount = 150, type = 'item', slot = 8, minrep = 140 },
        { name = 'weed_ogkush_seed', price = 15, amount = 150, type = 'item', slot = 9, minrep = 160 },
        { name = 'weed_amnesia_seed', price = 15, amount = 150, type = 'item', slot = 10, minrep = 180 },

        { name = 'rolling_paper', price = 3, amount = 300, type = 'item', slot = 11, minrep = 0 },
        { name = 'lighter', price = 6, amount = 300, type = 'item', slot = 12, minrep = 0 },

        { name = 'painkillers', price = 40, amount = 100, type = 'item', slot = 13, minrep = 50 },
        { name = 'meth', price = 180, amount = 50, type = 'item', slot = 14, minrep = 120 },
        { name = 'acid', price = 140, amount = 50, type = 'item', slot = 15, minrep = 140 },
        { name = 'cokebaggy', price = 200, amount = 50, type = 'item', slot = 16, minrep = 160 },
    },

    -- (Selling, delivery, prices, locations remain unchanged below)
}
