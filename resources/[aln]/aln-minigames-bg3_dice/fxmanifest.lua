fx_version 'cerulean'
game 'gta5'

name 'aln-minigame-bg3dice'
author 'Another Life N3'
description 'Optional visual bridge: BG3 dice animations for aln-minigame results.'
version '0.1.0'
lua54 'yes'

dependencies {
  'aln-core',
  'aln-minigame',
  -- paid dice resource should live in [standalone]; we do NOT hard-depend by name here
}

shared_scripts { 'shared/config.lua' }
client_scripts { 'client/main.lua' }

provide 'aln-minigame-bg3dice'
