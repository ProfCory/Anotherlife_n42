fx_version 'cerulean'
game 'gta5'

name 'bridge-gabz'
author 'ChatGPT (generated)'
description 'Standalone ambience spawner for Gabz MLOs (staff/visitors, optional qb-target interactions, optional cooldown/closures).'
version '0.1.0'

lua54 'yes'

shared_scripts {
  '@ox_lib/init.lua',
  'shared/models.lua',
  'shared/config.lua'
}

client_scripts {
  'client/main.lua',
  'client/interactions.lua'
}

server_scripts {
  'server/db.lua',
  'server/main.lua'
}

files {
  'data/locations.json'
}

escrow_ignore {
  '**/*.lua',
  'data/*.json'
}
