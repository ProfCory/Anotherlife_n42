Config = Config or {}

Config.Carjack = {
  Debug = true,

  -- Treat all non-player vehicles as locked when parked
  LockParkedVehicles = true,

  -- Interaction distance
  UseDist = 2.0,

  -- Hotwire required for stolen cars (engine disabled until success)
  RequireHotwire = true,

  -- Basic AI behavior (later you can expand: threatened driver flee/drive off)
  DriverThreat = {
    Enabled = false, -- v0 off to avoid creep
  },
}
