fx_version 'cerulean'
game 'gta5'

name 'aln-economy'
author 'Another Life N3'
description 'ALN3 economy primitives: cash/bank/dirty authoritative + ledger.'
version '0.1.0'

lua54 'yes'

dependencies {
  'aln-core',
  'aln-db',
  -- 'aln-persistent-data' (later)
}

shared_scripts {
  'shared/config.lua',
  'shared/constants.lua',
}

server_scripts {
  'server/bootstrap.lua',
  'server/accounts.lua',
  'server/ledger.lua',
  'server/api.lua',
  'server/main.lua',
}

provide 'aln-economy'
