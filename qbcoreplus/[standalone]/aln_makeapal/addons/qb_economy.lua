-- Optional QBCore economy adapter for aln_makeapal
-- Safe to remove at any time

if not GetResourceState('qb-core'):find('start') then
  print('[aln_makeapal][qb_economy] qb-core not running, adapter disabled')
  return
end

local QBCore = exports['qb-core']:GetCoreObject()
local ACCOUNT = 'cash' -- change to 'bank' if desired

-- Override GetMoney export
exports('GetMoney', function(src)
  local Player = QBCore.Functions.GetPlayer(src)
  if not Player then return 0 end
  return Player.Functions.GetMoney(ACCOUNT) or 0
end)

-- Override RemoveMoney export
exports('RemoveMoney', function(src, amount)
  local Player = QBCore.Functions.GetPlayer(src)
  if not Player then return false end
  amount = math.floor(amount)
  if amount <= 0 then return true end

  local has = Player.Functions.GetMoney(ACCOUNT) or 0
  if has < amount then return false end

  Player.Functions.RemoveMoney(ACCOUNT, amount, 'make-a-pal-hire')
  return true
end)

print('[aln_makeapal][qb_economy] QBCore economy adapter active')
