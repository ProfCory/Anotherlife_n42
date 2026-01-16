ALN = ALN or {}
ALN.InventoryAPI = ALN.InventoryAPI or {}

-- Server events (client requests), server validates.
-- v0: no anti-spam throttle yet (can add in aln-admin later).

RegisterNetEvent('aln:inv:addToPockets', function(itemKey, count, meta)
  local src = source
  local ok, res = exports['aln-inventory']:AddToPockets(src, itemKey, count, meta)
  TriggerClientEvent('aln:inv:result', src, { ok = ok, res = res, op = 'addToPockets' })
end)

RegisterNetEvent('aln:inv:removeFromPockets', function(itemKey, count, meta)
  local src = source
  local ok, res = exports['aln-inventory']:RemoveFromPockets(src, itemKey, count, meta)
  TriggerClientEvent('aln:inv:result', src, { ok = ok, res = res, op = 'removeFromPockets' })
end)

RegisterNetEvent('aln:inv:getSnapshot', function(containerId)
  local src = source
  local snap = exports['aln-inventory']:GetSnapshot(src, containerId or 'pockets')
  TriggerClientEvent('aln:inv:snapshot', src, { containerId = containerId or 'pockets', slots = snap })
end)
