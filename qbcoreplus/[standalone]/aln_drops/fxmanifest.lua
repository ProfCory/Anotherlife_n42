fx_version 'cerulean'
game 'gta5'

lua54 'yes'

name 'aln_drops'
author 'ALN'
description 'NPC loot drops + corpse persistence + witness EMS revive (lightweight)'
version '0.1.0'

shared_scripts {
  'config.lua',
  'shared.lua',
  'alias.lua',
}

client_scripts {
  '@ox_lib/init.lua', -- optional; safe if ox_lib present
  'client.lua',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua', -- optional; safe if absent (will not crash if you remove). Keep if you use oxmysql elsewhere.
  'server.lua',
}

dependencies {
  'ox_lib' -- optional but recommended; remove if you don't use ox_lib
}
