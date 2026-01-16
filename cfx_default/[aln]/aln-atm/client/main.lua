ALN = ALN or {}

local uiId = 'aln.atm'
local token = nil

local function dbg(ev, f)
  if Config and Config.ATM and Config.ATM.Debug then
    ALN.Log.Debug(ev, f or {})
  end
end

local function openATM(locationId)
  if token then return end
  token = exports['aln-ui-focus']:Acquire(uiId, { cursor = true, keepInput = true })
  if not token then
    dbg('atm.open_denied', { locationId = locationId })
    return
  end

  TriggerServerEvent('aln:atm:requestSnapshot', locationId)
end

local function closeATM()
  if not token then return end
  exports['aln-ui-focus']:Release(uiId, token)
  token = nil
  SendNUIMessage({ type = 'atm_close' })
end

-- Register UI with focus manager
CreateThread(function()
  exports['aln-ui-focus']:Register(uiId, {
    allowOverlap = false,
    allowStack = false,
    keepInput = true,
    nuiCloseMsgType = 'atm_close_request',
    onCloseEvent = 'aln:atm:closeRequested',
  })
end)

RegisterNetEvent('aln:atm:closeRequested', function()
  closeATM()
end)

-- Keybind: E to use when near ATM
CreateThread(function()
  while true do
    local near = exports['aln-atm']:GetNearbyATM()
    if near and not token then
      -- minimal help text
      BeginTextCommandDisplayHelp('STRING')
      AddTextComponentSubstringPlayerName('Press ~INPUT_CONTEXT~ to use ATM')
      EndTextCommandDisplayHelp(0, false, true, 1)

      if IsControlJustReleased(0, 38) then -- E
        openATM(near)
      end
      Wait(0)
    else
      Wait(200)
    end
  end
end)

-- Receive balances + card status
RegisterNetEvent('aln:atm:snapshot', function(payload)
  if not token then return end
  SendNUIMessage({
    type = 'atm_open',
    token = token,
    cash = payload.cash or 0,
    bank = payload.bank or 0,
    hasCard = payload.hasCard == true,
    cardCost = payload.cardCost or 100
  })
end)

-- NUI callbacks
RegisterNUICallback('atm_close', function(_, cb)
  closeATM()
  cb({ ok = true })
end)

RegisterNUICallback('atm_buy_card', function(_, cb)
  TriggerServerEvent('aln:atm:buyCard')
  cb({ ok = true })
end)

RegisterNUICallback('atm_deposit', function(data, cb)
  TriggerServerEvent('aln:atm:deposit', tonumber(data.amount) or 0)
  cb({ ok = true })
end)

RegisterNUICallback('atm_withdraw', function(data, cb)
  TriggerServerEvent('aln:atm:withdraw', tonumber(data.amount) or 0)
  cb({ ok = true })
end)

-- Server pushes balance updates after actions
RegisterNetEvent('aln:atm:update', function(payload)
  if not token then return end
  SendNUIMessage({
    type = 'atm_update',
    cash = payload.cash or 0,
    bank = payload.bank or 0,
    hasCard = payload.hasCard == true,
  })
end)
