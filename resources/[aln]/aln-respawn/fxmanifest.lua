fx_version 'cerulean'
game 'gta5'

name 'aln-respawn'
author 'Another Life N3'
description 'ALN3 solo death/respawn: timers + registry-driven endpoints.'
version '0.1.0'

lua54 'yes'

dependencies {
  'aln-core',
  'aln-ui-focus',
  'aln-locations',
  'aln-persistent-data',
}

shared_scripts {
  'shared/config.lua',
}

server_scripts {
  'server/logic.lua',
  'server/main.lua',
}

client_scripts {
  'client/main.lua',
}

provide 'aln-respawn'
