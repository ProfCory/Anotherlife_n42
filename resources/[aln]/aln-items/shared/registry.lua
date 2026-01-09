ALN = ALN or {}
ALN.Items = ALN.Items or {}
ALN_ITEM_MODULES = ALN_ITEM_MODULES or {}

local function isTrue(v) return v == true end

local function dbg(event, fields)
  if Config and Config.Items and Config.Items.Debug then
    ALN.Log.Debug(event, fields or {})
  end
end

local function err(msg)
  if Config and Config.Items and Config.Items.StrictValidation then
    error(msg)
  else
    ALN.Log.Error('items.validation', { msg = msg })
  end
end

local function validateItem(key, it)
  if type(it) ~= 'table' then err(('Item %s is not a table'):format(key)); return end
  if type(it.label) ~= 'string' or it.label == '' then err(('Item %s missing label'):format(key)) end
  if type(it.icon) ~= 'string' or it.icon == '' then err(('Item %s missing icon'):format(key)) end
  if type(it.domain) ~= 'string' or not (ALN.Items.Schema.domains[it.domain]) then
    err(('Item %s has invalid domain "%s"'):format(key, tostring(it.domain)))
  end

  if it.stackable == true then
    if type(it.maxStack) ~= 'number' or it.maxStack < 1 then
      err(('Item %s stackable but invalid maxStack'):format(key))
    end
  else
    -- normalize non-stackables
    it.stackable = false
    it.maxStack = nil
  end

  if it.buy ~= nil and type(it.buy) ~= 'number' then err(('Item %s buy must be number or nil'):format(key)) end
  if it.sell ~= nil and type(it.sell) ~= 'number' then err(('Item %s sell must be number or nil'):format(key)) end

  -- Weapon wheel domain should never be normal inventory visible unless explicitly wanted later
  if (it.domain == 'weapon' or it.domain == 'ammo') then
    if it.storage ~= 'weaponwheel' then
      err(('Item %s weapon/ammo must set storage="weaponwheel"'):format(key))
    end
    if it.inventoryVisible == nil then it.inventoryVisible = false end
  end
end

local function buildRegistry()
  local out = {}
  for moduleName, moduleItems in pairs(ALN_ITEM_MODULES) do
    if type(moduleItems) ~= 'table' then
      err(('Items module "%s" is not a table'):format(moduleName))
    else
      for key, it in pairs(moduleItems) do
        if out[key] ~= nil then
          err(('Duplicate item key "%s" (module %s)'):format(key, moduleName))
        else
          out[key] = it
          validateItem(key, it)
        end
      end
    end
  end

  return out
end

ALN.Items.Registry = buildRegistry()

function ALN.Items.Get(key) return ALN.Items.Registry[key] end
function ALN.Items.GetAll() return ALN.Items.Registry end

function ALN.Items.IconUrl(iconId)
  local fmt = (Config and Config.Items and Config.Items.IconUrlFormat) or 'nui://aln-items/icons/%s.png'
  return fmt:format(iconId)
end

exports('GetItem', function(key) return ALN.Items.Get(key) end)
exports('GetAll', function() return ALN.Items.GetAll() end)
exports('IconUrl', function(iconId) return ALN.Items.IconUrl(iconId) end)

dbg('items.registry_ready', { count = (function()
  local c=0; for _ in pairs(ALN.Items.Registry) do c=c+1 end; return c
end)() })
