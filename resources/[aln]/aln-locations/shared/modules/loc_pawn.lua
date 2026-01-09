ALN_LOCATION_MODULES = ALN_LOCATION_MODULES or {}

ALN_LOCATION_MODULES['pawn'] = {
  pawn_strawberry = {
    label = "Pawn Shop (Strawberry)",
    kind = "shop",
    coords = vector3(55.6, -1748.9, 29.6),
    tags = { "pawn", "city" },
    blip = { sprite = 431, color = 46, name = "Pawn Shop" },
    interact = { radius = 1.8 },
  },
  pawn_sandy = {
    label = "Pawn Shop (Sandy Shores)",
    kind = "shop",
    coords = vector3(1693.6, 3761.7, 34.7),
    tags = { "pawn", "blaines" },
    blip = { sprite = 431, color = 46, name = "Pawn Shop" },
    interact = { radius = 1.8 },
  },
  pawn_paleto = {
    label = "Pawn Shop (Paleto Bay)",
    kind = "shop",
    coords = vector3(-111.5, 6389.0, 31.5),
    tags = { "pawn", "paleto" },
    blip = { sprite = 431, color = 46, name = "Pawn Shop" },
    interact = { radius = 1.8 },
  },
}
