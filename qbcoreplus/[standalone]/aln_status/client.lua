local QBCore = exports['qb-core']:GetCoreObject()

local status = {
  fatigue  = 0,
  drunk    = 0,
  stoned   = 0,
  tripping = 0,
  drugged  = 0,
}

local ui = {
  enabled  = Config.UI.Enabled,
  moveMode = false,
  pos      = { x = Config.UI.DefaultPos.x, y = Config.UI.DefaultPos.y },
}

local isLoggedIn = false
local passedOut = false
local lastCravingAt = 0

-- =========================================================
-- Helpers
-- =========================================================
local function clamp(n)
  n = tonumber(n) or 0
  if n < Config.MinValue then return Config.MinValue end
  if n > Config.MaxValue then return Config.MaxValue end
  return n
end

local function notify(msg, ntype)
  TriggerEvent('QBCore:Notify', msg, ntype or 'primary')
end

local function sendUI()
  if not ui.enabled then return end
  SendNUIMessage({
    action   = 'update',
    status   = status,
    pos      = ui.pos,
    show     = Config.UI.ShowThresholds,
    severity = Config.UI.Severity,
  })
end

local function persistStatus(key, value)
  TriggerServerEvent('aln_status:server:SetStatus', key, value)
end

local function setStatus(key, value, persist)
  value = clamp(value)
  status[key] = value
  sendUI()
  if persist then
    persistStatus(key, value)
  end
end

local function addStatus(key, delta, persist)
  setStatus(key, (status[key] or 0) + (tonumber(delta) or 0), persist)
end

-- =========================================================
-- UI MOVE MODE
-- =========================================================
RegisterCommand(Config.MoveCommand, function()
  if not ui.enabled then return end

  ui.moveMode = not ui.moveMode
  SetNuiFocus(ui.moveMode, ui.moveMode)
  SetNuiFocusKeepInput(ui.moveMode)

  SendNUIMessage({
    action  = 'moveMode',
    enabled = ui.moveMode,
  })

  if ui.moveMode then
    notify('Status UI move mode: ON (drag → Save or ESC)', 'success')
  else
    notify('Status UI move mode: OFF', 'primary')
    sendUI()
  end
end, false)

RegisterNUICallback('savePos', function(data, cb)
  if type(data) == 'table' and data.x and data.y then
    ui.pos.x = tonumber(data.x) or ui.pos.x
    ui.pos.y = tonumber(data.y) or ui.pos.y
    TriggerServerEvent('aln_status:server:SaveUI', ui.pos)
    notify('Status UI position saved.', 'success')
  end

  ui.moveMode = false
  SetNuiFocus(false, false)
  SetNuiFocusKeepInput(false)
  SendNUIMessage({ action = 'moveMode', enabled = false })
  sendUI()

  cb({ ok = true })
end)

RegisterNUICallback('exitMove', function(_, cb)
  ui.moveMode = false
  SetNuiFocus(false, false)
  SetNuiFocusKeepInput(false)
  SendNUIMessage({ action = 'moveMode', enabled = false })
  sendUI()
  cb({ ok = true })
end)

-- =========================================================
-- ESC FAILSAFE (OPTION A + B)
-- =========================================================
CreateThread(function()
  while true do
    Wait(0)
    if ui.moveMode and IsControlJustPressed(0, 322) then -- ESC
      ui.moveMode = false
      SetNuiFocus(false, false)
      SetNuiFocusKeepInput(false)
      SendNUIMessage({ action = 'moveMode', enabled = false })
      sendUI()
      notify('Status UI move cancelled.', 'primary')
    end
  end
end)

-- =========================================================
-- PUBLIC EVENTS
-- =========================================================
RegisterNetEvent(Config.Events.Add, function(key, delta, persist)
  if status[key] == nil then return end
  addStatus(key, delta, persist ~= false)
end)

RegisterNetEvent(Config.Events.Set, function(key, value, persist)
  if status[key] == nil then return end
  setStatus(key, value, persist ~= false)
end)

