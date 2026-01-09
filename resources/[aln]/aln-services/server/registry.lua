ALN = ALN or {}
ALN.Services = ALN.Services or {}
ALN.Services.Registry = ALN.Services.Registry or {}

local function dbg(ev, f)
  if Config.Services.Debug then
    ALN.Log.Debug(ev, f or {})
  end
end

local function loadStationsFor(tag)
  local res = exports['aln-locations']:FindByTag(tag) or {}
  local out = {}
  for _, e in ipairs(res) do
    out[#out+1] = {
      id = e.id,
      coords = e.loc.coords,
      label = e.loc.label,
    }
  end
  return out
end

function ALN.Services.Registry.Refresh()
  local tags = Config.Services.Tags or {}
  ALN.Services.Registry.Police = loadStationsFor(tags.police)
  ALN.Services.Registry.EMS    = loadStationsFor(tags.ems)
  ALN.Services.Registry.Fire   = loadStationsFor(tags.fire)

  dbg('services.registry_refresh', {
    police = #(ALN.Services.Registry.Police or {}),
    ems = #(ALN.Services.Registry.EMS or {}),
    fire = #(ALN.Services.Registry.Fire or {}),
  })
end

function ALN.Services.Registry.GetStations(serviceType)
  if serviceType == 'police' then return ALN.Services.Registry.Police or {} end
  if serviceType == 'ems' then return ALN.Services.Registry.EMS or {} end
  if serviceType == 'fire' then return ALN.Services.Registry.Fire or {} end
  return {}
end

exports('RefreshRegistry', function()
  ALN.Services.Registry.Refresh()
  return true
end)
