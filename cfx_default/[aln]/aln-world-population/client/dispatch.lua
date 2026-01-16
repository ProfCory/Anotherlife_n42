ALN = ALN or {}

-- Dispatch services are indexed 1..15 (Rockstar enum).
-- We keep it simple: either leave ambient on, or disable all ambient services here.
-- “Callables” (police/ems/fire/taxi) are handled in aln-services later.

function ALN_WorldPop_ApplyDispatchToggles()
  local d = Config.WorldPop.Dispatch or {}
  local ambient = d.EnableAmbientDispatch == true

  if not ambient and d.DisableAllIfAmbientOff then
    for i = 1, 15 do
      EnableDispatchService(i, false)
    end
    -- also reduce random cop presence for the player
    SetDispatchCopsForPlayer(PlayerId(), false)
  else
    -- If you later want granular toggles, we can add a Dispatch.Enable map.
    SetDispatchCopsForPlayer(PlayerId(), true)
  end

  if Config.WorldPop.Debug then
    ALN.Log.Info('worldpop.dispatch_applied', { ambient = ambient })
  end
end
