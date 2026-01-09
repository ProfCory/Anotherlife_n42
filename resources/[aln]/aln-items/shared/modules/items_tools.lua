return {
  lockpick = {
    label = "Lockpick",
    icon = "lockpick",
    domain = "tool",
    stackable = true,
    maxStack = 10,
    buy = 80,
    sell = 20,
    tags = { "illegal", "tool", "src.shop.pawn", "src.shop.blackmarket" },
    hooks = { tool = { kind="lockpick", tier="basic", durability=1.0 } },
  },

  lockpick_adv = {
    label = "Advanced Lockpick",
    icon = "lockpick",
    domain = "tool",
    stackable = true,
    maxStack = 10,
    buy = 250,
    sell = 80,
    tags = { "illegal", "tool", "src.shop.pawn", "src.shop.blackmarket" },
    hooks = { tool = { kind="lockpick", tier="adv", durability=1.0 } },
  },

  screwdriver = {
    label = "Screwdriver",
    icon = "pliers",
    domain = "tool",
    stackable = false,
    buy = 35,
    sell = 10,
    tags = { "legal", "tool", "src.shop.hardware", "src.shop.convenience" },
    hooks = { tool = { kind="hotwire", tier="basic" } },
  },

  wrench = {
    label = "Wrench",
    icon = "wrench",
    domain = "tool",
    stackable = false,
    buy = 55,
    sell = 15,
    tags = { "legal", "tool", "src.shop.hardware", "sink.shop.pawn" },
  },

  rope = {
    label = "Rope",
    icon = "rope",
    domain = "tool",
    stackable = true,
    maxStack = 5,
    buy = 20,
    sell = 5,
    tags = { "legal", "tool", "src.shop.hardware" },
  },

  ziptie = {
    label = "Zip Tie",
    icon = "ziptie",
    domain = "tool",
    stackable = true,
    maxStack = 10,
    buy = 15,
    sell = 3,
    tags = { "legal", "tool", "src.shop.hardware" },
    hooks = { restraint = { kind="zip" } },
  },
}
