fx_version 'cerulean'
game 'gta5'

author 'ProfCory / ALN'
description 'ALN Status: fatigue/drunk/stoned (0-100) with effects + draggable UI'
version '1.0.0'

lua54 'yes'

ui_page 'html/index.html'

shared_scripts {
  'config.lua'
}

client_scripts {
  'client.lua'
}

server_scripts {
  'server.lua'
}

files {
  'html/index.html',
  'html/style.css',
  'html/app.js'
}

dependencies {
  'qb-core'
}
