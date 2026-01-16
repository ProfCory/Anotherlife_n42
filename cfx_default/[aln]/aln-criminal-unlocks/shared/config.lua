Config = Config or {}
Config.CriminalUnlocks = Config.CriminalUnlocks or {}

-- Stable unlock keys. Never rename—only add.
Config.CriminalUnlocks.LevelGates = {
  -- examples (edit later)
  ['crime.start']        = 1,
  ['tools.lockpick']     = 1,
  ['tools.hotwire']      = 2,
  ['robbery.store']      = 3,
  ['hack.basic']         = 4,
  ['weapons.basic_pistol_access'] = 5, -- “access” only; actual granting handled elsewhere
  ['robbery.house']      = 6,
  ['hack.advanced']      = 8,
}
