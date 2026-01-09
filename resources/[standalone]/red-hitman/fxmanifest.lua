fx_version 'cerulean'
game 'gta5'

name 'red-hitman'
author 'Red Scripts'
description 'Professional Hitman System - ESX/QBCore/QBX/Standalone'
version '1.0.0'

lua54 'yes'

shared_scripts {
    'shared/shared.lua',
    'shared/spawns.lua'
}

client_scripts {
    'config/cl_config.lua',
    'client/cl_main.lua'
}

server_scripts {
    'config/sv_config.lua',
    'server/sv_main.lua'
}

ui_page 'ui/build/index.html'

files {
    'ui/build/index.html',
    'ui/build/**/*'
}

dependencies {
    '/server:5848',
    '/onesync'
}

provide 'red-hitman'

escrow_ignore {
    'config/cl_config.lua',
    'config/sv_config.lua',
    'README.md'
}
dependency '/assetpacks'