ALN_LOCATION_MODULES = ALN_LOCATION_MODULES or {}

ALN_LOCATION_MODULES['parking'] = {
  park_legion_square = {
    label = "Legion Square Parking",
    kind = "parking",
    coords = vector3(215.8, -810.1, 30.7),
    tags = { "parking.free", "city" },
    blip = { sprite = 357, color = 3, name = "Free Parking" },
  },

  park_del_perro_beach = {
    label = "Del Perro Beach Parking",
    kind = "parking",
    coords = vector3(-1464.6, -914.2, 10.1),
    tags = { "parking.free", "city" },
    blip = { sprite = 357, color = 4, name = "Parking" },
  },

  park_casino = {
    label = "Casino Parking",
    kind = "parking",
    coords = vector3(925.4, 50.9, 80.9),
    tags = { "parking.free", "city" },
    blip = { sprite = 357, color = 7, name = "Parking" },
  },

  park_sandy_airfield = {
    label = "Sandy Shores Airfield Lot",
    kind = "parking",
    coords = vector3(1725.8, 3294.6, 41.2),
    tags = { "parking.free", "blaines" },
    blip = { sprite = 357, color = 18, name = "Parking" },
  },

  park_paleto_main = {
    label = "Paleto Bay Public Parking",
    kind = "parking",
    coords = vector3(-178.4, 6264.8, 31.5),
    tags = { "parking.free", "paleto" },
    blip = { sprite = 357, color = 25, name = "Parking" },
  },
}
