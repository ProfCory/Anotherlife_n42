Config = {}

-- =========================
-- Corpse persistence / EMS
-- =========================
Config.CorpsePersistSeconds = 60

-- "Witness" means: a real player is within this radius when the NPC dies
Config.WitnessRadius = 65.0

-- If witnessed, chance EMS is "called" and NPC is revived instead of cleaned up
Config.WitnessCallEmsChance = 0.35

-- How long after death to revive if EMS is called (random range)
Config.EmsReviveDelayMinSeconds = 20
Config.EmsReviveDelayMaxSeconds = 45

-- If not revived, delete ped after persist timer
Config.DeleteCorpseOnTimeout = true

-- =========================
-- Weapon drop control
-- =========================
-- Prevent GTA from dropping the weapon pickup on death (recommended)
Config.DisableGtaWeaponPickups = true

-- Loot weapon rules:
-- If true: only allow weapon loot if the NPC was wielding a weapon at death
Config.WeaponLootOnlyIfWielded = true

-- Chance of a weapon being included in loot when eligible
Config.WeaponLootChance = 0.03

-- Police/gang flavor: what weapon classes are "expected"
-- (Used only for loot bias, not for giving NPC weapons)
Config.PoliceWeaponBias = { 'pistol', 'shotgun' }
Config.GangWeaponBias   = { 'pistol', 'smg', 'melee' }

-- =========================
-- Loot container behavior
-- =========================
-- This avoids qb-inventory fork mismatches by using a simple bag prop + "take all"
Config.UseWorldLootBag = true
Config.LootBagModel = `prop_cs_heist_bag_02`  -- small duffel
Config.LootBagDespawnSeconds = 180

-- Distance to interact if you don't have ox_target/qb-target
Config.LootInteractDistance = 2.0

-- =========================
-- Loot basics
-- =========================
-- Cash is handled as an item by default (qb-inventory often uses 'cash' as account; adjust below)
Config.CashMode = 'account'  -- 'account' or 'item'
Config.CashAccountName = 'cash'
Config.CashItemName = 'cash' -- if CashMode='item'

-- Item names must exist in your qb-core/shared/items.lua (or equivalent)
Config.AmmoItems = {
  pistol  = 'pistol_ammo',
  smg     = 'smg_ammo',
  rifle   = 'rifle_ammo',
  shotgun = 'shotgun_ammo',
}

Config.DrugItems = {
  'joint',
  'blunt',
  'shatter',
  'keef',
  'driedcannabis',
  'cannabutter',
  'leanblunts',
  'dextroblunts',

  'oxy',
  'cocaine_baggy',
  'crack_baggy',
  'xtc_baggy',
  'shrooms',
  'reddextro',
}

Config.GeneralLoot = {
  'bandage',
  'water_bottle',
  'sandwich',
  'phone',
  'lockpick',
}

-- Very small default quantities
Config.Qty = {
  ammoMin = 0,
  ammoMax = 2,

  drugMin = 0,
  drugMax = 2,

  lootMin = 0,
  lootMax = 2,
}

-- =========================
-- Ped profiles
-- =========================
-- We classify peds into one of: CIV / SHOP / DEALER / GANG / POLICE / HOSTILE
-- You can add model hashes here later for strong overrides.
Config.ModelProfiles = {
  -- [`g_m_y_mexgoon_01`] = 'GANG',
  -- [`s_m_m_paramedic_01`] = 'EMS',
}

-- Relationship groups used by GTA (common ones)
-- This is heuristic; you can tune it as you observe behavior.
Config.RelationshipProfiles = {
  ['COP'] = 'POLICE',
  ['SECURITY_GUARD'] = 'POLICE',
  ['ARMY'] = 'POLICE',

  ['AMBIENT_GANG_LOST'] = 'GANG',
  ['AMBIENT_GANG_MEXICAN'] = 'GANG',
  ['AMBIENT_GANG_FAMILY'] = 'GANG',
  ['AMBIENT_GANG_BALLAS'] = 'GANG',
  ['AMBIENT_GANG_MARABUNTE'] = 'GANG',
  ['AMBIENT_GANG_SALVA'] = 'GANG',
  ['AMBIENT_GANG_WEICHENG'] = 'GANG',

  ['DEALER'] = 'DEALER', -- if you set your dealers to this group
}

-- =========================
-- Loot tables (weighted “rolls”)
-- =========================
-- Each profile gets:
-- cash range, chance buckets for ammo/drugs/general loot, and weapon bias
Config.Tables = {
  CIV = {
    cashMin = 5, cashMax = 60,
    chanceAmmo = 0.02,
    chanceDrugs = 0.04,
    chanceLoot = 0.20,
    weaponBias = {},
  },
  SHOP = {
    cashMin = 60, cashMax = 220,
    chanceAmmo = 0.01,
    chanceDrugs = 0.03,
    chanceLoot = 0.55,  -- robbery target: valuables + misc
    weaponBias = {},
  },
  DEALER = {
    cashMin = 10, cashMax = 90,
    chanceAmmo = 0.08,
    chanceDrugs = 0.75,
    chanceLoot = 0.20,
    weaponBias = { 'pistol', 'smg' },
  },
  GANG = {
    cashMin = 20, cashMax = 160,
    chanceAmmo = 0.35,
    chanceDrugs = 0.28,
    chanceLoot = 0.22,
    weaponBias = Config.GangWeaponBias,
  },
  POLICE = {
    cashMin = 5, cashMax = 40,
    chanceAmmo = 0.45,
    chanceDrugs = 0.01,
    chanceLoot = 0.08,
    weaponBias = Config.PoliceWeaponBias,
  },
  HOSTILE = {
    cashMin = 10, cashMax = 140,
    chanceAmmo = 0.30,
    chanceDrugs = 0.15,
    chanceLoot = 0.18,
    weaponBias = { 'pistol', 'smg', 'rifle', 'melee' },
  },
}

-- =========================
-- BG3 dice integration (optional)
-- =========================
Config.BG3Dice = {
  enabled = false,
  -- If enabled, the server will request a single roll per NPC death.
  -- This is rate-limited to avoid gang-fight spam.
  maxRollsPerSecond = 4,
  -- If dice roll fails/timeouts, fallback to normal RNG.
  fallbackToRng = true,
}
