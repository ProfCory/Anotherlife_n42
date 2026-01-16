Config = Config or {}

Config.Launder = {
  Debug = true,

  -- Uses locations tagged as launder points
  LocationTag = 'launder',

  UseDist = 1.8,

  -- Core economics
  -- CleanOut = floor(dirtyIn * PayoutRate) - FlatFee
  -- Then optionally apply PercentFee on cleanOut.
  PayoutRate = 0.70,     -- 70% return
  FlatFee = 50,          -- minimum operational fee
  PercentFee = 0.02,     -- 2% of cleanOut

  MinDirtyIn = 100,
  MaxDirtyIn = 50000,

  CooldownSeconds = 60,

  -- Where clean goes
  -- 'cash' recommended early; bank allowed if you want “check cashing” vibe.
  DefaultOutAccount = 'cash',
  AllowOutAccounts = { cash = true, bank = true },

  -- If true, require player to be at a launder point (tagged location)
  RequireLocation = true,
}
