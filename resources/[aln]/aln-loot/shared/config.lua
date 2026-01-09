Config = Config or {}

Config.Loot = {
  Debug = true,
  StrictValidation = true,

  -- If true, validate that every referenced item key exists in aln-items registry.
  ValidateItems = true,

  -- Hard cap to avoid accidental “drop 500 items” configs.
  MaxResultsPerRoll = 10,
}
