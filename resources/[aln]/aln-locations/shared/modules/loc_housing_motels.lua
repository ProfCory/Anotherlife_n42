ALN_LOCATION_MODULES = ALN_LOCATION_MODULES or {}

ALN_LOCATION_MODULES['motels'] = {
  home_motel_pink_cage = {
    label = "Pink Cage Motel",
    kind = "housing",
    coords = vector3(324.2, -212.2, 54.1),
    tags = { "housing.motel", "city", "tier.low" },
    blip = { sprite = 475, color = 8, name = "Motel" },
  },

  home_motel_sandy_dreamview = {
    label = "Dream View Motel (Sandy Shores)",
    kind = "housing",
    coords = vector3(1142.3, 2664.1, 38.1),
    tags = { "housing.motel", "blaines", "tier.low" },
    blip = { sprite = 475, color = 8, name = "Motel" },
  },

  home_motel_paleto = {
    label = "The Hen House Motel (Paleto area)",
    kind = "housing",
    coords = vector3(-107.6, 6316.2, 31.6),
    tags = { "housing.motel", "paleto", "tier.low" },
    blip = { sprite = 475, color = 8, name = "Motel" },
  },
}
