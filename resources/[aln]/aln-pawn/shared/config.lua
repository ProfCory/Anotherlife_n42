Config = Config or {}

Config.Pawn = {
  Debug = true,

  LocationTag = 'pawn',
  UseDist = 1.8,

  -- Where payout goes (cash only per your design)
  OutAccount = 'cash',

  -- Per-transaction caps
  MaxItemsPerSell = 10,
  MaxPayout = 50000,

  -- If true, require player to be near a pawn location
  RequireLocation = true,

  -- Price behavior
  -- FinalPrice = floor(BasePrice * ConditionMult * RandomBand)
  Condition = {
    Enabled = true,
    DefaultMult = 1.0,
    MinMult = 0.60,
    MaxMult = 1.10,
  },

  RandomBand = {
    Enabled = true,
    Min = 0.92,
    Max = 1.08,
  },
}
