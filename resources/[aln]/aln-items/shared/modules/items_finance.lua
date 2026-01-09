ALN_ITEM_MODULES = ALN_ITEM_MODULES or {}

ALN_ITEM_MODULES['finance'] = {
  atm_card = {
    label = "ATM Card",
    icon = "bank-card", -- if missing, change to "credit-card" or "cash" temporarily
    domain = "utility",
    stackable = false,
    buy = 100,
    sell = 10,
    tags = { "legal", "src.shop.bank", "src.shop.convenience" },
    hooks = { finance = { atm = true } },
  },

  check = {
    label = "Check",
    icon = "check",
    domain = "utility",
    stackable = true,
    maxStack = 25,
    buy = nil,
    sell = 0,
    tags = { "not_for_sale", "sink.check_cash" },
    hooks = { finance = { check = true } },
  },

  money_order = {
    label = "Money Order",
    icon = "money-order",
    domain = "utility",
    stackable = true,
    maxStack = 10,
    buy = nil,
    sell = 0,
    tags = { "not_for_sale" },
    hooks = { finance = { moneyOrder = true } },
  },
}
