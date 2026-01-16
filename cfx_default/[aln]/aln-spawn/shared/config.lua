Config = Config or {}

Config.Spawn = {
  Debug = true,

  -- Default “new character start” (Sandy clinic)
  DefaultStart = {
    coords = vector3(1839.6, 3672.9, 34.3),
    heading = 0.0,
    locationId = 'svc_hospital_sandy', -- from aln-locations (if present)
  },

  -- Onboarding flow
  Onboarding = {
    Enabled = true,
    -- Step 1: pick a base model
    Models = {
      { key = 'male',   label = 'Male (Freemode)',   model = 'mp_m_freemode_01' },
      { key = 'female', label = 'Female (Freemode)', model = 'mp_f_freemode_01' },
      -- “Street” base model (simple start); can be swapped later in appearance editor
      { key = 'street', label = 'Street (Random Ped)', model = 'a_m_y_stbla_02' },
    },

    -- Step 2: pick a starter vehicle (your spec)
    StarterVehicles = {
      { key = 'faggio', label = 'Faggio', model = 'faggio' },
      { key = 'voodoo', label = 'Voodoo', model = 'voodoo' },
      { key = 'rebel',  label = 'Rebel',  model = 'rebel'  },
    },
  },

  -- Vehicle spawn behavior (client execution, server authoritative selection)
  VehicleSpawn = {
    OffsetForward = 6.0,
    OffsetRight = 2.0,
    SafeRadius = 2.5,
  },
}
