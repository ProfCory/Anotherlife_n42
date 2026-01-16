-- aln-items/shared/items/_index.lua
-- Loads and merges item category modules into one registry table.

ALN = ALN or {}
ALN.Items = ALN.Items or {}

local function mergeInto(dst, src, srcName)
  for k, v in pairs(src or {}) do
    if dst[k] ~= nil then
      error(('[aln-items] Duplicate item key "%s" found while merging %s'):format(k, srcName or 'unknown'))
    end
    dst[k] = v
  end
end

local modules = {
  { name = 'items_starter',         path = 'shared/items/items_starter.lua' },
  { name = 'items_foods',           path = 'shared/items/items_foods.lua' },
  { name = 'items_medical',         path = 'shared/items/items_medical.lua' },
  { name = 'items_tools',           path = 'shared/items/items_tools.lua' },
  { name = 'items_vehicle',         path = 'shared/items/items_vehicle.lua' },
  { name = 'items_loot',            path = 'shared/items/items_loot.lua' },
  { name = 'items_drugs',           path = 'shared/items/items_drugs.lua' },
  { name = 'items_weapons_virtual', path = 'shared/items/items_weapons_virtual.lua' },
}

local registry = {}
for _, m in ipairs(modules) do
  local chunk = LoadResourceFile(GetCurrentResourceName(), m.path)
  if not chunk or chunk == '' then
    error(('[aln-items] Missing items module file: %s'):format(m.path))
  end

  local fn, err = load(chunk, ('@@%s/%s'):format(GetCurrentResourceName(), m.path), 't')
  if not fn then error(err) end

  local ok, tbl = pcall(fn)
  if not ok then error(tbl) end
  if type(tbl) ~= 'table' then
    error(('[aln-items] Module %s did not return a table'):format(m.name))
  end

  mergeInto(registry, tbl, m.name)
end

ALN.Items.Registry = registry

exports('GetItem', function(key) return ALN.Items.Registry[key] end)
exports('GetAll', function() return ALN.Items.Registry end)
