ALN_LOCATION_MODULES = ALN_LOCATION_MODULES or {}

ALN_LOCATION_MODULES['shops_shells'] = {
  -- These are "known good entrances" so when you add NPCs/targets later,
  -- you don’t have to redo coords.

  shop_convenience_1 = {
    label = "Convenience Store (Strawberry)",
    kind = "shop",
    coords = vector3(25.7, -1346.7, 29.5),
    tags = { "shop.convenience", "city" },
    blip = { sprite = 52, color = 2, name = "Store" },
  },

  shop_convenience_2 = {
    label = "Convenience Store (Vespucci)",
    kind = "shop",
    coords = vector3(-1222.9, -906.9, 12.3),
    tags = { "shop.convenience", "city" },
    blip = { sprite = 52, color = 2, name = "Store" },
  },

  shop_gas_1 = {
    label = "Gas Station (Grove St)",
    kind = "shop",
    coords = vector3(-70.8, -1761.5, 29.5),
    tags = { "shop.gas", "city" },
    blip = { sprite = 361, color = 1, name = "Gas" },
  },

  shop_gas_sandy = {
    label = "Gas Station (Sandy Shores)",
    kind = "shop",
    coords = vector3(2001.7, 3778.6, 32.2),
    tags = { "shop.gas", "blaines" },
    blip = { sprite = 361, color = 1, name = "Gas" },
  },

  shop_hardware_sandy = {
    label = "Hardware (Blaine County)",
    kind = "shop",
    coords = vector3(1698.3, 4923.4, 42.1),
    tags = { "shop.hardware", "blaines" },
    blip = { sprite = 566, color = 47, name = "Hardware" },
  },

  shop_pharmacy_city = {
    label = "Pharmacy (Downtown)",
    kind = "shop",
    coords = vector3(318.3, -1077.7, 29.5),
    tags = { "shop.pharmacy", "city" },
    blip = { sprite = 51, color = 2, name = "Pharmacy" },
  },

  shop_pawn_city = {
    label = "Pawn Shop (Davis)",
    kind = "shop",
    coords = vector3(412.3, -806.3, 29.4),
    tags = { "shop.pawn", "city" },
    blip = { sprite = 431, color = 5, name = "Pawn" },
  },
}
