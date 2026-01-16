return {
  joint = {
    label = "Joint",
    icon = "joint",
    domain = "consumable",
    stackable = true,
    maxStack = 10,
    buy = 40,
    sell = 10,
    tags = { "illegal", "consumable", "src.shop.blackmarket", "src.loot.npc" },
    effects = { stress = -18, hunger = 6 },
    hooks = { drug = { kind="weed", durationSec=600 } },
  },

  benzo = {
    label = "Benzo",
    icon = "benzo",
    domain = "consumable",
    stackable = true,
    maxStack = 10,
    buy = 120,
    sell = 35,
    tags = { "illegal", "consumable", "src.shop.blackmarket", "src.loot.npc" },
    effects = { stress = -25 },
    hooks = { drug = { kind="benzo", durationSec=900 } },
  },
}
