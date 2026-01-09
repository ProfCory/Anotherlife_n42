PawnPrices = PawnPrices or {}

PawnPrices = {
  -- Generic loot item with variants (meta.variant)
  loot_valuable = {
    base = 120,
    variants = {
      ring      = 90,
      necklace  = 140,
      rolex     = 320,
      diamond   = 600,
      art_mona  = 1200,
    }
  },

  -- Common resale items
  phone_basic = { base = 60 },
  phone_smart = { base = 180 },

  jewelry_box = { base = 220 },
  watch = { base = 90 },

  -- Junk / scrap
  scrap_metal = { base = 25 },
  copper_wire = { base = 45 },
  electronics_scrap = { base = 55 },

  -- Tools (optional – you can disable by removing entries)
  wrench = { base = 35 },
  lockpick = { base = 30 },
}
