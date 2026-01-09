fx_version 'cerulean'
game 'gta5'

name 'aln-ui-focus'
author 'Another Life N3'
description 'Global UI focus + input arbitration for ALN3.'
version '0.1.0'

lua54 'yes'

dependencies {
  'aln-core',
}

ui_page 'html/index.html'

files {
  'html/index.html'
}

shared_scripts {
  'shared/config.lua',
  'shared/constants.lua',
}

client_scripts {
  'client/focus.lua',
  'client/controls.lua',
  'client/nui.lua',
  'client/main.lua',
}

server_scripts {
  'server/main.lua',
}

provide 'aln-ui-focus'
