return {
  loot_valuable = {
    label = "Valuable",
    icon = "diamond",
    domain = "loot",
    stackable = true,
    maxStack = 25,
    buy = nil,
    sell = 0,
    tags = { "loot_only", "sink.shop.pawn", "src.loot.npc", "src.loot.crate" },
    hooks = { pawnable = true, variantBased = true },
    variants = {
      diamond       = { label="Diamond",        icon="diamond",          baseSell=1200 },
      ring          = { label="Diamond Ring",   icon="diamond-ring",     baseSell=900 },
      necklace      = { label="Necklace",       icon="diamond-necklace", baseSell=1100 },
      rolex         = { label="Gold Rolex",     icon="gold-rolex",       baseSell=1500 },
      art_mona      = { label="Stolen Art",     icon="mona-lisa",        baseSell=2200 },
    }
  },

  scratch_ticket = {
    label = "Scratch Ticket",
    icon = "scratchy-ticket",
    domain = "loot",
    stackable = true,
    maxStack = 10,
    buy = 5,
    sell = 1,
    tags = { "legal", "src.shop.convenience", "sink.shop.pawn" },
    hooks = { gamble = { kind="scratch", min=0, max=250 } },
  },
}
