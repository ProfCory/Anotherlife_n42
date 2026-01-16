fx_version 'cerulean'
game 'gta5'

name 'aln-criminal-tools'
author 'Another Life N3'
description 'ALN3 criminal tool registry + server-side tool checks/consumption.'
version '0.1.0'
lua54 'yes'

dependencies { 'aln-core', 'aln-items', 'aln-inventory' }

shared_scripts { 'shared/config.lua' }
server_scripts { 'server/main.lua' }

provide 'aln-criminal-tools'
