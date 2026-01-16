Config = Config or {}

Config.Persistent = {
  Debug = true,

  Slots = 3,

  -- Migration table unique to this resource (keeps additive rules clean)
  MigrationTable = 'aln3_migrations_persistent',

  -- Default data (used when creating a new character slot)
  Defaults = {
    model = 'mp_m_freemode_01', -- can be swapped during spawn/appearance
    money = { cash = 500, bank = 1000, dirty = 5000 },
    position = { x = 1839.6, y = 3672.9, z = 34.3, h = 0.0 }, -- Sandy clinic area default
  },
}
