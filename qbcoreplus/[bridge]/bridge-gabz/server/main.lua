-- bridge-gabz: server state + location registry

local LOC_FILE = 'data/locations.json'

local Locations = {}   -- array
local ClosedUntil = {} -- map id -> unix ms

local function nowMs()
  return os.time() * 1000
end

local function deepCopy(obj)
  if type(obj) ~= 'table' then return obj end
  local res = {}
  for k, v in pairs(obj) do
    res[k] = deepCopy(v)
  end
  return res
end

local function loadJsonLocations()
  local raw = LoadResourceFile(GetCurrentResourceName(), LOC_FILE)
  if not raw or raw == '' then
    return { version = 1, locations = {} }
  end
  local ok, data = pcall(function()
    return json.decode(raw)
  end)
  if not ok or type(data) ~= 'table' then
    return { version = 1, locations = {} }
  end
  data.locations = data.locations or {}
  return data
end

local function writeJsonLocations(locationsArray)
  local payload = json.encode({ version = 1, locations = locationsArray }, { indent = true })
  SaveResourceFile(GetCurrentResourceName(), LOC_FILE, payload, -1)
end

local function resourceAnyStarted(list)
  if type(list) ~= 'table' then return false end
  for _, r in ipairs(list) do
    if GetResourceState(r) == 'started' then
      return true
    end
  end
  return false
end

local function mergeLocations(defaults, saved)
  -- id-based merge: saved overrides defaults
  local byId = {}
  local out = {}

  for _, loc in ipairs(defaults or {}) do
    if loc.id then
      byId[loc.id] = deepCopy(loc)
    end
  end

  for _, loc in ipairs(saved or {}) do
    if loc.id then
      byId[loc.id] = deepCopy(loc)
    end
  end

  for _, loc in pairs(byId) do
    -- Auto-enable if matching resource started
    if loc.enabled == false and resourceAnyStarted(loc.enable_if_resource) then
      loc.enabled = true
    end
    table.insert(out, loc)
  end

  table.sort(out, function(a, b)
    return tostring(a.label or a.id) < tostring(b.label or b.id)
  end)

  return out
end

local function setLocationClosed(id, durationSeconds, reason)
  if not id then return end
  local untilMs = nowMs() + (math.floor((durationSeconds or 0) * 1000))
  ClosedUntil[id] = untilMs
  BG_DB.saveClosedUntil(id, untilMs)

  TriggerClientEvent('bridge-gabz:client:setClosed', -1, id, untilMs, reason or 'cleanup')
end

local function isClosed(id)
  local u = ClosedUntil[id] or 0
  return u > nowMs(), u
end

-- Boot
CreateThread(function()
  BG_DB.init()

  local saved = loadJsonLocations()
  Locations = mergeLocations(BG_DEFAULT_LOCATIONS, saved.locations)

  BG_DB.loadAll(function(map)
    ClosedUntil = map or {}
  end)
end)

-- Callbacks
lib.callback.register('bridge-gabz:server:getLocations', function(source)
  return Locations
end)

lib.callback.register('bridge-gabz:server:getClosedMap', function(source)
  return ClosedUntil
end)

lib.callback.register('bridge-gabz:server:isClosed', function(source, id)
  local closed, untilMs = isClosed(id)
  return closed, untilMs
end)

-- Client asks to close a location
RegisterNetEvent('bridge-gabz:server:closeLocation', function(id, durationSeconds, reason)
  if not BG_CFG.Cleanup.Enabled then return end
  setLocationClosed(id, durationSeconds or BG_CFG.Cleanup.CloseForSeconds, reason)
end)

-- Builder: save locations.json (admin gated by ace)
RegisterNetEvent('bridge-gabz:server:saveLocations', function(locationsArray)
  local src = source
  if not BG_CFG.EnableBuilderCommands then return end
  if not IsPlayerAceAllowed(src, 'bridgegabz.builder') then
    return
  end
  if type(locationsArray) ~= 'table' then return end

  -- basic sanitation: enforce id
  local cleaned = {}
  local seen = {}
  for _, loc in ipairs(locationsArray) do
    if type(loc) == 'table' and type(loc.id) == 'string' and loc.id ~= '' and not seen[loc.id] then
      seen[loc.id] = true
      table.insert(cleaned, loc)
    end
  end

  Locations = mergeLocations(BG_DEFAULT_LOCATIONS, cleaned)
  writeJsonLocations(cleaned)

  TriggerClientEvent('bridge-gabz:client:locationsUpdated', -1, Locations)
end)
