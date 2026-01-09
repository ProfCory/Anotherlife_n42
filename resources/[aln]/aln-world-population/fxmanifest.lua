fx_version 'cerulean'
game 'gta5'

name 'aln-world-population'
author 'Another Life N3'
description 'ALN3 world population owner: densities, scenarios, ambient dispatch tuning.'
version '0.1.0'

lua54 'yes'

dependencies {
  'aln-core',
}

shared_scripts {
  'shared/config.lua',
}

client_scripts {
  'client/scenarios.lua',
  'client/dispatch.lua',
  'client/main.lua',
}

provide 'aln-world-population'