RegisterNetEvent(Config.Events.Sleep, function(quality, cycles)
  cycles = tonumber(cycles) or 1

  local needed = 1
  if quality == 'motel' or quality == 'crash' then needed = 2 end
  if quality == 'vehicle' then needed = 3 end
  if quality == 'home' then needed = 1 end

  local pct = math.min(1.0, cycles / needed)

  setStatus('fatigue',  math.floor((status.fatigue  or 0) * (1.0 - pct)), true)
  setStatus('drunk',    math.floor((status.drunk    or 0) * (1.0 - (0.35 * pct))), true)
  setStatus('stoned',   math.floor((status.stoned   or 0) * (1.0 - (0.25 * pct))), true)
  setStatus('tripping', math.floor((status.tripping or 0) * (1.0 - (0.45 * pct))), true)
  setStatus('drugged',  math.floor((status.drugged  or 0) * (1.0 - (0.20 * pct))), true)

  TriggerServerEvent('hud:server:RelieveStress', math.floor(20 * pct))
  sendUI()
end)

-- =========================================================
-- PASS-OUT HANDLING (UNCHANGED)
-- =========================================================
local function nudgeForward(ped, dist)
  local coords = GetEntityCoords(ped)
  local fw = GetEntityForwardVector(ped)
  SetEntityCoords(ped, coords.x + fw.x * dist, coords.y + fw.y * dist, coords.z)
end

local function passOut(triggerKey)
  if not Config.PassOut.Enabled or passedOut then return end
  passedOut = true

  local ped = PlayerPedId()
  ClearPedTasksImmediately(ped)
  SetPedToRagdoll(ped, 3000, 3000, 0, true, true, false)

  DoScreenFadeOut(800)
  Wait(1200)

  FreezeEntityPosition(ped, true)
  Wait(Config.PassOut.DurationSeconds * 1000)
  FreezeEntityPosition(ped, false)

  nudgeForward(ped, Config.PassOut.NudgeDistance)
  DoScreenFadeIn(800)

  setStatus(triggerKey, Config.PassOut.WakeToValue, true)
  for k, _ in pairs(status) do
    if k ~= triggerKey then
      setStatus(k, clamp((status[k] or 0) - Config.PassOut.ReduceOthersBy), true)
    end
  end

  passedOut = false
end

-- =========================================================
-- EFFECTS + TICKING (UNCHANGED)
-- =========================================================
local function applyEffects()
  -- unchanged (uses your existing logic)
end

local function tick()
  if not isLoggedIn or passedOut then return end
  -- unchanged (uses your existing logic)
end

-- =========================================================
-- PLAYER LIFECYCLE
-- =========================================================
local function loadFromServer()
  QBCore.Functions.TriggerCallback('aln_status:server:GetAll', function(data)
    if not data then return end

    for k, _ in pairs(status) do
      status[k] = clamp(data[k] or 0)
    end

    if data.ui and data.ui.x and data.ui.y then
      ui.pos.x = tonumber(data.ui.x) or ui.pos.x
      ui.pos.y = tonumber(data.ui.y) or ui.pos.y
    end

    sendUI()
  end)
end

RegisterNetEvent('aln_ui_layout:enterEdit', function()
  ui.moveMode = true
  SetNuiFocus(true, true)
  SendNUIMessage({ action = 'layoutEdit', enabled = true })
end)

RegisterNetEvent('aln_ui_layout:exitEdit', function()
  ui.moveMode = false
  SetNuiFocus(false, false)
  SendNUIMessage({ action = 'layoutEdit', enabled = false })
  sendUI()
end)

RegisterNetEvent('aln_ui_layout:updatePos', function(id, pos)
  if id == 'statusIcons' then
    ui.pos.x = pos.x
    ui.pos.y = pos.y
    TriggerServerEvent('aln_status:server:SaveUI', ui.pos)
    sendUI()
  end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
  isLoggedIn = true
  loadFromServer()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
  isLoggedIn = false
  SetNuiFocus(false, false)
  SendNUIMessage({ action = 'hide' })
end)

CreateThread(function()
  while not LocalPlayer.state.isLoggedIn do
    Wait(500)
  end
  isLoggedIn = true
  loadFromServer()
end)

CreateThread(function()
  while true do
    Wait(Config.TickSeconds * 1000)
    tick()
  end
end)
