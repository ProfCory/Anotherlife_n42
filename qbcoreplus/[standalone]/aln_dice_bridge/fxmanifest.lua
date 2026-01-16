fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'aln_dice_bridge'
description 'Dice bridge + Criminal XP (QBCore metadata) using bg3_dice'
author 'Cory + ChatGPT'
version '0.1.0'

dependencies {
  'qb-core',
  'ox_lib',
  'bg3_dice'
}

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua'
}

client_scripts {
  'client.lua'
}

server_scripts {
  'server.lua'
}
