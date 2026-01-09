ALN_LOOT_MODULES = ALN_LOOT_MODULES or {}

ALN_LOOT_MODULES['gangs'] = {
  ['npc.gang.low'] = {
    label = 'Gang (Low)',
    rolls = { min = 1, max = 3 },
    entries = {
      { item = 'dirty_money', w = 35, count = { min = 20, max = 180 } },
      { item = 'cash',        w = 10, count = { min = 10, max = 80 } },
      { item = 'cigarette',   w = 18, count = { min = 1, max = 6 } },
      { item = 'joint',       w = 10, count = { min = 1, max = 2 } },
      { item = 'lockpick',    w = 8,  count = { min = 1, max = 1 } },
      { item = nil,           w = 19 },
    }
  },

  ['npc.gang.mid'] = {
    label = 'Gang (Mid)',
    rolls = { min = 2, max = 4 },
    entries = {
      { item = 'dirty_money', w = 40, count = { min = 60, max = 400 } },
      { item = 'loot_valuable', w = 12, count = { min = 1, max = 1 },
        variant = { list = {
          { key='ring', w=35 }, { key='necklace', w=25 }, { key='rolex', w=25 }, { key='diamond', w=15 }
        } }
      },
      { item = 'lockpick',    w = 10, count = { min = 1, max = 2 } },
      { item = 'lockpick_adv', w = 3, count = { min = 1, max = 1 } },
      { item = 'benzo',       w = 6,  count = { min = 1, max = 1 } },
      { item = nil,           w = 29 },
    }
  },

  ['npc.gang.high'] = {
    label = 'Gang (High)',
    rolls = { min = 2, max = 5 },
    entries = {
      { item = 'dirty_money', w = 45, count = { min = 150, max = 900 } },
      { item = 'loot_valuable', w = 18, count = { min = 1, max = 2 },
        variant = { list = {
          { key='rolex', w=35 }, { key='diamond', w=25 }, { key='necklace', w=25 }, { key='art_mona', w=15 }
        } }
      },
      { item = 'repair_basic', w = 5, count = { min = 1, max = 1 } },
      { item = 'lockpick_adv', w = 6, count = { min = 1, max = 1 } },
      { item = nil,            w = 26 },
    }
  },
}
