ALN_LOOT_MODULES = ALN_LOOT_MODULES or {}

ALN_LOOT_MODULES['misc'] = {
  ['assassin.drop'] = {
    label = 'Assassin Drop',
    rolls = { min = 1, max = 4 },
    entries = {
      { item = 'cash', w = 30, count = { min=100, max=800 } },
      { item = 'dirty_money', w = 20, count = { min=200, max=1200 } },
      { item = 'firstaid_kit', w = 10, count = { min=1, max=1 } },
      { item = 'repair_basic', w = 6, count = { min=1, max=1 } },
      { item = 'loot_valuable', w = 12, count = { min=1, max=1 },
        variant = { list = { {key='rolex', w=50}, {key='diamond', w=30}, {key='art_mona', w=20} } }
      },
      { item = nil, w = 22 },
    }
  },
}
