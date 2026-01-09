ALN_LOCATION_MODULES = ALN_LOCATION_MODULES or {}

ALN_LOCATION_MODULES['houses'] = {
  home_house_franklin = {
    label = "Forum Drive House",
    kind = "housing",
    coords = vector3(-14.5, -1441.6, 31.1),
    tags = { "housing.house", "city", "tier.mid" },
    blip = { sprite = 40, color = 2, name = "House" },
  },

  home_house_michael = {
    label = "Rockford Hills House",
    kind = "housing",
    coords = vector3(-816.3, 178.7, 72.2),
    tags = { "housing.house", "city", "tier.high" },
    blip = { sprite = 40, color = 30, name = "House" },
  },

  home_house_trevor = {
    label = "Trevor's Trailer (Sandy Shores)",
    kind = "housing",
    coords = vector3(1973.1, 3816.0, 33.4),
    tags = { "housing.house", "blaines", "tier.low" },
    blip = { sprite = 40, color = 8, name = "Trailer" },
  },

  home_house_grapeseed = {
    label = "Grapeseed Farmhouse",
    kind = "housing",
    coords = vector3(2441.7, 4969.5, 46.8),
    tags = { "housing.house", "blaines", "tier.low" },
    blip = { sprite = 40, color = 19, name = "House" },
  },
}
