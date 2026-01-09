Config = Config or {}

Config.Inventory = {
  Debug = true,

  -- Until aln-persistent-data is done, we will use memory store by default.
  -- When you flip this true, it uses DB tables below.
  UseDB = false,

  -- Pockets: fixed 5 slots like you described
  Pockets = {
    Slots = 5
  },

  -- Default wearable capacity (if no backpack etc)
  Wearables = {
    DefaultExtraSlots = 0,

    -- itemKey -> extra slots
    -- (You can add these items later in aln-items)
    SlotAdds = {
      backpack = 10,
      dufflebag = 20,
      camping_pack = 30,
    }
  },

  -- Stashes (server-side IDs)
  -- Player stash IDs will be "stash:home:<locationId>" etc.
  Stash = {
    MaxSlotsVehicle = 20,
    MaxSlotsHome = 30,
    MaxSlotsMotel = 15,
  },

  -- Hard cap to prevent accidents
  MaxStackDefault = 10,
}
