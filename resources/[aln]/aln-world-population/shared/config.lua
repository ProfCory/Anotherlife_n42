Config = Config or {}

Config.WorldPop = {
  Debug = true,

  -- Master toggles
  Enabled = true,
  ManageDensities = true,
  ManageScenarios = true,
  ManageDispatch = true,

  -- DENSITY MULTIPLIERS (0.0 to 1.0+)
  -- These apply every frame (owner pattern).
  Density = {
    -- Peds
    Ped = 0.65,
    ScenarioPed = 0.55,

    -- Vehicles
    Vehicle = 0.70,
    ParkedVehicle = 0.70,

    -- Random cops/ambient
    RandomVehicle = 0.70,
  },

  -- If you want harsher world: raise gangs elsewhere; here we just manage population.
  -- Optional "near player cap" (reduces clutter right on top of the player).
  NearPlayer = {
    Enabled = true,
    Radius = 80.0,
    PedMultiplier = 0.85,
    VehicleMultiplier = 0.90,
  },

  -- SCENARIOS: disable noisy/annoying stuff, keep city alive.
  -- NOTE: scenario group/type strings are Rockstar-defined.
  Scenarios = {
    DisableGroups = {
      -- common offenders; safe to adjust/remove
      'AMBIENT_GANG_LOST',
      'AMBIENT_GANG_BALLAS',
      'AMBIENT_GANG_FAMILY',
      'AMBIENT_GANG_MEXICAN',
      'AMBIENT_GANG_MARABUNTE',
      'AMBIENT_GANG_SALVA',
      'GANG_1',
      'GANG_2',
      'GANG_9',
      'DEALERS',
      'DRUGS',
    },

    DisableTypes = {
      -- examples; keep list small to avoid breaking ambience
      'WORLD_VEHICLE_POLICE_CAR',
      'WORLD_VEHICLE_AMBULANCE',
      'WORLD_VEHICLE_FIRE_TRUCK',
      'WORLD_VEHICLE_MILITARY_PLANES_SMALL',
      'WORLD_VEHICLE_MILITARY_PLANES_BIG',
    },
  },

  -- DISPATCH: keep services callable via aln-services; reduce random ambient spam here.
  Dispatch = {
    -- Set to false to disable ambient dispatch services entirely
    EnableAmbientDispatch = false,

    -- Per-service toggle (index 1..15). If unknown, leave it and just disable ambient globally.
    -- We'll apply only if EnableAmbientDispatch==false by disabling all.
    DisableAllIfAmbientOff = true,
  },
}
