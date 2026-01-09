fx_version 'cerulean'
game 'gta5'

name 'aln-criminal-xp'
author 'Another Life N3'
description 'ALN3 criminal XP/level bands + momentum state (server authoritative).'
version '0.1.0'
lua54 'yes'

dependencies { 'aln-core', 'aln-persistent-data' }

shared_scripts { 'shared/config.lua' }
server_scripts { 'server/main.lua' }

provide 'aln-criminal-xp'
