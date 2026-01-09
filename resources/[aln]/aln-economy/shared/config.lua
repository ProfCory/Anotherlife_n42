Config = Config or {}

Config.Economy = {
  Debug = true,

  -- Phase 1 mode (until persistent-data exists):
  -- balances live in memory keyed by playerKey/characterKey.
  InMemoryMode = true,

  -- Default starting balances for new identities (test-friendly)
  Defaults = {
    cash = 500,
    bank = 1000,
    dirty = 5000,
  },

  -- Hard caps (anti-bug)
  Caps = {
    cash = 100000000,
    bank = 1000000000,
    dirty = 100000000,
  },

  -- Whether to allow negative balances (generally no)
  AllowNegative = {
    cash = false,
    bank = false,
    dirty = false,
  },
}
