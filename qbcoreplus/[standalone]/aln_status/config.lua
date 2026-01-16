-- aln_status/config.lua (FULL REPLACEMENT)

Config = {}

-- =========================================================
-- Core status keys (metadata keys)
-- =========================================================
Config.StatusKeys = {
  fatigue   = 'fatigue',
  drunk     = 'drunk',
  stoned    = 'stoned',
  tripping  = 'tripping',
  drugged   = 'drugged',
}

Config.DefaultValue = 0
Config.MinValue = 0
Config.MaxValue = 100

-- =========================================================
-- UI
-- =========================================================
Config.UI = {
  Enabled = true,

  -- Default position (upper-right-ish). Stored per-player once moved.
  DefaultPos = { x = 0.86, y = 0.08 }, -- normalized 0..1

  -- Show icon when value >= threshold (UI may not render all keys; safe)
  ShowThresholds = {
    fatigue  = 15,
    drunk    = 10,
    stoned   = 10,
    tripping = 10,
    drugged  = 10,
  },

  Severity = {
    warn = 50,
    danger = 75,
  }
}

Config.MoveCommand = 'statusui'

-- =========================================================
-- Ticking / decay / gains
-- =========================================================
Config.TickSeconds = 30

Config.Fatigue = {
  BaseGainPerTick = 0.15,
  SprintExtraPerTick = 0.25,
  InjuryExtraPerTick = 0.35,
  InjuryThreshold = 20,
  NaturalDecayPerTick = 0.10,
  VehicleIdleMultiplier = 0.60,
}

Config.Drunk = {
  DecayPerTick = 0.60
}

Config.Stoned = {
  DecayPerTick = 0.45
}

Config.Tripping = {
  -- Quick spike but fades clean
  DecayPerTick = 0.85,

  EnableTimecycle = true,
  Timecycle = 'drug_drive_blend01',
  StartsAt = 25,

  EnableCameraShake = true,
  ShakeMin = 0.03,
  ShakeMax = 0.20,
  ShakeStartsAt = 35,
}

Config.Drugged = {
  -- Meth/crack/coke: strong spike + fades; health cost; cravings
  DecayPerTick = 0.55,

  -- Health drain scaling
  HealthDrainStartsAt = 40,       -- starts hurting above this
  MaxHealthDrainPerTick = 6,       -- per tick at 100%
  HealthFloor = 120,              -- never kill outright (keeps them limping)

  -- Cravings
  CravingStartsAt = 20,
  CravingInterval = 90,           -- seconds between messages

  CravingMessages = {
    "Your hands feel restless… you could really use a hit.",
    "Your heart’s racing. One more would smooth this out.",
    "Your thoughts keep circling back to getting high.",
    "You feel on edge. Everything would be better with another dose.",
    "Your jaw clenches. You want more. Badly.",
  },

  -- Optional mild camera shake
  EnableCameraShake = true,
  ShakeMin = 0.03,
  ShakeMax = 0.22,
  ShakeStartsAt = 45,
}

-- =========================================================
-- Pass-out rules
-- =========================================================
Config.PassOut = {
  Enabled = true,
  TriggerAt = 100,

  DurationSeconds = 30,

  WakeToValue = 60,
  ReduceOthersBy = 20,

  NudgeDistance = 6.0,
}

-- =========================================================
-- Effects (lightweight but noticeable)
-- =========================================================
Config.Effects = {
  Fatigue = {
    EnableCameraShake = true,
    ShakeMin = 0.05,
    ShakeMax = 0.22,
    ShakeStartsAt = 60,

    StaminaPenaltyStartsAt = 60,
    StaminaPenaltyMax = 0.35,
  },

  Drunk = {
    EnableCameraShake = true,
    ShakeMin = 0.04,
    ShakeMax = 0.25,
    ShakeStartsAt = 40,

    StumbleStartsAt = 80,
    StumbleChancePerTick = 0.08,
  },

  Stoned = {
    EnableTimecycle = true,
    Timecycle = 'spectator5',
    StartsAt = 50,
  },
}

-- =========================================================
-- Public events for other scripts
-- =========================================================
Config.Events = {
  Add   = 'aln_status:client:Add',
  Set   = 'aln_status:client:Set',
  Sleep = 'aln_status:client:Sleep',
}
