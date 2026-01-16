ALN = ALN or {}
ALN.CriminalUnlocks = ALN.CriminalUnlocks or {}

function ALN.CriminalUnlocks.Has(src, key)
  key = tostring(key or '')
  local gate = (Config.CriminalUnlocks.LevelGates or {})[key]
  if not gate then return false end
  local lvl = select(1, exports['aln-criminal-xp']:GetLevel(src))
  return (tonumber(lvl) or 1) >= (tonumber(gate) or 99)
end

function ALN.CriminalUnlocks.ListAvailable(src)
  local lvl = select(1, exports['aln-criminal-xp']:GetLevel(src))
  local out = {}
  for k, gate in pairs(Config.CriminalUnlocks.LevelGates or {}) do
    if (tonumber(lvl) or 1) >= (tonumber(gate) or 99) then
      out[#out+1] = k
    end
  end
  table.sort(out)
  return out
end

exports('Has', function(src, key) return ALN.CriminalUnlocks.Has(src, key) end)
exports('ListAvailable', function(src) return ALN.CriminalUnlocks.ListAvailable(src) end)
