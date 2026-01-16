ALN = ALN or {}

local uiId = 'aln.carjack'
local token = nil

local function dbg(ev, f)
  if Config.Carjack.Debug then
    print('[ALN3][carjack] ' .. ev .. (f and (' ' .. json.encode(f)) or ''))
  end
end

local function acquire()
  if token then return true end
  token = exports['aln-ui-focus']:Acquire(uiId, { cursor=false, keepInput=true })
  return token ~= nil
end

local function release()
  if token then
    exports['aln-ui-focus']:Release(uiId, token)
    token = nil
  end
end

CreateThread(function()
  exports['aln-ui-focus']:Register(uiId, { allowOverlap=false, allowStack=false, keepInput=true })
end)

local function drawHelp(msg)
  BeginTextCommandDisplayHelp('STRING')
  AddTextComponentSubstringPlayerName(msg)
  EndTextCommandDisplayHelp(0, false, true, 1)
end

local function drawCenter(text)
  SetTextFont(4)
  SetTextScale(0.45, 0.45)
  SetTextColour(255,255,255,220)
  SetTextCentre(true)
  SetTextOutline()
  BeginTextCommandDisplayText('STRING')
  AddTextComponentSubstringPlayerName(text)
  EndTextCommandDisplayText(0.5, 0.45)
end

local function getVehicleInFront(ped)
  local p = GetEntityCoords(ped)
  local f = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
  local ray = StartShapeTestRay(p.x, p.y, p.z+0.3, f.x, f.y, f.z, 10, ped, 0)
  local _, hit, _, _, ent = GetShapeTestResult(ray)
  if hit == 1 and ent and ent ~= 0 and IsEntityAVehicle(ent) then
    return ent
  end
  return nil
end

local function vehicleCtx(veh)
  local class = GetVehicleClass(veh)
  local model = GetEntityModel(veh)
  -- value is not auto-known; we pass 0 for now (later aln-vehicles can provide bluebook)
  return {
    vehicleClass = class,
    value = 0,
    model = model,
  }
end

-- Track vehicles we’ve “stolen” and whether they’re hotwired
local stolen = {} -- netId -> { hotwired=true/false }

local function netId(ent)
  if not NetworkGetEntityIsNetworked(ent) then
    NetworkRegisterEntityAsNetworked(ent)
  end
  return NetworkGetNetworkIdFromEntity(ent)
end

local function ensureLockedBehavior()
  if not Config.Carjack.LockParkedVehicles then return end
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsTryingToEnter(ped)
  if veh and veh ~= 0 then
    -- If it's not yours/mission: keep locked
    SetVehicleDoorsLocked(veh, 2) -- locked
  end
end

