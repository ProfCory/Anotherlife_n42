fx_version 'cerulean'
game 'gta5'

name 'aln-items'
author 'Another Life N3'
description 'ALN3 item registry (data-first, stable IDs) + icon key mapping.'
version '0.1.0'

lua54 'yes'

dependencies {
  'aln-core',
}

shared_scripts {
  'shared/config.lua',
  'shared/tags.lua',
  'shared/schema.lua',

  -- modules (add more later without touching registry.lua logic)
  'shared/modules/items_starter.lua',
  'shared/modules/items_foods.lua',
  'shared/modules/items_drinks.lua',
  'shared/modules/items_medical.lua',
  'shared/modules/items_tools.lua',
  'shared/modules/items_vehicle.lua',
  'shared/modules/items_loot.lua',
  'shared/modules/items_finance.lua',
  'shared/modules/items_smokes.lua',
  'shared/modules/items_weapons_virtual.lua',

  -- registry builder/validator + exports
  'shared/registry.lua',
}

files {
  'icons/*.png'
}

provide 'aln-items'
