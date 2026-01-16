ALN = ALN or {}

AddEventHandler('onResourceStart', function(res)
  if res ~= GetCurrentResourceName() then return end
  ALN.Log.Info('carjack.start', {})
end)