-- Simple choice menu: Smash or Lockpick (if available)
local function chooseEntryMethod(hasLockpick)
  if not acquire() then return nil end
  local idx = 1
  local opts = { { key='smash', label='Smash Window' } }
  if hasLockpick then
    opts[#opts+1] = { key='lockpick', label='Lockpick Door' }
  end

  while true do
    DisableAllControlActions(0)
    EnableControlAction(0, 172, true) -- up
    EnableControlAction(0, 173, true) -- down
    EnableControlAction(0, 191, true) -- enter
    EnableControlAction(0, 202, true) -- back

    if IsControlJustReleased(0, 172) then idx = idx - 1 end
    if IsControlJustReleased(0, 173) then idx = idx + 1 end
    if idx < 1 then idx = #opts end
    if idx > #opts then idx = 1 end

    drawCenter(('Vehicle Entry\n\n~y~%s~s~\n\n~c~Up/Down • Enter • Back~s~'):format(opts[idx].label))

    if IsControlJustReleased(0, 202) then
      release()
      return nil
    end
    if IsControlJustReleased(0, 191) then
      local choice = opts[idx].key
      release()
      return choice
    end

    Wait(0)
  end
end

local pending = nil

RegisterNetEvent('aln:minigame:result', function(payload)
  -- We only handle results if we initiated a check.
  if not pending then return end
  local p = pending
  pending = nil

  if not payload or payload.ok ~= true then
    dbg('check_failed', payload)
    return
  end

  local res = payload.res
  if type(res) ~= 'table' then return end

  if p.kind == 'entry' then
    if res.success then
      -- unlock and enter
      SetVehicleDoorsLocked(p.veh, 1)
      TaskEnterVehicle(PlayerPedId(), p.veh, 6000, -1, 1.0, 1, 0)
      -- mark stolen/hotwire required
      local id = netId(p.veh)
      stolen[id] = stolen[id] or { hotwired = false }
      dbg('entry_success', { action = p.actionId, id = id })
    else
      -- keep locked; smash could still unlock as partial, but we keep it simple v0
      dbg('entry_fail', { action = p.actionId })
    end
    return
  end

  if p.kind == 'hotwire' then
    local id = netId(p.veh)
    stolen[id] = stolen[id] or { hotwired = false }

    if res.success then
      stolen[id].hotwired = true
      SetVehicleEngineOn(p.veh, true, true, false)
      SetVehicleUndriveable(p.veh, false)
      dbg('hotwire_success', { id = id })
    else
      -- keep engine disabled
      SetVehicleEngineOn(p.veh, false, true, true)
      SetVehicleUndriveable(p.veh, true)
      dbg('hotwire_fail', { id = id })
    end
  end
end)

-- Main loop:
-- - keep parked vehicles locked
-- - when player enters a “stolen not-hotwired” vehicle, kill engine and prompt hotwire
CreateThread(function()
  while true do
    ensureLockedBehavior()

    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 and Config.Carjack.RequireHotwire then
      local id = netId(veh)
      if stolen[id] and stolen[id].hotwired ~= true then
        -- disable engine until hotwired
        SetVehicleEngineOn(veh, false, true, true)
        SetVehicleUndriveable(veh, true)

        drawHelp('Press ~INPUT_CONTEXT~ to hotwire')
        if IsControlJustReleased(0, 38) and not pending then
          local ctx = vehicleCtx(veh)
          pending = { kind='hotwire', veh=veh, actionId='vehicle.hotwire' }
          TriggerServerEvent('aln:minigame:doCheck', 'vehicle.hotwire', {
            wantedStars = GetPlayerWantedLevel(PlayerId()),
            vehicleClass = ctx.vehicleClass,
            value = ctx.value,
          })
        end
        Wait(0)
      else
        Wait(150)
      end
    else
      Wait(150)
    end
  end
end)

-- “E near locked vehicle” to attempt entry
CreateThread(function()
  while true do
    local ped = PlayerPedId()
    if ped == 0 then Wait(500) goto continue end
    if IsPedInAnyVehicle(ped, false) then Wait(500) goto continue end

    local veh = getVehicleInFront(ped)
    if veh and veh ~= 0 then
      local p = GetEntityCoords(ped)
      local v = GetEntityCoords(veh)
      if #(p - v) <= (Config.Carjack.UseDist or 2.0) then
        local locked = GetVehicleDoorLockStatus(veh)
        if locked == 2 or locked == 4 then
          drawHelp('Press ~INPUT_CONTEXT~ to attempt entry')
          if IsControlJustReleased(0, 38) and not pending then
            -- tool check (server-side accurate) — but for menu we do a local best-effort:
            -- we’ll ask tools export via server? keeping v0 simple:
            local hasLockpick = true -- optimistic; menu will still work if you choose lockpick and server tool_required fails
            local choice = chooseEntryMethod(hasLockpick)
            if not choice then goto continue end

            local actionId = (choice == 'lockpick') and 'vehicle.entry.lockpick' or 'vehicle.entry.smash'
            local ctx = vehicleCtx(veh)

            pending = { kind='entry', veh=veh, actionId=actionId }
            TriggerServerEvent('aln:minigame:doCheck', actionId, {
              wantedStars = GetPlayerWantedLevel(PlayerId()),
              vehicleClass = ctx.vehicleClass,
              value = ctx.value,
            })
          end
          Wait(0)
        else
          Wait(200)
        end
      else
        Wait(200)
      end
    else
      Wait(300)
    end
    ::continue::
  end
end)
