fx_version 'cerulean'
game 'gta5'

name 'aln-minigame'
author 'Another Life N3'
description 'ALN3 DC/D20 engine: adv/dis, nat1/nat20, tool break, wanted side effects.'
version '0.1.0'
lua54 'yes'

dependencies { 'aln-core', 'aln-criminal-xp', 'aln-criminal-tools' }

shared_scripts { 'shared/config.lua' }
server_scripts { 'server/main.lua' }
client_scripts { 'client/main.lua' }

provide 'aln-minigame'
