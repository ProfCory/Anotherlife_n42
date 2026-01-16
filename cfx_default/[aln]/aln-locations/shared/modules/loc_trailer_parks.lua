ALN_LOCATION_MODULES = ALN_LOCATION_MODULES or {}

ALN_LOCATION_MODULES['trailers'] = {
  home_trailer_sandy_park = {
    label = "Sandy Shores Trailer Park",
    kind = "housing",
    coords = vector3(1526.5, 3778.0, 34.5),
    tags = { "housing.trailerpark", "blaines", "tier.low" },
    blip = { sprite = 475, color = 18, name = "Trailer Park" },
  },

  home_trailer_harmony = {
    label = "Harmony Trailer Cluster",
    kind = "housing",
    coords = vector3(315.7, 2622.7, 44.5),
    tags = { "housing.trailerpark", "blaines", "tier.low" },
    blip = { sprite = 475, color = 18, name = "Trailer Park" },
  },

  gang_stab_city = {
    label = "Stab City",
    kind = "gang",
    coords = vector3(30.2, 3662.2, 40.4),
    tags = { "gang.lost", "blaines", "stronghold" },
    blip = { sprite = 84, color = 1, name = "Gang Area" },
  },
}
