-- aln_hostilezones/shared/config.lua
-- Standalone hostile zones & escalation framework (solo / PVE-first)
-- Owns: zones, factions, tiers, bosses, vehicles, interiors (hooks only)
-- Does NOT own: inventory, keys, HUD, drops, wanted

Config = {}

-- ======================================================
-- GLOBAL
-- ======================================================
Config.Debug = true
Config.UseServerAuthority = true

-- Optional integrations (pure adapters listen to our events)
Config.Integrations = {
  K4mb1Startershells = {
    enabled = true,
    resourceName = "k4mb1-startershells",
  },
  AlnDrops = {
    enabled = true,
    resourceName = "aln_drops",
  }
}

-- ======================================================
-- TIME MODEL (night bias)
-- ======================================================
Config.Time = {
  NightStartHour = 21,
  NightEndHour   = 5,

  Night = {
    heatGainMult      = 1.15,
    skirmishChanceMult= 2.25,
    spawnBudgetMult   = 1.25,
  },

  Day = {
    heatGainMult      = 0.95,
    skirmishChanceMult= 0.60,
    spawnBudgetMult   = 0.90,
  }
}

-- ======================================================
-- HEAT → TIER
-- ======================================================
Config.Heat = {
  MaxHeat = 100,
  DecayPerSecond = 0.06,

  IncidentWeights = {
    gunshot        = 6,
    hit            = 3,
    kill           = 14,
    explosion      = 18,
    vehicleRamming = 6,
    aimingThreat   = 2,
    opsLingering   = 3,
  }
}

Config.Tiers = {
  HeatToTierDelta = {
    { min=0,  max=19,  add=0 },
    { min=20, max=39,  add=1 },
    { min=40, max=59,  add=2 },
    { min=60, max=79,  add=3 },
    { min=80, max=100, add=4 },
  },

  Budgets = {
    [0] = { maxAlive=0,  waveSize=0,  waveCooldownSec=0 },
    [1] = { maxAlive=3,  waveSize=2,  waveCooldownSec=90 },
    [2] = { maxAlive=6,  waveSize=3,  waveCooldownSec=70 },
    [3] = { maxAlive=10, waveSize=5,  waveCooldownSec=55 },
    [4] = { maxAlive=14, waveSize=6,  waveCooldownSec=45 },
    [5] = { maxAlive=18, waveSize=8,  waveCooldownSec=35 },
  }
}

-- ======================================================
-- BOSSES
-- ======================================================
Config.Bosses = {
  callBackupAfterSeconds = 30,
  backupCooldownSeconds = 90,

  armorMultiplier = 1.75,
  accuracyBonus   = 1.15,

  blip = {
    sprite = 303,
    color  = 1,
    scale  = 0.9,
    label  = "Gang Leader",
  },

  reinforcement = {
    waveMultiplier = 1.5,
  },

  vehicle = {
    enabled = true,
    chance = 0.65,
    spawnRadius = 10.0,
    useAsCover = true,

    modelsByFaction = {
      ballas   = { "baller", "schafter2", "sultan" },
      vagos    = { "buccaneer", "chino", "tornado" },
      lost     = { "daemon", "bagger", "hexer" },
      locals   = { "rebel", "bfinjection", "dloader" },
      ops      = { "fbi", "fbi2" },
      police   = { "police", "police2", "sheriff" },
      military = { "crusader", "barracks", "mesa3" },
    }
  }
}

-- ======================================================
-- VEHICLE RIGGING (CAR BOMBS)
-- ======================================================
Config.VehicleRigging = {
  enabled = true,
  baseRigChance = 0.10,

  factionRigChanceBonus = {
    lost     = 0.35,
    locals   = 0.12,
    ballas   = 0.08,
    vagos    = 0.08,
    ops      = 0.05,
    police   = 0.00,
    military = 0.00,
  },

  armDelaySeconds      = 2.5,
  detonateAfterSeconds= 4.0,
  warningBeep         = true,
}

