fx_version 'cerulean'
game 'gta5'

name 'aln-carjack'
author 'Another Life N3'
description 'ALN3 carjack: lock vehicles, entry methods, hotwire requirement (minigame-driven).'
version '0.1.0'
lua54 'yes'

dependencies {
  'aln-core',
  'aln-ui-focus',
  'aln-minigame',
  'aln-criminal-tools',
}

shared_scripts { 'shared/config.lua' }

server_scripts { 'server/main.lua' }
client_scripts { 'client/main.lua' }

provide 'aln-carjack'
