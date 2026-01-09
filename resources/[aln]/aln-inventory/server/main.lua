ALN = ALN or {}

AddEventHandler('onResourceStart', function(resName)
  if resName ~= GetCurrentResourceName() then return end
  ALN.Log.Info('inventory.start', { useDB = Config.Inventory.UseDB == true })
end)

-- Console-only helpers (testing without UI)
RegisterCommand('aln_inv_give', function(src, args)
  if src ~= 0 then return end
  local playerSrc = tonumber(args[1] or 0) or 0
  local item = tostring(args[2] or '')
  local count = tonumber(args[3] or 1) or 1
  if playerSrc <= 0 or item == '' then
    print('usage: aln_inv_give <src> <itemKey> <count>')
    return
  end
  local ok, res = exports['aln-inventory']:AddToPockets(playerSrc, item, count, nil)
  print('[ALN3] give => ok=' .. tostring(ok) .. ' res=' .. (type(res)=='table' and json.encode(res) or tostring(res)))
end, true)

RegisterCommand('aln_inv_take', function(src, args)
  if src ~= 0 then return end
  local playerSrc = tonumber(args[1] or 0) or 0
  local item = tostring(args[2] or '')
  local count = tonumber(args[3] or 1) or 1
  if playerSrc <= 0 or item == '' then
    print('usage: aln_inv_take <src> <itemKey> <count>')
    return
  end
  local ok, res = exports['aln-inventory']:RemoveFromPockets(playerSrc, item, count, nil)
  print('[ALN3] take => ok=' .. tostring(ok) .. ' res=' .. (type(res)=='table' and json.encode(res) or tostring(res)))
end, true)

RegisterCommand('aln_inv_dump', function(src, args)
  if src ~= 0 then return end
  local playerSrc = tonumber(args[1] or 0) or 0
  local containerId = tostring(args[2] or 'pockets')
  if playerSrc <= 0 then
    print('usage: aln_inv_dump <src> [containerId]')
    return
  end
  local snap = exports['aln-inventory']:GetSnapshot(playerSrc, containerId)
  print('[ALN3] dump ' .. containerId .. ': ' .. json.encode(snap))
end, true)
