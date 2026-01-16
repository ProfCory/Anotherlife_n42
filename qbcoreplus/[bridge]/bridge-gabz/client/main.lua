-- bridge-gabz: client spawner + zone logic

local Locations = {}
local ClosedUntil = {}

local ActiveZones = {}     -- id -> zone object
local LocationRuntime = {} -- id -> runtime state

local function reqModel(model)
  if not model then return false end
  local m = type(model) == 'string' and joaat(model) or model
  if not m then return false end
  if HasModelLoaded(m) then return true end
  RequestModel(m)
  local timeout = GetGameTimer() + 5000
  while not HasModelLoaded(m) and GetGameTimer() < timeout do
    Wait(0)
  end
  return HasModelLoaded(m)
end

local function pick(list)
  if type(list) ~= 'table' or #list == 0 then return nil end
  return list[math.random(1, #list)]
end

local function isResourceStarted(name)
  return name and GetResourceState(name) == 'started'
end

local function isClosed(id)
  local untilMs = ClosedUntil[id] or 0
  local serverTime = lib.getServerTime()
  -- lib.getServerTime() returns seconds
  local nowServerMs = (serverTime or os.time()) * 1000
  return untilMs > nowServerMs, untilMs
end

local function ensureRuntime(id)
  if LocationRuntime[id] then return LocationRuntime[id] end
  LocationRuntime[id] = {
    inside = false,
    lastOutsideAt = nil,
    lastVisitorWaveAt = 0,
    peds = {
      staff = {},
      visitors = {}
    }
  }
  return LocationRuntime[id]
end

local function safeDeletePed(ped)
  if not ped or ped == 0 then return end
  if DoesEntityExist(ped) then
    DeleteEntity(ped)
  end
end

local function setupAmbientPed(ped)
  SetEntityAsMissionEntity(ped, true, true)
  SetPedCanRagdoll(ped, true)
  SetPedDiesWhenInjured(ped, true)
  SetPedFleeAttributes(ped, 0, false)
  SetPedCombatAttributes(ped, 17, false) -- bUseCover
  SetPedCombatAttributes(ped, 46, true)  -- bAlwaysFlee
  SetBlockingOfNonTemporaryEvents(ped, false)
  SetPedKeepTask(ped, true)
  SetPedAsNoLongerNeeded(ped)
end

local function createPedAt(pos4, model, scenario)
  if not pos4 then return nil end
  if not reqModel(model) then return nil end

  local pedType = 4
  local ped = CreatePed(pedType, joaat(model), pos4.x, pos4.y, pos4.z - 1.0, pos4.w or 0.0, false, false)
  if not ped or ped == 0 then return nil end

  setupAmbientPed(ped)

  if scenario and scenario ~= '' then
    TaskStartScenarioInPlace(ped, scenario, 0, true)
  else
    TaskWanderStandard(ped, 10.0, 10)
  end

  return ped
end

local function clearPedsForLocation(id)
  local rt = ensureRuntime(id)
  for _, ped in ipairs(rt.peds.staff) do safeDeletePed(ped) end
  for _, ped in ipairs(rt.peds.visitors) do safeDeletePed(ped) end
  rt.peds.staff = {}
  rt.peds.visitors = {}
end

local function spawnStaff(loc)
  local rt = ensureRuntime(loc.id)
  local closed = isClosed(loc.id)

  local targetCount = BG_CFG.Staff.DefaultCount
  if closed and BG_CFG.Cleanup.KeepStaffWhenClosed then
    targetCount = BG_CFG.Cleanup.StaffWhenClosedCount
  elseif closed then
    targetCount = 0
  end

  -- explicit staff points in loc.staff
  local points = loc.staff or {}
  if #points == 0 then return end

  while #rt.peds.staff < math.min(targetCount, #points) do
    local idx = #rt.peds.staff + 1
    local s = points[idx]
    local model = (s.model and s.model ~= '') and s.model or pick(BG_MODELS.staff)
    local scenario = (s.scenario and s.scenario ~= '') and s.scenario or pick(BG_SCENARIOS.staff)
    local ped = createPedAt(s.pos, model, scenario)
    if ped then
      table.insert(rt.peds.staff, ped)
    else
      break
    end
  end
end

local function spawnVisitorWave(loc)
  if not BG_CFG.Visitors.Enabled then return end

  local closed = isClosed(loc.id)
  if closed then return end

  local rt = ensureRuntime(loc.id)
  local maxLoc = BG_CFG.MaxPedsPerLocation
  if (#rt.peds.staff + #rt.peds.visitors) >= maxLoc then return end

  local v = loc.visitors
  if not v or not v.roam or #v.roam == 0 then return end

  local waveCount = math.min(BG_CFG.Visitors.DefaultCount, maxLoc - (#rt.peds.staff + #rt.peds.visitors))
  for i = 1, waveCount do
    local roam = pick(v.roam)
    local model = pick(BG_MODELS.visitors)
    local scenario = (roam and roam.scenario) or pick(BG_SCENARIOS.visitors)
    local ped = createPedAt(roam.pos, model, scenario)
    if ped then
      -- schedule leave
      local stay = math.random(BG_CFG.Visitors.MinStaySeconds, BG_CFG.Visitors.MaxStaySeconds)
      SetTimeout(stay * 1000, function()
        if DoesEntityExist(ped) then
          ClearPedTasks(ped)
          if v.exit then
            TaskGoStraightToCoord(ped, v.exit.x, v.exit.y, v.exit.z, 1.2, -1, v.exit.w or 0.0, 0.5)
          else
            TaskWanderStandard(ped, 10.0, 10)
          end
          SetTimeout(15000, function()
            safeDeletePed(ped)
          end)
        end
      end)

      table.insert(rt.peds.visitors, ped)
    end
  end
end

local function pruneDeadPeds(loc)
  local rt = ensureRuntime(loc.id)
  local function prune(list)
    local keep = {}
    for _, ped in ipairs(list) do
      if ped and ped ~= 0 and DoesEntityExist(ped) and not IsEntityDead(ped) then
        table.insert(keep, ped)
      else
        safeDeletePed(ped)
      end
    end
    return keep
  end
  rt.peds.staff = prune(rt.peds.staff)
  rt.peds.visitors = prune(rt.peds.visitors)
end

local function detectViolence(loc)
  if not BG_CFG.Cleanup.Enabled then return false end
  local playerPed = PlayerPedId()
  if not playerPed or playerPed == 0 then return false end

  if IsPedShooting(playerPed) then return true end
  if IsPedInMeleeCombat(playerPed) then return true end

  -- crude explosion check near zone center
  local z = loc.zone
  if z and z.center then
    if IsExplosionInSphere(-1, z.center.x, z.center.y, z.center.z, (z.radius or 50.0)) then
      return true
    end
  end

  return false
end

local function setClosedLocal(id, untilMs)
  ClosedUntil[id] = untilMs or 0
end

RegisterNetEvent('bridge-gabz:client:setClosed', function(id, untilMs)
  if not id then return end
  setClosedLocal(id, untilMs)

  -- when closed, immediately drop visitors for that location
  local rt = LocationRuntime[id]
  if rt then
    for _, ped in ipairs(rt.peds.visitors) do safeDeletePed(ped) end
    rt.peds.visitors = {}
  end
end)

RegisterNetEvent('bridge-gabz:client:locationsUpdated', function(newLocations)
  Locations = newLocations or {}
  -- rebuild zones
  for _, z in pairs(ActiveZones) do
    if z and z.remove then z:remove() end
  end
  ActiveZones = {}
  LocationRuntime = {}
  CreateThread(function()
    Wait(250)
    TriggerEvent('bridge-gabz:client:bootstrap')
  end)
end)

local function makeZone(loc)
  local z = loc.zone
  if not z or not z.type then return nil end

  if z.type == 'sphere' then
    return lib.zones.sphere({
      coords = z.center,
      radius = z.radius or 60.0,
      debug = BG_CFG.Debug,
      onEnter = function()
        local rt = ensureRuntime(loc.id)
        rt.inside = true
        rt.lastOutsideAt = nil
      end,
      onExit = function()
        local rt = ensureRuntime(loc.id)
        rt.inside = false
        rt.lastOutsideAt = GetGameTimer()
      end
    })
  elseif z.type == 'box' then
    return lib.zones.box({
      coords = z.center,
      size = z.size or vec3(40.0, 40.0, 20.0),
      rotation = z.rotation or 0.0,
      debug = BG_CFG.Debug,
      onEnter = function()
        local rt = ensureRuntime(loc.id)
        rt.inside = true
        rt.lastOutsideAt = nil
      end,
      onExit = function()
        local rt = ensureRuntime(loc.id)
        rt.inside = false
        rt.lastOutsideAt = GetGameTimer()
      end
    })
  end

  return nil
end

AddEventHandler('bridge-gabz:client:bootstrap', function()
  CreateThread(function()
    Locations = lib.callback.await('bridge-gabz:server:getLocations', false) or {}
    ClosedUntil = lib.callback.await('bridge-gabz:server:getClosedMap', false) or {}

    for _, loc in ipairs(Locations) do
      if loc.enabled then
        ActiveZones[loc.id] = makeZone(loc)
      end
    end

    -- main loop
    while true do
      local inAny = false

      for _, loc in ipairs(Locations) do
        local rt = LocationRuntime[loc.id]
        if loc.enabled and rt and rt.inside then
          inAny = true

          pruneDeadPeds(loc)

          -- spawn staff if needed
          spawnStaff(loc)

          -- visitor waves
          if BG_CFG.Visitors.Enabled then
            local t = GetGameTimer()
            if (t - (rt.lastVisitorWaveAt or 0)) >= (BG_CFG.Visitors.WaveEverySeconds * 1000) then
              rt.lastVisitorWaveAt = t
              spawnVisitorWave(loc)
            end
          end

          -- violence detection
          if detectViolence(loc) then
            TriggerServerEvent('bridge-gabz:server:closeLocation', loc.id, BG_CFG.Cleanup.CloseForSeconds, 'violence')
          end
        elseif loc.enabled and rt and not rt.inside and rt.lastOutsideAt then
          -- despawn after grace
          local elapsed = (GetGameTimer() - rt.lastOutsideAt) / 1000.0
          if elapsed >= BG_CFG.SpawnGraceSeconds then
            clearPedsForLocation(loc.id)
            rt.lastOutsideAt = nil
          end
        end
      end

      Wait(inAny and BG_CFG.TickRateMs or 1500)
    end
  end)
end)

-- Start
CreateThread(function()
  math.randomseed(GetGameTimer())
  TriggerEvent('bridge-gabz:client:bootstrap')
end)

-- Expose to other client files
exports('getLocations', function() return Locations end)
exports('getClosedUntil', function() return ClosedUntil end)

-- ===== Builder commands (optional) =====
-- Ace required on server: add_ace group.admin bridgegabz.builder allow
-- Commands:
-- /bg_newloc <id> <label>
-- /bg_here_zone <id> <radius>
-- /bg_addstaff <id> [model] [scenario]
-- /bg_setentry <id>
-- /bg_setexit <id>
-- /bg_addroam <id> [scenario]
-- /bg_enable <id> <0|1>
-- /bg_save

local function canBuild()
  return BG_CFG.EnableBuilderCommands and IsPlayerAceAllowed(PlayerId(), 'bridgegabz.builder')
end

local function cvec4()
  local p = GetEntityCoords(PlayerPedId())
  local h = GetEntityHeading(PlayerPedId())
  return vec4(p.x, p.y, p.z, h)
end

local function findLoc(id)
  for i, l in ipairs(Locations) do
    if l.id == id then return l, i end
  end
  return nil, nil
end

local function ensureVisitorsTable(loc)
  loc.visitors = loc.visitors or {}
  loc.visitors.roam = loc.visitors.roam or {}
end

local function notify(msg, t)
  lib.notify({ title = 'bridge-gabz', description = msg, type = t or 'inform' })
end

RegisterCommand('bg_newloc', function(_, args)
  if not canBuild() then return notify('No permission (bridgegabz.builder).', 'error') end
  local id = args[1]
  if not id or id == '' then return notify('Usage: /bg_newloc <id> <label>', 'error') end
  local label = table.concat(args, ' ', 2)
  if label == '' then label = id end

  local existing = findLoc(id)
  if existing then return notify('Location already exists: ' .. id, 'error') end

  table.insert(Locations, {
    id = id,
    label = label,
    enabled = true,
    zone = { type = 'sphere', center = GetEntityCoords(PlayerPedId()), radius = 60.0 },
    staff = {},
    visitors = { entry = cvec4(), exit = cvec4(), roam = {} }
  })

  notify('Created location ' .. id .. ' (enabled).')
  TriggerEvent('bridge-gabz:client:locationsUpdated', Locations)
end, false)

RegisterCommand('bg_here_zone', function(_, args)
  if not canBuild() then return notify('No permission (bridgegabz.builder).', 'error') end
  local id = args[1]
  local radius = tonumber(args[2] or '60') or 60.0
  local loc = findLoc(id)
  if not loc then return notify('Unknown location: ' .. tostring(id), 'error') end

  loc.zone = { type = 'sphere', center = GetEntityCoords(PlayerPedId()), radius = radius }
  notify(('Zone set for %s (r=%.1f).'):format(id, radius))
  TriggerEvent('bridge-gabz:client:locationsUpdated', Locations)
end, false)

RegisterCommand('bg_addstaff', function(_, args)
  if not canBuild() then return notify('No permission (bridgegabz.builder).', 'error') end
  local id = args[1]
  local loc = findLoc(id)
  if not loc then return notify('Unknown location: ' .. tostring(id), 'error') end

  local model = args[2]
  local scenario = args[3]
  loc.staff = loc.staff or {}
  table.insert(loc.staff, { pos = cvec4(), model = model or '', scenario = scenario or '' })
  notify(('Added staff point to %s (%d).'):format(id, #loc.staff))
end, false)

RegisterCommand('bg_setentry', function(_, args)
  if not canBuild() then return notify('No permission (bridgegabz.builder).', 'error') end
  local id = args[1]
  local loc = findLoc(id)
  if not loc then return notify('Unknown location: ' .. tostring(id), 'error') end
  ensureVisitorsTable(loc)
  loc.visitors.entry = cvec4()
  notify('Entry set for ' .. id)
end, false)

RegisterCommand('bg_setexit', function(_, args)
  if not canBuild() then return notify('No permission (bridgegabz.builder).', 'error') end
  local id = args[1]
  local loc = findLoc(id)
  if not loc then return notify('Unknown location: ' .. tostring(id), 'error') end
  ensureVisitorsTable(loc)
  loc.visitors.exit = cvec4()
  notify('Exit set for ' .. id)
end, false)

RegisterCommand('bg_addroam', function(_, args)
  if not canBuild() then return notify('No permission (bridgegabz.builder).', 'error') end
  local id = args[1]
  local loc = findLoc(id)
  if not loc then return notify('Unknown location: ' .. tostring(id), 'error') end

  local scenario = args[2]
  ensureVisitorsTable(loc)
  table.insert(loc.visitors.roam, { pos = cvec4(), scenario = scenario or '' })
  notify(('Added roam point to %s (%d).'):format(id, #loc.visitors.roam))
end, false)

RegisterCommand('bg_enable', function(_, args)
  if not canBuild() then return notify('No permission (bridgegabz.builder).', 'error') end
  local id = args[1]
  local v = tonumber(args[2] or '1')
  local loc = findLoc(id)
  if not loc then return notify('Unknown location: ' .. tostring(id), 'error') end
  loc.enabled = (v == 1)
  notify(('Set %s enabled=%s'):format(id, tostring(loc.enabled)))
  TriggerEvent('bridge-gabz:client:locationsUpdated', Locations)
end, false)

RegisterCommand('bg_save', function()
  if not canBuild() then return notify('No permission (bridgegabz.builder).', 'error') end
  TriggerServerEvent('bridge-gabz:server:saveLocations', Locations)
  notify('Saved locations to data/locations.json')
end, false)
