return {
  jerry_can = {
    label = "Jerry Can",
    icon = "jerry-can",
    domain = "vehicle",
    stackable = false,
    buy = 60,
    sell = 15,
    tags = { "legal", "vehicle_service", "src.shop.gas", "sink.shop.pawn" },
    hooks = { container = { kind="fuel", capacity=20 } },
  },

  repair_basic = {
    label = "Basic Repair Kit",
    icon = "basic-repair",
    domain = "vehicle",
    stackable = true,
    maxStack = 5,
    buy = 180,
    sell = 50,
    tags = { "legal", "vehicle_service", "src.shop.mechanic" },
    hooks = { vehicleRepair = { tier="basic", engine=150.0, body=100.0 } },
  },

  repair_advanced = {
    label = "Advanced Repair Kit",
    icon = "advanced-repair",
    domain = "vehicle",
    stackable = true,
    maxStack = 3,
    buy = 450,
    sell = 140,
    tags = { "legal", "vehicle_service", "src.shop.mechanic" },
    hooks = { vehicleRepair = { tier="adv", engine=350.0, body=250.0 } },
  },
}
