ALN = ALN or {}

AddEventHandler('onClientResourceStart', function(resName)
  if resName ~= GetCurrentResourceName() then return end
  ALN.Log.Info('core.client_start', { resource = resName })
end)
