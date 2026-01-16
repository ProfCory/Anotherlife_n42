ALN = ALN or {}
ALN.Admin = ALN.Admin or {}

AddEventHandler('onResourceStart', function(res)
  if res ~= GetCurrentResourceName() then return end
  ALN.Log.Info('admin.start', { ace = Config.Admin.RequiredAce })
end)

-- ========== Core admin commands ==========

RegisterCommand('aln_admin_ping', function(src)
  if not ALN.Admin.IsAllowed(src) then return ALN.Admin.Deny(src) end
  ALN.Admin.Print(src, '[ALN3] admin ok')
end, false)

-- Dump baseline status for a player src
RegisterCommand('aln_admin_status', function(src, args)
  if not ALN.Admin.IsAllowed(src) then return ALN.Admin.Deny(src) end
  local target = tonumber(args[1] or src) or src
  if target == 0 then
    ALN.Admin.Print(src, 'usage: aln_admin_status <playerSrc>')
    return
  end
  local rep = ALN.Admin.Baseline.Report(target)
  ALN.Admin.J(src, rep)
end, false)

-- Force set active character slot (1..3) for a player
RegisterCommand('aln_admin_setslot', function(src, args)
  if not ALN.Admin.IsAllowed(src) then return ALN.Admin.Deny(src) end
  local target = tonumber(args[1] or 0) or 0
  local slot = tonumber(args[2] or 1) or 1
  if target <= 0 then
    ALN.Admin.Print(src, 'usage: aln_admin_setslot <playerSrc> <slot>')
    return
  end
  local ok, res = exports['aln-persistent-data']:SetActiveSlot(target, slot)
  ALN.Admin.J(src, { ok = ok, res = res })
end, false)

-- Give an item to pockets
RegisterCommand('aln_admin_give', function(src, args)
  if not ALN.Admin.IsAllowed(src) then return ALN.Admin.Deny(src) end
  local target = tonumber(args[1] or 0) or 0
  local item = tostring(args[2] or '')
  local count = tonumber(args[3] or 1) or 1
  if target <= 0 or item == '' then
    ALN.Admin.Print(src, 'usage: aln_admin_give <playerSrc> <itemKey> [count]')
    return
  end
  local ok, res = exports['aln-inventory']:AddToPockets(target, item, count, nil)
  ALN.Admin.J(src, { ok = ok, res = res })
end, false)

-- Add money to a wallet (cash/bank/dirty)
RegisterCommand('aln_admin_money', function(src, args)
  if not ALN.Admin.IsAllowed(src) then return ALN.Admin.Deny(src) end
  local target = tonumber(args[1] or 0) or 0
  local account = tostring(args[2] or 'cash')
  local amt = tonumber(args[3] or 0) or 0
  if target <= 0 or amt == 0 then
    ALN.Admin.Print(src, 'usage: aln_admin_money <playerSrc> <cash|bank|dirty> <amount>')
    return
  end
  if amt > 0 then
    local ok = exports['aln-economy']:Credit(target, account, math.floor(amt), 'admin.credit', {})
    ALN.Admin.J(src, { ok = ok, account = account, amount = amt })
  else
    local ok = exports['aln-economy']:Debit(target, account, math.abs(math.floor(amt)), 'admin.debit', {})
    ALN.Admin.J(src, { ok = ok, account = account, amount = amt })
  end
end, false)

-- Trigger services (police/ems/fire/taxi) for a player
RegisterCommand('aln_admin_service', function(src, args)
  if not ALN.Admin.IsAllowed(src) then return ALN.Admin.Deny(src) end
  local target = tonumber(args[1] or 0) or 0
  local svc = tostring(args[2] or '')
  if target <= 0 or svc == '' then
    ALN.Admin.Print(src, 'usage: aln_admin_service <playerSrc> <police|ems|fire|taxi>')
    return
  end
  local ok, res = exports['aln-services']:RequestService(target, svc, {})
  ALN.Admin.J(src, { ok = ok, res = res })
end, false)

-- Run a sample DC check for a player
RegisterCommand('aln_admin_dc', function(src, args)
  if not ALN.Admin.IsAllowed(src) then return ALN.Admin.Deny(src) end
  local target = tonumber(args[1] or 0) or 0
  local actionId = tostring(args[2] or 'vehicle.hotwire')
  if target <= 0 then
    ALN.Admin.Print(src, 'usage: aln_admin_dc <playerSrc> <actionId>')
    return
  end
  local ok, res = exports['aln-minigame']:DoCheck(target, actionId, { wantedStars = 0, vehicleClass = 6, value = 60000 })
  ALN.Admin.J(src, { ok = ok, res = res })
end, false)
