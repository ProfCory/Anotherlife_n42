fx_version 'cerulean'
game 'gta5'

name 'aln-spawn'
author 'Another Life N3'
description 'ALN3 spawn owner: onboarding + last-location spawn + starter vehicle.'
version '0.1.0'

lua54 'yes'

dependencies {
  'aln-core',
  'aln-ui-focus',
  'aln-locations',
  'aln-persistent-data',
  'aln-respawn',
  'spawnmanager',
}

shared_scripts {
  'shared/config.lua',
}

server_scripts {
  'server/onboarding.lua',
  'server/spawn.lua',
  'server/main.lua',
}

client_scripts {
  'client/vehicle.lua',
  'client/ui.lua',
  'client/main.lua',
}

files {
  'migrations/1002_onboarding.sql'
}

provide 'aln-spawn'
