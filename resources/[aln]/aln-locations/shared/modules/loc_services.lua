ALN_LOCATION_MODULES = ALN_LOCATION_MODULES or {}

ALN_LOCATION_MODULES['services'] = {
  -- Hospitals / clinics (walkable entrances)
  svc_hospital_pillbox = {
    label = "Pillbox Hill Medical",
    kind = "service",
    coords = vector3(307.8, -1433.4, 29.9),
    tags = { "service.medical", "city" },
    blip = { sprite = 61, color = 2, name = "Hospital" },
  },

  svc_hospital_mount_zonah = {
    label = "Mount Zonah Medical",
    kind = "service",
    coords = vector3(-449.7, -340.3, 34.5),
    tags = { "service.medical", "city" },
    blip = { sprite = 61, color = 2, name = "Hospital" },
  },

  svc_hospital_sandy = {
    label = "Sandy Shores Medical Center",
    kind = "service",
    coords = vector3(1839.6, 3672.9, 34.3),
    tags = { "service.medical", "blaines" },
    blip = { sprite = 61, color = 2, name = "Clinic" },
  },

  svc_hospital_paleto = {
    label = "Paleto Bay Medical",
    kind = "service",
    coords = vector3(-247.2, 6331.1, 32.4),
    tags = { "service.medical", "paleto" },
    blip = { sprite = 61, color = 2, name = "Clinic" },
  },

  -- Police / sheriff stations
  svc_police_missionrow = {
    label = "Mission Row Police Station",
    kind = "service",
    coords = vector3(425.1, -979.5, 30.7),
    tags = { "service.police", "city" },
    blip = { sprite = 60, color = 29, name = "Police" },
  },

  svc_sheriff_sandy = {
    label = "Blaine County Sheriff (Sandy)",
    kind = "service",
    coords = vector3(1853.2, 3686.5, 34.3),
    tags = { "service.police", "blaines" },
    blip = { sprite = 60, color = 29, name = "Sheriff" },
  },

  svc_sheriff_paleto = {
    label = "Blaine County Sheriff (Paleto)",
    kind = "service",
    coords = vector3(-446.1, 6012.3, 31.7),
    tags = { "service.police", "paleto" },
    blip = { sprite = 60, color = 29, name = "Sheriff" },
  },

  -- Fire stations
  svc_fire_davis = {
    label = "Fire Station (Davis)",
    kind = "service",
    coords = vector3(205.9, -1651.3, 29.8),
    tags = { "service.fire", "city" },
    blip = { sprite = 436, color = 1, name = "Fire Dept" },
  },

  svc_fire_sandy = {
    label = "Fire Station (Sandy Shores)",
    kind = "service",
    coords = vector3(1693.7, 3585.9, 35.6),
    tags = { "service.fire", "blaines" },
    blip = { sprite = 436, color = 1, name = "Fire Dept" },
  },

  svc_fire_paleto = {
    label = "Fire Station (Paleto Bay)",
    kind = "service",
    coords = vector3(-379.9, 6118.4, 31.9),
    tags = { "service.fire", "paleto" },
    blip = { sprite = 436, color = 1, name = "Fire Dept" },
  },
}
