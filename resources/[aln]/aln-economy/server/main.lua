ALN = ALN or {}

AddEventHandler('onResourceStart', function(resName)
  if resName ~= GetCurrentResourceName() then return end
  ALN.Log.Info('economy.start', { inMemory = Config.Economy.InMemoryMode == true })
end)

-- Simple console-only tests (ACE gating later in aln-admin)
RegisterCommand('aln_money_get', function(src, args)
  if src ~= 0 then return end
  local playerSrc = tonumber(args[1] or 0) or 0
  if playerSrc <= 0 then print('usage: aln_money_get <src>'); return end
  local idKey = exports['aln-economy']:GetIdentityKey(playerSrc)
  local cash = exports['aln-economy']:GetBalance(idKey, 'cash')
  local bank = exports['aln-economy']:GetBalance(idKey, 'bank')
  local dirty = exports['aln-economy']:GetBalance(idKey, 'dirty')
  print(('[ALN3] %s cash=%d bank=%d dirty=%d'):format(idKey, cash, bank, dirty))
end, true)

RegisterCommand('aln_money_add', function(src, args)
  if src ~= 0 then return end
  local playerSrc = tonumber(args[1] or 0) or 0
  local account = tostring(args[2] or 'cash')
  local amt = tonumber(args[3] or 0) or 0
  if playerSrc <= 0 then print('usage: aln_money_add <src> <cash|bank|dirty> <amt>'); return end
  local ok, res = exports['aln-economy']:Credit(playerSrc, account, amt, 'console_add', { by='console' })
  print('[ALN3] add => ok=' .. tostring(ok) .. ' res=' .. (type(res)=='table' and json.encode(res) or tostring(res)))
end, true)

RegisterCommand('aln_money_take', function(src, args)
  if src ~= 0 then return end
  local playerSrc = tonumber(args[1] or 0) or 0
  local account = tostring(args[2] or 'cash')
  local amt = tonumber(args[3] or 0) or 0
  if playerSrc <= 0 then print('usage: aln_money_take <src> <cash|bank|dirty> <amt>'); return end
  local ok, res = exports['aln-economy']:Debit(playerSrc, account, amt, 'console_take', { by='console' })
  print('[ALN3] take => ok=' .. tostring(ok) .. ' res=' .. (type(res)=='table' and json.encode(res) or tostring(res)))
end, true)
