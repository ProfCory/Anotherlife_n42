ALN_LOOT_MODULES = ALN_LOOT_MODULES or {}

ALN_LOOT_MODULES['crates'] = {
  ['crate.house.common'] = {
    label = 'House Crate (Common)',
    rolls = { min = 1, max = 4 },
    entries = {
      { item = 'water',         w = 25, count = { min=1, max=2 } },
      { item = 'soda',          w = 18, count = { min=1, max=2 } },
      { item = 'sandwich',      w = 16, count = { min=1, max=2 } },
      { item = 'bandage',       w = 12, count = { min=1, max=2 } },
      { item = 'cigarette',     w = 10, count = { min=1, max=6 } },
      { item = 'cash',          w = 8,  count = { min=10, max=120 } },
      { item = 'loot_valuable', w = 6,  count = { min=1, max=1 },
        variant = { list = { {key='ring', w=45}, {key='necklace', w=35}, {key='diamond', w=20} } }
      },
      { item = nil,             w = 20 },
    }
  },

  ['crate.vehicle.trunk'] = {
    label = 'Vehicle Trunk',
    rolls = { min = 0, max = 3 },
    entries = {
      { item = 'water',         w = 14, count = { min=1, max=1 } },
      { item = 'soda',          w = 10, count = { min=1, max=1 } },
      { item = 'jerry_can',     w = 6,  count = { min=1, max=1 } },
      { item = 'wrench',        w = 8,  count = { min=1, max=1 } },
      { item = 'rope',          w = 7,  count = { min=1, max=1 } },
      { item = 'repair_basic',  w = 5,  count = { min=1, max=1 } },
      { item = 'cash',          w = 10, count = { min=5, max=60 } },
      { item = nil,             w = 40 },
    }
  },

  ['crate.stash.illegal'] = {
    label = 'Stash (Illegal)',
    rolls = { min = 1, max = 4 },
    entries = {
      { item = 'dirty_money',   w = 35, count = { min=50, max=500 } },
      { item = 'lockpick',      w = 15, count = { min=1, max=2 } },
      { item = 'lockpick_adv',  w = 6,  count = { min=1, max=1 } },
      { item = 'joint',         w = 12, count = { min=1, max=3 } },
      { item = 'benzo',         w = 8,  count = { min=1, max=1 } },
      { item = 'loot_valuable', w = 10, count = { min=1, max=1 },
        variant = { list = { {key='rolex', w=40}, {key='diamond', w=30}, {key='ring', w=30} } }
      },
      { item = nil,             w = 14 },
    }
  },
}
