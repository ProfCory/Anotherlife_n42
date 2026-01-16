Config = {}

-- Max pals registered per player (persistent roster)
Config.MaxCrew = 5

-- Proximity “Make a Pal”
Config.MakeKey = "E"
Config.MakeDistance = 2.0

-- Relationship group
Config.RelationshipGroup = "ALN_PALS"

-- Pricing (hire = on-duty activation)
Config.CurrencyLabel = "cash"
Config.BaseHireCost = 250
Config.CostArmor = 150
Config.CostWeapon = 300
Config.CostStealth = 200

-- Scaling based on how many you have on duty AFTER hiring
Config.ScaleAt3 = 2.0   -- if on-duty count >= 3 => x2
Config.ScaleAt5 = 3.0   -- if on-duty count >= 5 => x3

-- Downed regen
Config.EnableDownedRegen = true
Config.DownTimeMs = 10000
Config.ReviveHealth = 120

-- Owned vehicle follow (optional)
Config.EnableOwnedVehicleChance = true
Config.OwnedVehicleChance = 0.18
Config.OwnedVehicleModels = { "sultan", "buffalo", "kuruma", "primo", "granger" }
Config.OwnedVehicleSpawnDistance = 18.0

-- Flavor hangouts
Config.Hangouts = {
  "Mirror Park",
  "Del Perro Beach",
  "Sandy Shores",
  "Grapeseed",
  "Downtown Vinewood",
  "La Mesa",
  "Paleto Bay",
}

-- Weapons list
Config.WeaponList = {
  `WEAPON_PISTOL`,
  `WEAPON_COMBATPISTOL`,
  `WEAPON_PISTOL50`,
  `WEAPON_SMG`,
}

-- Tier tuning (1 Noob, 2 Basic, 3 Chad)
Config.Tiers = {
  [1] = { label="Noob",  wageMult=0.75, accuracy=18, combatAbility=0, combatMove=1, followSpeed=2.6 },
  [2] = { label="Basic", wageMult=1.00, accuracy=35, combatAbility=1, combatMove=2, followSpeed=3.0 },
  [3] = { label="Chad",  wageMult=1.80, accuracy=55, combatAbility=2, combatMove=3, followSpeed=3.4 },
}

-- Blips
Config.EnableBlips = true
Config.BlipSprite = 280   -- friend/ally style
Config.BlipScale  = 0.75
