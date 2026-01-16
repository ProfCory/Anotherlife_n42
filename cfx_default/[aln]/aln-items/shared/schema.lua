ALN = ALN or {}
ALN.Items = ALN.Items or {}

-- Purely documentation + light validation target.
ALN.Items.Schema = {
  required = { 'label', 'icon', 'domain' },
  domains = {
    currency = true,
    utility = true,
    consumable = true,
    medical = true,
    tool = true,
    vehicle = true,
    loot = true,

    -- virtual only
    weapon = true,
    ammo = true,
  }
}
