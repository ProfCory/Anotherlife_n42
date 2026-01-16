ALN = ALN or {}
ALN.Identity = ALN.Identity or {}

local function getAllIdentifiers(src)
  local out = {}
  for _, id in ipairs(GetPlayerIdentifiers(src)) do
    -- format is "type:value"
    local colon = string.find(id, ':', 1, true)
    if colon then
      local t = string.sub(id, 1, colon - 1)
      local v = string.sub(id, colon + 1)
      out[t] = v
    end
  end
  return out
end

-- Returns stable player key (string) like "license:abcd..."
-- Priority: Config.Core.IdentifierPriority
function ALN.Identity.GetPlayerKey(src)
  if not src or src <= 0 then return nil end
  local ids = getAllIdentifiers(src)

  local prio = (Config and Config.Core and Config.Core.IdentifierPriority) or { 'license' }
  for _, t in ipairs(prio) do
    if ids[t] and ids[t] ~= '' then
      return (t .. ':' .. ids[t])
    end
  end

  -- last resort: server id (NOT stable across reconnects)
  return ('src:%d'):format(src)
end

-- Convenience: return identifiers map
function ALN.Identity.GetIdentifiers(src)
  return getAllIdentifiers(src)
end