-- ======================================================
-- CAPABILITY LADDERS
-- ======================================================
Config.Capabilities = {
  ArmorByTier = {
    [0]=0,[1]=0,[2]=25,[3]=50,[4]=80,[5]=120
  },

  ThrowablesByTier = {
    [0]={},
    [1]={},
    [2]={ "WEAPON_MOLOTOV" },
    [3]={ "WEAPON_MOLOTOV" },
    [4]={ "WEAPON_MOLOTOV", "WEAPON_GRENADE" },
    [5]={ "WEAPON_GRENADE", "WEAPON_STICKYBOMB" },
  },

  DefaultWeaponTiers = {
    [0]={ "WEAPON_UNARMED" },
    [1]={ "WEAPON_KNIFE", "WEAPON_BAT", "WEAPON_PISTOL" },
    [2]={ "WEAPON_PISTOL", "WEAPON_COMBATPISTOL" },
    [3]={ "WEAPON_SMG", "WEAPON_MICROSMG" },
    [4]={ "WEAPON_ASSAULTRIFLE", "WEAPON_CARBINERIFLE" },
    [5]={ "WEAPON_CARBINERIFLE", "WEAPON_SPECIALCARBINE" },
  }
}

-- ======================================================
-- FACTIONS (ENVIRONMENTAL ONLY)
-- ======================================================
Config.Factions = {
  ballas = {
    label="Ballas",
    relationshipGroup="ALN_BALLAS",
    pedModels={ "g_m_y_ballaorig_01","g_m_y_ballasout_01","g_m_y_ballaeast_01" },
    weaponTiers=Config.Capabilities.DefaultWeaponTiers,
    armorByTier=Config.Capabilities.ArmorByTier,
    throwablesByTier=Config.Capabilities.ThrowablesByTier,
    behavior={ aggression=1.0, accuracy=0.65 }
  },

  vagos = {
    label="Vagos",
    relationshipGroup="ALN_VAGOS",
    pedModels={ "g_m_y_mexgoon_01","g_m_y_mexgoon_02","g_m_y_mexgoon_03" },
    weaponTiers=Config.Capabilities.DefaultWeaponTiers,
    armorByTier=Config.Capabilities.ArmorByTier,
    throwablesByTier=Config.Capabilities.ThrowablesByTier,
    behavior={ aggression=1.05, accuracy=0.66 }
  },

  lost = {
    label="The Lost",
    relationshipGroup="ALN_LOST",
    pedModels={ "g_m_y_lost_01","g_m_y_lost_02","g_m_y_lost_03" },
    weaponTiers={
      [1]={ "WEAPON_SAWNOFFSHOTGUN","WEAPON_PISTOL" },
      [3]={ "WEAPON_PUMPSHOTGUN","WEAPON_SMG" },
      [5]={ "WEAPON_ASSAULTRIFLE" },
    },
    armorByTier=Config.Capabilities.ArmorByTier,
    throwablesByTier=Config.Capabilities.ThrowablesByTier,
    behavior={ aggression=1.15, accuracy=0.62 }
  },

  locals = {
    label="Locals",
    relationshipGroup="ALN_LOCALS",
    pedModels={ "a_m_m_hillbilly_01","a_m_m_farmer_01","a_m_m_beach_01" },
    weaponTiers=Config.Capabilities.DefaultWeaponTiers,
    armorByTier=Config.Capabilities.ArmorByTier,
    throwablesByTier=Config.Capabilities.ThrowablesByTier,
    behavior={ aggression=0.95, accuracy=0.55 }
  },

  police = {
    label="Police",
    relationshipGroup="ALN_POLICE",
    pedModels={ "s_m_y_cop_01","s_m_y_sheriff_01" },
    weaponTiers={
      [1]={ "WEAPON_PISTOL" },
      [3]={ "WEAPON_PUMPSHOTGUN","WEAPON_CARBINERIFLE" },
      [5]={ "WEAPON_SPECIALCARBINE" },
    },
    armorByTier={ [1]=25,[2]=50,[3]=80,[4]=120,[5]=160 },
    throwablesByTier={ [3]={ "WEAPON_SMOKEGRENADE" } },
    behavior={ aggression=1.0, accuracy=0.72 }
  },

  ops = {
    label="IAA/FIB",
    relationshipGroup="ALN_OPS",
    pedModels={ "s_m_m_fiboffice_01","s_m_m_ciasec_01" },
    weaponTiers=Config.Capabilities.DefaultWeaponTiers,
    armorByTier={ [1]=25,[3]=100,[5]=200 },
    throwablesByTier={ [4]={ "WEAPON_SMOKEGRENADE" } },
    behavior={ aggression=1.1, accuracy=0.78 }
  },

  military = {
    label="Military",
    relationshipGroup="ALN_MIL",
    pedModels={ "s_m_y_marine_01","s_m_y_marine_02" },
    weaponTiers={
      [3]={ "WEAPON_SPECIALCARBINE" },
      [5]={ "WEAPON_COMBATMG","WEAPON_HEAVYSNIPER" },
    },
    armorByTier={ [3]=200,[5]=360 },
    throwablesByTier={ [3]={ "WEAPON_GRENADE" },[5]={ "WEAPON_STICKYBOMB" } },
    behavior={ aggression=1.25, accuracy=0.85 }
  }
}

