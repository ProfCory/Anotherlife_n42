ALN = ALN or {}
ALN.Admin = ALN.Admin or {}
ALN.Admin.Baseline = ALN.Admin.Baseline or {}

local function idKey(src)
  return exports['aln-persistent-data']:GetActiveIdentityKey(src)
end

function ALN.Admin.Baseline.Report(src)
  local out = {
    src = src,
    identityKey = idKey(src),
    charId = exports['aln-persistent-data']:GetActiveCharacterId(src),

    economy = {},
    inventory = {},
    criminal = {},
  }

  -- Economy snapshot
  local k = out.identityKey
  if k then
    out.economy.cash  = exports['aln-economy']:GetBalance(k, 'cash')
    out.economy.bank  = exports['aln-economy']:GetBalance(k, 'bank')
    out.economy.dirty = exports['aln-economy']:GetBalance(k, 'dirty')
  end

  -- Inventory snapshot (pockets)
  local pockets = exports['aln-inventory']:GetSnapshot(src, 'pockets') or {}
  local items = {}
  for slot, v in pairs(pockets) do
    if v then
      items[#items+1] = { slot = slot, item = v.item, count = v.count, meta = v.meta }
    end
  end
  table.sort(items, function(a,b) return a.slot < b.slot end)
  out.inventory.pockets = items

  -- Criminal
  local lvl, mod, xp = exports['aln-criminal-xp']:GetLevel(src)
  out.criminal = { level = lvl, mod = mod, xp = xp }

  return out
end
