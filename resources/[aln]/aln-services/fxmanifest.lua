fx_version 'cerulean'
game 'gta5'

name 'aln-services'
author 'Another Life N3'
description 'ALN3 service dispatcher: police/ems/fire/taxi callable simulations (server-authoritative).'
version '0.1.0'

lua54 'yes'

dependencies {
  'aln-core',
  'aln-locations',
  'aln-economy',
}

shared_scripts {
  'shared/config.lua',
  'shared/schema.lua',
}

server_scripts {
  'server/registry.lua',
  'server/dispatcher.lua',
  'server/main.lua',
}

client_scripts {
  'client/ai.lua',
  'client/main.lua',
}

provide 'aln-services'
