fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'ALN'
description 'Standalone hostile zones & gangs (PVE-first)'

shared_scripts {
    'shared/config.lua',
    'shared/constants.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- safe even if unused yet
    'server/state.lua',
    'server/selectors.lua',
    'server/events.lua',
    'server/main.lua',
}

client_scripts {
    'client/util.lua',
    'client/ai.lua',
    'client/blips.lua',
    'client/incidents.lua',
    'client/director.lua',
    'client/main.lua',
	'client/boss.lua',
	'client/vehicle_security.lua',
	'client/interiors.lua',
	'client/k4mb1_adapter.lua',
}
