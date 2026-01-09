fx_version 'cerulean'
game 'gta5'

name 'aln-admin'
author 'Another Life N3'
description 'ALN3 admin/ops: ACE-gated debug commands + baseline validation helpers.'
version '0.1.0'
lua54 'yes'

dependencies {
  'aln-core',
  'aln-db',
  'aln-persistent-data',
  'aln-economy',
  'aln-inventory',
  'aln-services',
  'aln-launder',
  'aln-pawn',
  'aln-minigame',
  'aln-carjack',
}

shared_scripts {
  'shared/config.lua',
}

server_scripts {
  'server/util.lua',
  'server/baseline.lua',
  'server/main.lua',
}

client_scripts {
  'client/main.lua',
}

provide 'aln-admin'
