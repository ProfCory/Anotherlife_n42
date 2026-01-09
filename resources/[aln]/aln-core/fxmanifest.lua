fx_version 'cerulean'
game 'gta5'

name 'aln-core'
author 'Another Life N3'
description 'ALN3 core spine: readiness, identifiers, structured logging, event conventions.'
version '0.1.0'

lua54 'yes'

shared_scripts {
  'shared/config.lua',
  'shared/constants.lua',
  'shared/util.lua',
}

server_scripts {
  'server/log.lua',
  'server/identifiers.lua',
  'server/ready.lua',
  'server/main.lua',
}

client_scripts {
  'client/log.lua',
  'client/ready.lua',
  'client/main.lua',
}

provide 'aln-core'
