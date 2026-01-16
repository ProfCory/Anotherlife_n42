fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'aln_makeapal'
author 'ALN'
description 'Make-a-Pal NPC crew for solo/low-player servers (ox_lib + JSON persistence)'

shared_scripts {
  '@ox_lib/init.lua',
  'shared.lua',
  'config.lua',
}

server_scripts {
  'persistence.lua',
  'server.lua',

  -- OPTIONAL ADDONS
  'addons/qb_economy.lua',
}

client_scripts {
  'client.lua',
  'radial_bridge.lua',

  -- OPTIONAL ADDONS
  'addons/qb_radial.lua',
}
