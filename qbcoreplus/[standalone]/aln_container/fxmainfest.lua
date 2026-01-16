fx_version 'cerulean'
game 'gta5'

author 'ALN'
description 'Illegal Container House (qb-inventory + qb-target)'
version '1.2.0'

client_script 'client.lua'
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'qb-core',
    'qb-radialmenu',
    'qb-target',
    'k4mb1-startershells',
    'qb-inventory'
}
