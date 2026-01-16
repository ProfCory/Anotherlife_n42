-- Optional qb-radialmenu integration for aln_makeapal

if not GetResourceState('qb-radialmenu'):find('start') then
  print('[aln_makeapal][qb_radial] qb-radialmenu not running, adapter disabled')
  return
end

CreateThread(function()
  Wait(1000)

  exports['qb-radialmenu']:AddOption({
    id = 'aln_makeapal_root',
    title = 'Make-a-Pal',
    icon = 'users',
    type = 'client',
    event = 'aln_makeapal:client:openMakeMenu',
    shouldClose = true,
  })

  exports['qb-radialmenu']:AddOption({
    id = 'aln_makeapal_roster',
    title = 'Pal Roster',
    icon = 'clipboard-list',
    type = 'client',
    event = 'aln_makeapal:client:openRoster',
    shouldClose = true,
  })

  exports['qb-radialmenu']:AddOption({
    id = 'aln_makeapal_backup',
    title = 'Call Backup',
    icon = 'person-rifle',
    type = 'client',
    event = 'aln_makeapal:client:needBackup',
    shouldClose = true,
  })

  print('[aln_makeapal][qb_radial] Radial menu options registered')
end)
