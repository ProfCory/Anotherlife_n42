fx_version 'cerulean'
game 'gta5'

name 'aln-persistent-data'
author 'Another Life N3'
description 'ALN3 persistence spine: 3 slots, active character, lifecycle, JSON blobs for v0.'
version '0.1.0'

lua54 'yes'

dependencies {
  'aln-core',
  'aln-db',
}

shared_scripts {
  'shared/config.lua',
  'shared/constants.lua',
}

server_scripts {
  'server/util.lua',
  'server/migrate.lua',
  'server/repo.lua',
  'server/main.lua',
}

provide 'aln-persistent-data'
