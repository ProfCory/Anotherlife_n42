ALN = ALN or {}
ALN.Services = ALN.Services or {}
ALN.Services.Dispatch = ALN.Services.Dispatch or {}

local lastCall = {} -- src -> type -> os.time()

local function dbg(ev, f)
  if Config.Services.Debug then
    ALN.Log.Debug(ev, f or {})
  end
end

local function now() return os.time() end

local function canCall(src, t)
  if not (Config.Services.Enabled and Config.Services.Enabled[t]) then
    return false, 'disabled'
  end
  lastCall[src] = lastCall[src] or {}
  local cd = (Config.Services.Cooldowns and Config.Services.Cooldowns[t]) or 30
  local prev = lastCall[src][t] or 0
  if (now() - prev) < cd then
    return false, 'cooldown'
  end
  return true
end

local function getPlayerCoordsServer(src)
  -- Works with OneSync. If not available, client will include coords.
  local ped = GetPlayerPed(src)
  if ped and ped ~= 0 then
    local c = GetEntityCoords(ped)
    if c then return c end
  end
  return nil
end

local function dist(a, b)
  local dx = a.x - b.x
  local dy = a.y - b.y
  local dz = a.z - b.z
  return math.sqrt(dx*dx + dy*dy + dz*dz)
end

local function nearestStation(serviceType, playerCoords)
  local stations = ALN.Services.Registry.GetStations(serviceType)
  local best, bestD = nil, 1e12
  for _, s in ipairs(stations) do
    local d = dist(playerCoords, s.coords)
    if d < bestD then
      bestD = d
      best = s
    end
  end
  return best
end

-- Public: request a service
-- opts may include: coords (vector3), waypoint (vector3), meta (table)
function ALN.Services.Dispatch.Request(src, serviceType, opts)
  opts = opts or {}

  if not ALN.Services.Types[serviceType] then
    return false, 'bad_type'
  end

  local ok, reason = canCall(src, serviceType)
  if not ok then return false, reason end

  local pc = getPlayerCoordsServer(src) or opts.coords
  if not pc then return false, 'no_coords' end

  local station = nil
  if serviceType ~= 'taxi' then
    station = nearestStation(serviceType, pc)
  end

  lastCall[src][serviceType] = now()

  local job = {
    jobId = ('%s:%d:%d'):format(serviceType, src, now()),
    type = serviceType,
    player = { src = src, coords = pc },
    station = station,
    waypoint = opts.waypoint,
    config = {
      spawnMin = (Config.Services.Spawn and Config.Services.Spawn.MinFromPlayer) or 80.0,
      spawnMax = (Config.Services.Spawn and Config.Services.Spawn.MaxFromPlayer) or 160.0,
      dwell = (Config.Services.Spawn and Config.Services.Spawn.DwellSeconds) or 45,
    },
    meta = opts.meta or {},
  }

  dbg('services.request_ok', {
    src = src,
    type = serviceType,
    stationId = station and station.id or nil,
  })

  TriggerClientEvent('aln:services:job', src, job)
  return true, job
end

exports('RequestService', function(src, serviceType, opts)
  return ALN.Services.Dispatch.Request(src, serviceType, opts)
end)
