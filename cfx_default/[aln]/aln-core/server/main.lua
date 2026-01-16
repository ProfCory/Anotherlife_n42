ALN = ALN or {}

AddEventHandler('onResourceStart', function(resName)
  if resName ~= GetCurrentResourceName() then return end

  ALN.Log.Info('core.start', {
    resource = resName,
    debug = (Config and Config.Core and Config.Core.Debug) or false,
  })

  -- Core has no heavy init yet; mark ready next tick.
  -- Other resources can wait on exports('IsReady') / exports('OnReady').
  CreateThread(function()
    Wait(0)
    ALN.Core._SetReady()
  end)
end)

AddEventHandler('playerJoining', function(oldId)
  local src = source
  local key = ALN.Identity.GetPlayerKey(src)
  ALN.Log.Info('player.joining', { src = src, playerKey = key, oldId = oldId })
end)

AddEventHandler('playerDropped', function(reason)
  local src = source
  local key = ALN.Identity.GetPlayerKey(src)
  ALN.Log.Info('player.dropped', { src = src, playerKey = key, reason = reason })
end)

-- Export: stable player key
exports('GetPlayerKey', function(src)
  return ALN.Identity.GetPlayerKey(src)
end)

exports('GetIdentifiers', function(src)
  return ALN.Identity.GetIdentifiers(src)
end)
