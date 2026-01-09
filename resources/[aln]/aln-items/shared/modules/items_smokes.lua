ALN_ITEM_MODULES = ALN_ITEM_MODULES or {}

ALN_ITEM_MODULES['smokes'] = {
  cigarette = {
    label = "Cigarette",
    icon = "cigarette",
    domain = "consumable",
    stackable = true,
    maxStack = 20,
    buy = 10,
    sell = 2,
    tags = { "legal", "consumable", "src.shop.convenience" },
    effects = { stress = -6, thirst = 2 }, -- thirst penalty
    hooks = { stimulant = { kind="nicotine", durationSec=300, crash=false } },
  },

  cigar = {
    label = "Cigar",
    icon = "cigar",
    domain = "consumable",
    stackable = true,
    maxStack = 10,
    buy = 35,
    sell = 8,
    tags = { "legal", "consumable", "src.shop.convenience" },
    effects = { stress = -10, thirst = 3 },
    hooks = { stimulant = { kind="nicotine", durationSec=450, crash=false } },
  },

  lighter = {
    label = "Lighter",
    icon = "lighter",
    domain = "tool",
    stackable = false,
    buy = 15,
    sell = 3,
    tags = { "legal", "tool", "src.shop.convenience" },
    hooks = { ignition = true },
  },
}
