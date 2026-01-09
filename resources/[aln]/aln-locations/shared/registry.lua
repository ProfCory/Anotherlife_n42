ALN = ALN or {}
ALN.Locations = ALN.Locations or {}
ALN_LOCATION_MODULES = ALN_LOCATION_MODULES or {}

local function dbg(event, fields)
  if Config and Config.Locations and Config.Locations.Debug then
    ALN.Log.Debug(event, fields or {})
  end
end

local function err(msg)
  if Config and Config.Locations and Config.Locations.StrictValidation then
    error(msg)
  else
    ALN.Log.Error('locations.validation', { msg = msg })
  end
end

local function validate(id, loc)
  if type(loc) ~= 'table' then err(('Location %s is not a table'):format(id)); return end
  if type(loc.label) ~= 'string' or loc.label == '' then err(('Location %s missing label'):format(id)) end
  if type(loc.kind) ~= 'string' or not ALN.Locations.Schema.kinds[loc.kind] then
    err(('Location %s has invalid kind "%s"'):format(id, tostring(loc.kind)))
  end
  if type(loc.coords) ~= 'vector3' then
    err(('Location %s coords must be vector3'):format(id))
  end
  if loc.blip then
    if type(loc.blip) ~= 'table' then err(('Location %s blip must be table'):format(id)) end
    if loc.blip.scale == nil and Config.Locations.DefaultBlipScale then
      loc.blip.scale = Config.Locations.DefaultBlipScale
    end
    if loc.blip.shortRange == nil then
      loc.blip.shortRange = Config.Locations.DefaultShortRange == true
    end
  end
end

local function build()
  local out = {}
  for moduleName, tbl in pairs(ALN_LOCATION_MODULES) do
    if type(tbl) ~= 'table' then
      err(('Locations module "%s" is not a table'):format(moduleName))
    else
      for id, loc in pairs(tbl) do
        if out[id] then
          err(('Duplicate location id "%s" (module %s)'):format(id, moduleName))
        end
        out[id] = loc
        validate(id, loc)
      end
    end
  end
  return out
end

ALN.Locations.Registry = build()

function ALN.Locations.Get(id) return ALN.Locations.Registry[id] end
function ALN.Locations.GetAll() return ALN.Locations.Registry end

function ALN.Locations.FindByTag(tag)
  local res = {}
  for id, loc in pairs(ALN.Locations.Registry) do
    if loc.tags then
      for _, t in ipairs(loc.tags) do
        if t == tag then
          res[#res+1] = { id=id, loc=loc }
          break
        end
      end
    end
  end
  return res
end

exports('Get', function(id) return ALN.Locations.Get(id) end)
exports('GetAll', function() return ALN.Locations.GetAll() end)
exports('FindByTag', function(tag) return ALN.Locations.FindByTag(tag) end)

dbg('locations.registry_ready', { count = (function() local c=0; for _ in pairs(ALN.Locations.Registry) do c=c+1 end; return c end)() })
