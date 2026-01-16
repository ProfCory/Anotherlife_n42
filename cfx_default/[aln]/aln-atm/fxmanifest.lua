fx_version 'cerulean'
game 'gta5'

name 'aln-atm'
author 'Another Life N3'
description 'ALN3 ATM: cash <-> bank transfers + ATM card purchase.'
version '0.1.0'

lua54 'yes'

dependencies {
  'aln-core',
  'aln-ui-focus',
  'aln-locations',
  'aln-items',
  'aln-economy',
}

ui_page 'html/index.html'

files {
  'html/index.html'
}

shared_scripts {
  'shared/config.lua'
}

client_scripts {
  'client/detect.lua',
  'client/main.lua',
}

server_scripts {
  'server/main.lua',
}

provide 'aln-atm'
