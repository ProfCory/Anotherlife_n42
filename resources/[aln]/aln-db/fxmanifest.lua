fx_version 'cerulean'
game 'gta5'

name 'aln-db'
author 'Another Life N3'
description 'ALN3 database contract: migrations + query wrappers (oxmysql).'
version '0.1.0'

lua54 'yes'

dependencies {
  'aln-core',
  'oxmysql'
}

shared_scripts {
  'shared/config.lua',
  'shared/constants.lua',
}

server_scripts {
  'server/util.lua',
  'server/db.lua',
  'server/migrate.lua',
  'server/main.lua',
}

provide 'aln-db'
