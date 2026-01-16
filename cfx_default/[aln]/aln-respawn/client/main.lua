ALN = ALN or {}

local uiId = 'aln.respawn'
local token = nil
local armed = nil
local isDead = false
local lastDeathTs = 0

local function dbg(ev, f)
  if Config.Respawn.Debug then
    ALN.Log.Debug(ev, f or {})
  end
end

local function openTimerUI(seconds, label)
  if token then return end
  token = exports['aln-ui-focus']:Acquire(uiId, { cursor = false, keepInput = true })
  -- If focus manager denies, we still function; UI is optional in v0.
  dbg('respawn.ui_open', { seconds = seconds, label = label })
end

local function closeTimerUI()
  if not token then return end
  exports['aln-ui-focus']:Release(uiId, token)
  token = nil
  dbg('respawn.ui_close', {})
end

-- Simple on-screen text (no NUI yet)
local function drawText(msg)
  SetTextFont(4)
  SetTextProportional(0)
  SetTextScale(0.45, 0.45)
  SetTextColour(255, 255, 255, 220)
  SetTextOutline()
  BeginTextCommandDisplayText('STRING')
  AddTextComponentSubstringPlayerName(msg)
  EndTextCommandDisplayText(0.5, 0.85)
end

-- Register with focus manager so ESC can close any future UI overlay
CreateThread(function()
  exports['aln-ui-focus']:Register(uiId, {
    allowOverlap = false,
    allowStack = false,
    keepInput = true,
    nuiCloseMsgType = nil,
    onCloseEvent = nil,
  })
end)

-- Death detection loop (solo friendly)
CreateThread(function()
  while true do
    local ped = PlayerPedId()
    if ped ~= 0 then
      local dead = IsEntityDead(ped)
      if dead and not isDead then
        isDead = true
        lastDeathTs = GetGameTimer()

        local coords = GetEntityCoords(ped)
        local stars = GetPlayerWantedLevel(PlayerId())

        TriggerServerEvent('aln:respawn:request', {
          coords = { x = coords.x, y = coords.y, z = coords.z },
          wantedStars = stars
        })

        dbg('respawn.death_detected', { stars = stars })
      elseif (not dead) and isDead then
        -- If something revived us outside the system
        isDead = false
        armed = nil
        closeTimerUI()
      end
    end
    Wait(250)
  end
end)

RegisterNetEvent('aln:respawn:armed', function(payload)
  armed = payload
  openTimerUI(payload.timer, payload.endpoint and payload.endpoint.label or 'Respawn')
  dbg('respawn.armed_client', payload)

  CreateThread(function()
    local remaining = tonumber(payload.timer or 0) or 0
    while armed == payload and remaining > 0 do
      local ped = PlayerPedId()
      if ped ~= 0 and IsEntityDead(ped) then
        drawText(('Respawn in ~y~%ds~s~  (%s)'):format(remaining, payload.endpoint.label or 'Service'))
      end
      Wait(1000)
      remaining = remaining - 1
    end

    if armed == payload then
      -- Allow player to commit respawn (auto-commit)
      TriggerServerEvent('aln:respawn:commit', {
        endpoint = payload.endpoint,
        wantedStars = payload.wantedStars,
        heading = 0.0,
      })
    end
  end)
end)

RegisterNetEvent('aln:respawn:denied', function(payload)
  dbg('respawn.denied', payload or {})
end)

RegisterNetEvent('aln:respawn:do', function(payload)
  closeTimerUI()

  local ped = PlayerPedId()
  DoScreenFadeOut(400)
  while not IsScreenFadedOut() do Wait(10) end

  local c = payload.coords
  local x, y, z = c.x, c.y, c.z
  local h = payload.heading or 0.0

  -- Resurrect / revive
  NetworkResurrectLocalPlayer(x, y, z, h, true, true, false)
  ClearPedTasksImmediately(ped)
  SetEntityHealth(ped, 200)
  ClearPedBloodDamage(ped)

  if payload.clearWanted then
    ClearPlayerWantedLevel(PlayerId())
  end

  DoScreenFadeIn(600)
  isDead = false
  armed = nil

  dbg('respawn.completed_client', payload)
end)
