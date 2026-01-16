fx_version 'cerulean'
lua54 'yes'
game 'gta5'

name 'bg3_dice'
description 'BG3-style D20 with visual ADV/DIS (two dice), nat20 glint, nat1 sting, DC>20 nat20-only, transparent NUI'
author 'GrandScripts'
version '1.0.0'

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/style.css',
  'html/app.js',
  'html/translation.js',
  'html/three.min.js',
  'html/sfx/roll_loop.ogg',
  'html/sfx/roll_loop.wav',
  'html/sfx/success.ogg',
  'html/sfx/success.wav',
  'html/sfx/fail.ogg',
  'html/sfx/fail.wav',
  'html/sfx/nat20.ogg',
  'html/sfx/nat20.wav',
  'html/sfx/nat1.ogg',
  'html/sfx/nat1.wav'
}

client_scripts {
  'config.lua',
  'client.lua'
}

server_scripts {
  'config.lua',
  'server.lua'
}

escrow_ignore {
	'client.lua',
	'config.lua',
    'server.lua'
}

dependency '/assetpacks'