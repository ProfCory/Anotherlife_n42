fx_version 'cerulean'
game 'gta5'

name 'aln-locations'
author 'Another Life N3'
description 'ALN3 location registry (data-first IDs) + optional blip spawner with clustering.'
version '0.1.0'

lua54 'yes'

dependencies {
  'aln-core',
}

shared_scripts {
  'shared/config.lua',
  'shared/schema.lua',

  'shared/modules/loc_services.lua',
  'shared/modules/loc_housing_apartments.lua',
  'shared/modules/loc_housing_motels.lua',
  'shared/modules/loc_housing_houses.lua',
  'shared/modules/loc_trailer_parks.lua',
  'shared/modules/loc_parking.lua',
  'shared/modules/loc_gangs.lua',
  'shared/modules/loc_payphones.lua',
  'shared/modules/loc_shops_shells.lua',
  'shared/modules/loc_pawn.lua',
  'shared/modules/loc_launder.lua',
  'shared/modules/loc_atms.lua',

  'shared/registry.lua',
}

client_scripts {
  'client/blips.lua',
  'client/main.lua',
}

provide 'aln-locations'
