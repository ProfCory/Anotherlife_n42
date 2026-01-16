local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('aln_sleep:server:tryPay', function(source, cb, amount)
  local Player = QBCore.Functions.GetPlayer(source)
  if not Player then cb(false) return end

  amount = tonumber(amount) or 0
  if amount <= 0 then cb(false) return end

  local money = Player.Functions.GetMoney(Config.PayAccount)
  if money < amount then
    cb(false)
    return
  end

  Player.Functions.RemoveMoney(Config.PayAccount, amount, 'sleep')
  cb(true)
end)
