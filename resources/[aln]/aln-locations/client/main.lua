ALN = ALN or {}

AddEventHandler('onClientResourceStart', function(resName)
  if resName ~= GetCurrentResourceName() then return end
  ALN.Log.Info('locations.client_start', {})
  CreateThread(function()
    Wait(500)
    ALN_Locations_SpawnBlips()
  end)
end)

RegisterCommand('aln_loc_blips_reload', function()
  ALN_Locations_SpawnBlips()
end, false)