-- Rivalries for overlap skirmishes
Config.Rivalries = {
  { "ballas","vagos" },
  { "lost","locals" },
  { "ballas","lost" },
}

-- ======================================================
-- CLEARING & COOLDOWN
-- ======================================================
Config.Clearing = {
  bossRequired = true,
  holdSeconds  = 90,
  cooldownInGameHours = 24,
}

-- ======================================================
-- BLIPS (MINIMAL UI)
-- ======================================================
Config.Blips = {
  enabled = true,
  showNearDistance = 250.0,
  requireGPS = true,
}

-- ======================================================
-- INTERIORS (SHELL DEFINITIONS ONLY)
-- ======================================================
Config.Interiors = {
  enabled = true,

  shells = {
    michael   = { model="shell_michael", label="Michael House" },
    trevor    = { model="shell_trevor", label="Trevor House" },
    trailer   = { model="shell_trailer", label="Trailer" },
    store1    = { model="shell_store1", label="Store" },
    office1   = { model="shell_office1", label="Office" },
    motel     = { model="standardmotel_shell", label="Motel" },
    warehouse = { model="shell_warehouse1", label="Warehouse" },
    modern    = { model="k4mb1_modern_shell", label="Modern" },
    apartment = { model="k4mb1_apartment_shell", label="Apartment" },
  }
}

-- ======================================================
-- ZONES (EXAMPLES – CLONE THESE)
-- ======================================================
Config.Zones = {
  grove_st_gang = {
    label="Grove Street Heat",
    center=vec3(110.0,-1940.0,20.0),
    radius=260.0,
    baseTier=2,
    maxTier=5,

    factionsWeighted={
      {id="ballas",weight=60},
      {id="vagos", weight=40},
    },

    cores={
      {
        label="Courtyard Core",
        center=vec3(85.0,-1955.0,20.0),
        radius=85.0,
        bossSlots=1,
      },
      {
        label="Back Alley Core",
        center=vec3(140.0,-1920.0,20.0),
        radius=70.0,
        bossSlots=2,
      }
    },

    interiors={
      { shellId="apartment", tierRequired=3, chance=0.20 },
      { shellId="office1",   tierRequired=4, chance=0.12 },
    }
  },

  lost_desert = {
    label="Lost Desert Pocket",
    center=vec3(1985.0,3050.0,47.0),
    radius=260.0,
    baseTier=2,
    maxTier=5,

    factionsWeighted={ {id="lost",weight=100} },

    cores={
      {
        label="Clubhouse Core",
        center=vec3(1985.0,3050.0,47.0),
        radius=85.0,
        bossSlots=2,
      }
    },

    interiors={
      { shellId="trailer", tierRequired=3, chance=0.22 },
      { shellId="motel",   tierRequired=2, chance=0.12 },
    }
  }
}

-- ======================================================
-- SKIRMISHES (AI vs AI)
-- ======================================================
Config.Skirmishes = {
  enabled = true,
  baseChancePerMinuteNight = 0.22,
  baseChancePerMinuteDay   = 0.06,
  groupSize = { min=2, max=5 },
}

return Config
