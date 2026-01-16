fx_version 'cerulean'
game 'gta5'

name 'aln-loot'
author 'Another Life N3'
description 'ALN3 loot registry + deterministic server-side roller.'
version '0.1.0'

lua54 'yes'

dependencies {
  'aln-core',
  'aln-items',
}

shared_scripts {
  'shared/config.lua',
  'shared/schema.lua',

  'shared/modules/pools_npc.lua',
  'shared/modules/pools_crates.lua',
  'shared/modules/pools_robbery.lua',
  'shared/modules/pools_gangs.lua',
  'shared/modules/pools_misc.lua',

  'shared/registry.lua',
}

server_scripts {
  'server/rng.lua',
  'server/roll.lua',
  'server/main.lua',
}

provide 'aln-loot'
