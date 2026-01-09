ALN_LOOT_MODULES = ALN_LOOT_MODULES or {}

ALN_LOOT_MODULES['robbery'] = {
  ['robbery.register.small'] = {
    label = 'Cash Register (Small)',
    rolls = { min = 1, max = 2 },
    entries = {
      { item = 'cash', w = 80, count = { min=60, max=250 } },
      { item = 'dirty_money', w = 10, count = { min=40, max=160 } },
      { item = nil, w = 10 },
    }
  },

  ['robbery.safe.small'] = {
    label = 'Small Safe',
    rolls = { min = 1, max = 3 },
    entries = {
      { item = 'cash', w = 55, count = { min=150, max=900 } },
      { item = 'dirty_money', w = 18, count = { min=120, max=700 } },
      { item = 'loot_valuable', w = 18, count = { min=1, max=2 },
        variant = { list = { {key='ring', w=35}, {key='necklace', w=30}, {key='rolex', w=25}, {key='diamond', w=10} } }
      },
      { item = nil, w = 9 },
    }
  },
}
