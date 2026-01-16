local editing = false
local blockControls = false
local anchors = {}

local function clamp01(v)
  v = tonumber(v) or 0
  if v < 0 then return 0 end
  if v > 1 then return 1 end
  return v
end

local function sendUI(action, data)
  data = data or {}
  data.action = action
  SendNUIMessage(data)
end

local function setEditing(state)
  editing = state
  blockControls = state

  sendUI('setEditing', { enabled = editing, anchors = anchors })

  if editing then
    SetNuiFocus(true, true)
  else
    SetNuiFocus(false, false)
  end
end

exports('RegisterAnchor', function(id, label, pos)
  anchors[id] = { id = id, label = label, x = pos.x, y = pos.y }
end)

RegisterCommand('uilayout', function()
  setEditing(not editing)
end)

RegisterKeyMapping('uilayout', 'UI Layout Editor', 'keyboard', 'F7')

CreateThread(function()
  while true do
    if blockControls then
      DisableAllControlActions(0)
      EnableControlAction(0, 1, true)
      EnableControlAction(0, 2, true)
      EnableControlAction(0, 322, true)
    end
    Wait(0)
  end
end)

RegisterNUICallback('setPos', function(data, cb)
  if anchors[data.id] then
    anchors[data.id].x = clamp01(data.x)
    anchors[data.id].y = clamp01(data.y)
    TriggerEvent('aln_ui_layout:updatePos', data.id, { x = anchors[data.id].x, y = anchors[data.id].y })
  end
  cb('ok')
end)

RegisterNUICallback('save', function(data, cb)
  TriggerServerEvent('aln_ui_layout:save', data.positions)
  setEditing(false)
  cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
  setEditing(false)
  cb('ok')
end)

CreateThread(function()
  exports['aln_ui_layout']:RegisterAnchor('vehicleDash', 'Vehicle Dash', { x = 0.88, y = 0.78 })
  exports['aln_ui_layout']:RegisterAnchor('statusIcons', 'Status Icons', { x = 0.90, y = 0.18 })
end)
