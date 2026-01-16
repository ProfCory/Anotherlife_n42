fx_version 'cerulean'
game 'gta5'

author 'ProfCory / ALN'
description 'ALN Sleep: beds, motels, crash sleep, vehicle sleep, coffee'
version '1.0.0'

lua54 'yes'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'qb-core',
    'qb-target',
    'aln_status'
}
