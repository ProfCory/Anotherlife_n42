local function nearbyPlayersOf(source, radius)
  local list = {}
  local srcPed = GetPlayerPed(source)
  if not DoesEntityExist(srcPed) then return list end
  local srcCoords = GetEntityCoords(srcPed)
  for _, id in ipairs(GetPlayers()) do
    local ped = GetPlayerPed(id)
    if DoesEntityExist(ped) then
      local dist = #(GetEntityCoords(ped) - srcCoords)
      if dist <= radius then table.insert(list, id) end
    end
  end
  return list
end

RegisterNetEvent('bg3_dice:roll')
AddEventHandler('bg3_dice:roll', function(raw, modifier, total, dc, mode, meta)
  local src = source
  local name = GetPlayerName(src)
  if Config.BroadcastToNearby then
    local targets = nearbyPlayersOf(src, Config.BroadcastRadius)
    for _, id in ipairs(targets) do
      TriggerClientEvent('bg3_dice:broadcast', id, name, raw, modifier, total, dc, mode)
    end
  else
    TriggerClientEvent('bg3_dice:broadcast', -1, name, raw, modifier, total, dc, mode)
  end
end)


RegisterNetEvent('bg3_dice:started', function(r1, r2, raw, modifier, dc, mode, meta)
  local src = source
  local name = GetPlayerName(src)
  TriggerEvent('bg3_dice:onRollStart', src, name, { r1 = r1, r2 = r2, raw = raw, modifier = modifier, dc = dc, mode = mode, meta = meta })
end)

RegisterNetEvent('bg3_dice:ended', function(success, total, raw, dc, modifier, mode, meta)
  local src = source
  local name = GetPlayerName(src)
  TriggerEvent('bg3_dice:onRollEnd', src, name, { success = success, total = total, raw = raw, dc = dc, modifier = modifier, mode = mode, meta = meta })
  if raw == 20 then TriggerEvent('bg3_dice:onNat20', src, name, { dc = dc, modifier = modifier, mode = mode, meta = meta }) end
  if raw == 1 then TriggerEvent('bg3_dice:onNat1', src, name, { dc = dc, modifier = modifier, mode = mode, meta = meta }) end
end)
