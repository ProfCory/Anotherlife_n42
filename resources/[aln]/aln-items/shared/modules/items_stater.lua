return {
  cash = {
    label = "Cash",
    icon = "cash",
    domain = "currency",
    stackable = true,
    maxStack = 1000000,
    buy = nil, sell = nil,
    tags = { "not_for_sale" },
  },

  dirty_money = {
    label = "Dirty Money",
    icon = "dirty-money",
    domain = "currency",
    stackable = true,
    maxStack = 1000000,
    buy = nil,
    sell = 0,
    tags = { "illegal", "loot_only", "sink.launder", "src.loot.npc", "src.loot.crate" },
    hooks = { launderable = true },
  },

  phone_basic = {
    label = "Phone",
    icon = "phone",
    domain = "utility",
    stackable = false,
    buy = 250,
    sell = 50,
    tags = { "legal", "src.shop.convenience", "sink.shop.pawn" },
    hooks = { enables = { "gps", "service_calls" } },
  },

  notepad = {
    label = "Notepad",
    icon = "notepad",
    domain = "utility",
    stackable = false,
    buy = 25,
    sell = 5,
    tags = { "legal", "src.shop.convenience" },
  },

  binoculars = {
    label = "Binoculars",
    icon = "binoculars",
    domain = "utility",
    stackable = false,
    buy = 180,
    sell = 60,
    tags = { "legal", "src.shop.convenience", "sink.shop.pawn" },
  },
}
