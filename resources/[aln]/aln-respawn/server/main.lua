-- aln-respawn/server/main.lua
-- Server-authoritative respawn coordinator

local Log
local Respawn = {}

-- Internal state
local Locks = {}

-- ===== Helpers =====

local function now()
  return os.time()
end

local function lock(src, seconds, meta)
  Locks[src] = {
    untilTs = now() + math.max(1, seconds or 1),
    meta = meta or {}
  }
end

local function isLocked(src)
  local l = Locks[src]
  if not l then return false end
  if now() > l.untilTs then
    Locks[src] = nil
    return false
  end
  return true
end

-- ===== Public API =====

Respawn.Lock = lock
Respawn.IsLocked = isLocked

-- Example timer logic (kept from your design)
function Respawn.ComputeTimerSeconds(wantedStars)
  wantedStars = tonumber(wantedStars or 0) or 0
  if wantedStars <= 0 then return Config.Respawn.BaseSeconds end
  return Config.Respawn.BaseSeconds + (wantedStars * Config.Respawn.PerStarSeconds)
end

-- Endpoint selector (delegates to registry logic)
function Respawn.SelectEndpoint(ctx)
  return ALN.RespawnEndpoints and ALN.RespawnEndpoints.Select(ctx) or nil
end

-- ===== Events =====

RegisterNetEvent('aln:respawn:request', function(payload)
  local src = source
  payload = payload or {}

  if isLocked(src) then
    TriggerClientEvent('aln:respawn:denied', src, { reason = 'locked' })
    return
  end

  local coords = payload.coords
  if coords and type(coords) ~= 'vector3' then
    coords = vector3(coords.x, coords.y, coords.z)
  end

  if not coords then
    local ped = GetPlayerPed(src)
    if ped and ped ~= 0 then
      coords = GetEntityCoords(ped)
    end
  end

  if not coords then
    TriggerClientEvent('aln:respawn:denied', src, { reason = 'no_coords' })
    return
  end

  local wantedStars = math.floor(tonumber(payload.wantedStars or 0) or 0)
  local timer = Respawn.ComputeTimerSeconds(wantedStars)

  lock(src, timer + 5, { armed = true })

  local endpoint = Respawn.SelectEndpoint({
    wantedStars = wantedStars,
    coords = coords
  })

  if not endpoint then
    TriggerClientEvent('aln:respawn:denied', src, { reason = 'no_endpoint' })
    return
  end

  Log.Info('respawn.armed', {
    src = src,
    timer = timer,
    wantedStars = wantedStars,
    endpointId = endpoint.id
  })

  TriggerClientEvent('aln:respawn:armed', src, {
    timer = timer,
    wantedStars = wantedStars,
    endpoint = {
      id = endpoint.id,
      label = endpoint.label,
      coords = {
        x = endpoint.coords.x,
        y = endpoint.coords.y,
        z = endpoint.coords.z
      }
    }
  })
end)

RegisterNetEvent('aln:respawn:commit', function(payload)
  local src = source
  payload = payload or {}

  if not isLocked(src) then
    lock(src, 10, { commit = true })
  end

  local endpoint = payload.endpoint
  if not endpoint or not endpoint.coords then
    TriggerClientEvent('aln:respawn:denied', src, { reason = 'bad_payload' })
    return
  end

  local c = endpoint.coords
  local coords = vector3(c.x, c.y, c.z)

  exports['aln-persistent-data']:SetLastPosition(
    src,
    coords,
    payload.heading or 0.0
  )

  TriggerClientEvent('aln:respawn:do', src, {
    coords = { x = c.x, y = c.y, z = c.z },
    heading = payload.heading or 0.0,
    clearWanted = Config.Respawn.ClearWantedOnRespawn == true
  })

  TriggerEvent('aln:respawn:completed', src, {
    endpointId = endpoint.id,
    wantedStars = tonumber(payload.wantedStars or 0) or 0
  })
end)

AddEventHandler('playerDropped', function()
  Locks[source] = nil
end)

-- ===== Init =====

CreateThread(function()
  exports['aln-core']:OnReady(function()
    Log = exports['aln-core']:Log()

    Log.Info('respawn.start', {
      resource = GetCurrentResourceName()
    })
  end)
end)
