Config = {}

-- =========================================================
-- Payments
-- =========================================================
Config.PayAccount = 'cash'
Config.MotelPrice = 125
Config.CoffeePrice = 15

-- =========================================================
-- Sleep timing (seconds, capped at 30)
-- =========================================================
Config.SleepDurations = {
  home    = 15,
  motel   = 20,
  crash   = 20,
  vehicle = 30,
}

-- =========================================================
-- Sleep cycles required to fully restore fatigue
-- =========================================================
Config.SleepCyclesNeeded = {
  home    = 1,
  motel   = 2,
  crash   = 2,
  vehicle = 3,
}

-- =========================================================
-- Coffee effect
-- =========================================================
Config.Coffee = {
  FatigueReduction = 20,
}

-- =========================================================
-- Vehicle sleep risk
-- =========================================================
Config.VehicleSleep = {
  CopChance = 0.06, -- 6% chance per sleep
  WantedLevel = 1,
}

-- =========================================================
-- Target distance
-- =========================================================
Config.TargetDistance = 2.0

-- =========================================================
-- Motel locations
-- =========================================================
Config.Motels = {
  { name = "Pink Cage Motel", coords = vec4(324.3, -201.0, 54.1, 160.0) },
  { name = "Sandy Shores Motel", coords = vec4(1141.6, 2664.9, 38.1, 0.0) },
}

-- =========================================================
-- Coffee spots
-- =========================================================
Config.CoffeeSpots = {
  { name = "Downtown Coffee", coords = vec4(235.0, -853.3, 30.3, 340.0) },
  { name = "Sandy Coffee", coords = vec4(1982.6, 3053.7, 47.2, 330.0) },
}
