fx_version 'cerulean'
game 'gta5'

name 'aln-inventory'
author 'Another Life N3'
description 'ALN3 server-authoritative inventory: pockets, wearables, stashes.'
version '0.1.0'

lua54 'yes'

dependencies {
  'aln-core',
  'aln-db',
  'aln-items',
  'aln-economy',
  -- 'aln-persistent-data' later
}

shared_scripts {
  'shared/config.lua',
  'shared/schema.lua',
}

server_scripts {
  'server/validate.lua',
  'server/store_memory.lua',
  'server/store_db.lua',
  'server/inventory.lua',
  'server/stashes.lua',
  'server/api.lua',
  'server/main.lua',
}

client_scripts {
  'client/main.lua',
}

files {
  'migrations/0002_inventory.sql'
}

provide 'aln-inventory'
