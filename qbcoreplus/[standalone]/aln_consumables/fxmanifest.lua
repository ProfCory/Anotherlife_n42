fx_version 'cerulean'
game 'gta5'

author 'ProfCory / ALN'
description 'ALN Consumables: crafting + consuming bridge'
version '1.0.0'

lua54 'yes'

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'qb-core',
    'qb-inventory',
    'aln_status'
}
