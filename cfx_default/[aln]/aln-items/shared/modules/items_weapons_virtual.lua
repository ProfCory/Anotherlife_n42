-- Virtual catalog entries for GTA stock weapon wheel + ammo.
-- Not normal inventory items. Used by shops/unlocks to grant via natives.

return {
  weapon_pistol = {
    label = "Pistol",
    icon = "pistol",
    domain = "weapon",
    storage = "weaponwheel",
    inventoryVisible = false,
    buy = 2500,
    sell = 0,
    tags = { "weaponwheel" },
    hooks = { weapon = { hash = `WEAPON_PISTOL` } },
  },

  weapon_sns_pistol = {
    label = "SNS Pistol",
    icon = "sns-pistol",
    domain = "weapon",
    storage = "weaponwheel",
    inventoryVisible = false,
    buy = 1800,
    sell = 0,
    tags = { "weaponwheel" },
    hooks = { weapon = { hash = `WEAPON_SNSPISTOL` } },
  },

  weapon_combat_pistol = {
    label = "Combat Pistol",
    icon = "combat-pistol",
    domain = "weapon",
    storage = "weaponwheel",
    inventoryVisible = false,
    buy = 4200,
    sell = 0,
    tags = { "weaponwheel" },
    hooks = { weapon = { hash = `WEAPON_COMBATPISTOL` } },
  },

  weapon_smg = {
    label = "SMG",
    icon = "smg",
    domain = "weapon",
    storage = "weaponwheel",
    inventoryVisible = false,
    buy = 8200,
    sell = 0,
    tags = { "weaponwheel" },
    hooks = { weapon = { hash = `WEAPON_SMG` } },
  },

  weapon_assault_rifle = {
    label = "Assault Rifle",
    icon = "assault-rifle",
    domain = "weapon",
    storage = "weaponwheel",
    inventoryVisible = false,
    buy = 14500,
    sell = 0,
    tags = { "weaponwheel" },
    hooks = { weapon = { hash = `WEAPON_ASSAULTRIFLE` } },
  },

  ammo_pistol_box = {
    label = "Pistol Ammo (Box)",
    icon = "box-magazine",
    domain = "ammo",
    storage = "weaponwheel",
    inventoryVisible = false,
    buy = 120,
    sell = 0,
    tags = { "weaponwheel" },
    hooks = { ammo = { ["for"] = "pistol", amount = 24 } },
  },

  ammo_rifle_box = {
    label = "Rifle Ammo (Box)",
    icon = "box-magazine",
    domain = "ammo",
    storage = "weaponwheel",
    inventoryVisible = false,
    buy = 240,
    sell = 0,
    tags = { "weaponwheel" },
    hooks = { ammo = { ["for"] = "rifle", amount = 30 } },
  },
}
