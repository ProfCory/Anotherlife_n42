-- Simple bridge so qb-radialmenu can call Make-a-Pal features via client events.

RegisterNetEvent('aln_makeapal:client:openMakeMenu', function()
  -- triggers the same menu as pressing E
  if _G and _G.openMakePalMenu then
    _G.openMakePalMenu()
  else
    -- fallback: trigger server roster then menu from there
    TriggerServerEvent("aln_makeapal:server:getRoster")
    lib.notify({ type='inform', description='Use /pals to open roster if menu function not found.' })
  end
end)

RegisterNetEvent('aln_makeapal:client:openRoster', function()
  TriggerServerEvent("aln_makeapal:server:getRoster")
end)

RegisterNetEvent('aln_makeapal:client:needBackup', function()
  TriggerServerEvent("aln_makeapal:server:needBackup")
end)
