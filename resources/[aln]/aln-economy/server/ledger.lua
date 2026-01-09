ALN = ALN or {}
ALN.Economy = ALN.Economy or {}

-- In-memory ledger for now (last N entries)
local ledger = {}
local maxEntries = 2000

local function push(entry)
  ledger[#ledger+1] = entry
  if #ledger > maxEntries then
    table.remove(ledger, 1)
  end
end

function ALN.Economy.LedgerAdd(entry)
  push(entry)
  TriggerEvent(ALN.Economy.Events.Ledger, entry)
end

function ALN.Economy.LedgerGetRecent(n)
  n = tonumber(n) or 25
  if n < 1 then n = 1 end
  if n > 200 then n = 200 end
  local out = {}
  for i = math.max(1, #ledger - n + 1), #ledger do
    out[#out+1] = ledger[i]
  end
  return out
end

exports('LedgerRecent', function(n) return ALN.Economy.LedgerGetRecent(n) end)
