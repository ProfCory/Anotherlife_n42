ALN = ALN or {}

AddEventHandler('onResourceStart', function(resName)
  if resName ~= GetCurrentResourceName() then return end
  ALN.Log.Info('loot.start', {})
end)

-- Dev console helper (server console only)
RegisterCommand('aln_loot_test', function(src, args)
  if src ~= 0 then return end
  local poolId = args[1] or 'npc.civilian.pockets'
  local results, reason = exports['aln-loot']:Roll(poolId, { playerKey = 'test', entityNetId = 123 })
  print('[ALN3] loot test pool=' .. poolId .. ' reason=' .. tostring(reason))
  if results then
    for i, r in ipairs(results) do
      print(('  %d) %s x%d meta=%s'):format(i, r.item, r.count, json.encode(r.meta or {})))
    end
  end
end, true)
