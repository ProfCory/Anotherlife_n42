fx_version 'cerulean'
game 'gta5'

name 'aln-pawn'
author 'Another Life N3'
description 'ALN3 pawn: sell loot/junk/valuables for cash (server authoritative).'
version '0.1.0'

lua54 'yes'

dependencies {
  'aln-core',
  'aln-ui-focus',
  'aln-locations',
  'aln-items',
  'aln-inventory',
  'aln-economy',
}

shared_scripts {
  'shared/config.lua',
  'shared/prices.lua',
}

server_scripts {
  'server/pricing.lua',
  'server/main.lua',
}

client_scripts {
  'client/main.lua',
}

provide 'aln-pawn'
