Config = Config or {}

Config.Items = {
  Debug = true,

  -- Registry validation:
  -- error on duplicate keys, missing fields, invalid stacking, etc.
  StrictValidation = true,

  -- Icon URL format for NUI:
  -- UI should use exports['aln-items']:IconUrl(iconId)
  IconUrlFormat = 'nui://aln-items/icons/%s.png',
}
