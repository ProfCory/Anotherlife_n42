ALN_LOOT_MODULES = ALN_LOOT_MODULES or {}

ALN_LOOT_MODULES['npc'] = {
  ['npc.civilian.pockets'] = {
    label = 'Civilian Pockets',
    rolls = { min = 0, max = 2 },
    entries = {
      { item = nil,            w = 45 },
      { item = 'cash',         w = 30, count = { min = 5, max = 60 } },
      { item = 'water',        w = 10, count = { min = 1, max = 1 } },
      { item = 'soda',         w = 8,  count = { min = 1, max = 1 } },
      { item = 'scratch_ticket', w = 5, count = { min = 1, max = 1 } },
      { item = 'cigarette',    w = 10, count = { min = 1, max = 4 } },
      { item = 'notepad',      w = 2,  count = { min = 1, max = 1 } },
    }
  },

  ['npc.civilian.wallet'] = {
    label = 'Civilian Wallet',
    rolls = { min = 1, max = 2 },
    entries = {
      { item = 'cash',      w = 65, count = { min = 10, max = 120 } },
      { item = 'receipt',   w = 25, count = { min = 1, max = 3 } },
      { item = nil,         w = 10 },
    }
  },

  ['npc.police.pockets'] = {
    label = 'Police Pockets',
    rolls = { min = 1, max = 2 },
    entries = {
      { item = 'bandage',   w = 18, count = { min = 1, max = 2 } },
      { item = 'firstaid_kit', w = 8, count = { min = 1, max = 1 } },
      { item = 'cash',      w = 25, count = { min = 10, max = 80 } },
      { item = nil,         w = 49 },
    }
  },

  ['npc.ems.pockets'] = {
    label = 'EMS Pockets',
    rolls = { min = 1, max = 3 },
    entries = {
      { item = 'bandage',      w = 35, count = { min = 1, max = 3 } },
      { item = 'firstaid_kit', w = 20, count = { min = 1, max = 1 } },
      { item = 'vicodin',      w = 10, count = { min = 1, max = 2 } },
      { item = nil,            w = 35 },
    }
  },
}
