ALN = ALN or {}
ALN.CriminalXP = ALN.CriminalXP or {}

local function now() return os.time() end

-- identityKey (char:<id>) -> state
local state = {}

local function identityKey(src)
  return exports['aln-persistent-data']:GetActiveIdentityKey(src)
    or exports['aln-core']:GetPlayerKey(src)
    or ('src:%d'):format(src)
end

local function clampXP(x)
  x = math.floor(tonumber(x) or 0)
  if x < 0 then x = 0 end
  local max = math.floor(tonumber(Config.Criminal.XPMax or 15000) or 15000)
  if x > max then x = max end
  return x
end

local function ensure(k)
  state[k] = state[k] or { xp = 0, nextAdvUntil = 0 }
  return state[k]
end

local function bandForXP(xp)
  for _, b in ipairs(Config.Criminal.Bands or {}) do
    if xp <= b.max then return b end
  end
  local last = (Config.Criminal.Bands or {})[#(Config.Criminal.Bands or {})]
  return last or { level = 1, mod = 0, max = 0 }
end

function ALN.CriminalXP.GetXP(src)
  local k = identityKey(src)
  return ensure(k).xp
end

function ALN.CriminalXP.SetXP(src, xp)
  local k = identityKey(src)
  ensure(k).xp = clampXP(xp)
  return ensure(k).xp
end

function ALN.CriminalXP.AddXP(src, add)
  local k = identityKey(src)
  local s = ensure(k)
  s.xp = clampXP(s.xp + math.floor(tonumber(add) or 0))
  return s.xp
end

function ALN.CriminalXP.GetLevel(src)
  local xp = ALN.CriminalXP.GetXP(src)
  local b = bandForXP(xp)
  return b.level, b.mod, xp
end

function ALN.CriminalXP.GrantNextAdv(src)
  if not (Config.Criminal.NextAdvEnabled == true) then return false end
  local k = identityKey(src)
  local s = ensure(k)
  s.nextAdvUntil = now() + (tonumber(Config.Criminal.NextAdvTTLSeconds or 300) or 300)
  return true
end

function ALN.CriminalXP.ConsumeNextAdvIfActive(src)
  if not (Config.Criminal.NextAdvEnabled == true) then return false end
  local k = identityKey(src)
  local s = ensure(k)
  if s.nextAdvUntil and s.nextAdvUntil > now() then
    s.nextAdvUntil = 0
    return true
  end
  return false
end

exports('GetXP', function(src) return ALN.CriminalXP.GetXP(src) end)
exports('SetXP', function(src, xp) return ALN.CriminalXP.SetXP(src, xp) end)
exports('AddXP', function(src, add) return ALN.CriminalXP.AddXP(src, add) end)
exports('GetLevel', function(src) return ALN.CriminalXP.GetLevel(src) end)
exports('GrantNextAdv', function(src) return ALN.CriminalXP.GrantNextAdv(src) end)
exports('ConsumeNextAdvIfActive', function(src) return ALN.CriminalXP.ConsumeNextAdvIfActive(src) end)

-- console test
RegisterCommand('aln_crim_xp', function(src, args)
  if src ~= 0 then return end
  local ps = tonumber(args[1] or 0) or 0
  local add = tonumber(args[2] or 0) or 0
  if ps <= 0 then print('usage: aln_crim_xp <src> <add>'); return end
  local xp = exports['aln-criminal-xp']:AddXP(ps, add)
  local lvl, mod = exports['aln-criminal-xp']:GetLevel(ps)
  print(('[ALN3] criminal xp=%d level=%d mod=%d'):format(xp, lvl, mod))
end, true)
