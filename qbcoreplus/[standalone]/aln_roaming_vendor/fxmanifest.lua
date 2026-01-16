fx_version 'cerulean'
game 'gta5'

author 'standalone'
description 'Roaming vendor truck with qb-target buy/sell + pickup delivery'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua',
    'html/modules/jest_setup.js'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- optional; safe to leave even if unused, remove if you don't have it
    'server.lua'
}

dependencies {
    'qb-core',
    'qb-target',
    'qb-input'
}
