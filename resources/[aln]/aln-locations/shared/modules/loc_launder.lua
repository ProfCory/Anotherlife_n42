ALN_LOCATION_MODULES = ALN_LOCATION_MODULES or {}

ALN_LOCATION_MODULES['launder'] = {
  -- 1) Hands On Car Wash (Strawberry area)
  launder_hands_on_car_wash = {
    label = "Hands On Car Wash",
    kind = "business_front",
    coords = vector3(25.2, -1392.7, 29.3), -- sidewalk/entry area
    tags = { "launder", "city", "front.carwash" },
    clusterKey = "launder_city_1",
    blip = { sprite = 500, color = 25, name = "Launder" }, -- sprite optional
    interact = { radius = 1.8 },
  },

  -- 2) Watersports (Vespucci Beach)
  launder_watersports = {
    label = "Watersports",
    kind = "business_front",
    coords = vector3(-1496.6, -1472.0, 4.4), -- near storefront
    tags = { "launder", "city", "front.watersports" },
    clusterKey = "launder_beach",
    blip = { sprite = 500, color = 25, name = "Launder" },
    interact = { radius = 1.8 },
  },

  -- 3) The Hen House (Paleto Bay strip club)
  launder_hen_house = {
    label = "The Hen House",
    kind = "business_front",
    coords = vector3(-303.9, 6265.0, 31.5), -- outside entrance
    tags = { "launder", "paleto", "front.stripclub" },
    clusterKey = "launder_paleto",
    blip = { sprite = 500, color = 25, name = "Launder" },
    interact = { radius = 1.8 },
  },

  -- 4) Sandy check-cashing style box (the one from earlier)
  launder_sandy_check_cash = {
    label = "Check Cashing (Sandy Shores)",
    kind = "business_front",
    coords = vector3(1736.2, 3709.6, 34.1),
    tags = { "launder", "blaines", "front.checkcash" },
    clusterKey = "launder_sandy",
    blip = { sprite = 500, color = 25, name = "Launder" },
    interact = { radius = 1.8 },
  },
}
