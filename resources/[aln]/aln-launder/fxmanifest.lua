fx_version 'cerulean'
game 'gta5'

name 'aln-launder'
author 'Another Life N3'
description 'ALN3 laundering: convert dirty money to clean cash/bank at configured endpoints.'
version '0.1.0'

lua54 'yes'

dependencies {
  'aln-core',
  'aln-ui-focus',
  'aln-locations',
  'aln-economy',
}

shared_scripts {
  'shared/config.lua',
}

server_scripts {
  'server/rates.lua',
  'server/main.lua',
}

client_scripts {
  'client/main.lua',
}

provide 'aln-launder'
