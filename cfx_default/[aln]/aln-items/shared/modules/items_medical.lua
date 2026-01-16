return {
  bandage = {
    label = "Bandage",
    icon = "bandages",
    domain = "medical",
    stackable = true,
    maxStack = 10,
    buy = 25,
    sell = 6,
    tags = { "legal", "medical", "consumable", "src.shop.pharmacy", "sink.service.ems" },
    hooks = { heal = { amount = 12, seconds = 4 } },
  },

  firstaid_kit = {
    label = "First Aid Kit",
    icon = "firstaid-kit",
    domain = "medical",
    stackable = true,
    maxStack = 5,
    buy = 120,
    sell = 30,
    tags = { "legal", "medical", "src.shop.pharmacy", "sink.service.ems" },
    hooks = { heal = { amount = 45, seconds = 6 } },
  },

  vicodin = {
    label = "Painkillers",
    icon = "vicodin",
    domain = "medical",
    stackable = true,
    maxStack = 10,
    buy = 80,
    sell = 20,
    tags = { "legal", "medical", "src.shop.pharmacy" },
    hooks = { buff = { kind="pain", durationSec=300 } },
  },
}
