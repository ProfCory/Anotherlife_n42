fx_version 'cerulean'
game 'gta5'

name 'aln-criminal-unlocks'
author 'Another Life N3'
description 'ALN3 criminal unlock registry (server authoritative checks).'
version '0.1.0'
lua54 'yes'

dependencies { 'aln-core', 'aln-criminal-xp' }

shared_scripts { 'shared/config.lua' }
server_scripts { 'server/main.lua' }

provide 'aln-criminal-unlocks'
