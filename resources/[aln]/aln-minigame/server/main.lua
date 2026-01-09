ALN = ALN or {}
ALN.Minigame = ALN.Minigame or {}

local function clamp(n,a,b) if n<a then return a elseif n>b then return b else return n end end

local function d20()
  return math.random(1,20)
end

local function rollWithMode(mode)
  -- mode: 'normal' | 'adv' | 'dis'
  local a = d20()
  if mode == 'normal' then return a, a, nil end
  local b = d20()
  if mode == 'adv' then
    return math.max(a,b), a, b
  else
    return math.min(a,b), a, b
  end
end

local function valueBump(value)
  value = tonumber(value or 0) or 0
  local add = 0
  for _, r in ipairs(Config.Minigame.ValueBumps or {}) do
    if value >= (r.min or 0) then add = math.max(add, r.add or 0) end
  end
  return add
end

local function toolBreakChance(dc, nat1)
  if not (Config.Minigame.ToolBreak and Config.Minigame.ToolBreak.Enabled) then return 0 end
  if nat1 then return 100 end
  local tb = Config.Minigame.ToolBreak
  local c = (tb.Base or 10) + ((dc - 10) * (tb.PerDc or 2))
  c = clamp(c, tb.Min or 10, tb.Max or 40)
  return math.floor(c)
end

-- Server authoritative check:
-- ctx:
-- { wantedStars, vehicleClass, value, dcAdd, forceMode='adv|dis|normal' }
function ALN.Minigame.DoCheck(src, actionId, ctx)
  ctx = ctx or {}
  actionId = tostring(actionId or '')
  local def = (Config.Minigame.Actions or {})[actionId]
  if not def then return false, 'unknown_action' end

  local level, mod = exports['aln-criminal-xp']:GetLevel(src)

  -- tool tier
  local tier, toolItem = exports['aln-criminal-tools']:GetBestToolForAction(src, actionId)
  local hasTool = (tier ~= 'none')

  if def.requiresTool and not hasTool then
    return false, 'tool_required'
  end

  local dc = math.floor(tonumber(def.baseDC or 10) or 10)

  if ctx.vehicleClass ~= nil then
    local v = Config.Minigame.VehicleClassDC[tonumber(ctx.vehicleClass)]
    if v then dc = dc + (v - (def.baseDC or v)) end
  end

  if ctx.value ~= nil then
    dc = dc + valueBump(ctx.value)
  end

  if ctx.dcAdd ~= nil then
    dc = dc + math.floor(tonumber(ctx.dcAdd) or 0)
  end

  local wanted = math.floor(tonumber(ctx.wantedStars or 0) or 0)

  -- roll mode
  local mode = 'normal'
  if ctx.forceMode == 'adv' or ctx.forceMode == 'dis' or ctx.forceMode == 'normal' then
    mode = ctx.forceMode
  else
    if wanted >= (Config.Minigame.WantedDisThreshold or 1) then
      mode = 'dis'
    end

    -- momentum next-adv
    local consumed = exports['aln-criminal-xp']:ConsumeNextAdvIfActive(src)
    if consumed then mode = 'adv' end

    -- tool advantage
    if def.toolGivesAdv and hasTool then
      if tier == 'adv' then mode = 'adv' end
      if tier == 'basic' and mode == 'normal' then mode = 'adv' end
      -- if already dis, stay dis
    end
  end

  local roll, r1, r2 = rollWithMode(mode)
  local nat1 = (roll == 1)
  local nat20 = (roll == 20)

  local total = roll + (tonumber(mod) or 0)
  local success = (total >= dc) and not nat1
  local crit = nat20

  -- XP
  local xpGain = 0
  if success then
    xpGain = math.floor(dc * (Config.Minigame.SuccessXpPerDC or 10))
  else
    xpGain = math.floor(dc * (Config.Minigame.FailXpPerDC or 0))
  end
  if xpGain > 0 then
    exports['aln-criminal-xp']:AddXP(src, xpGain)
  end

  -- nat20 grants next-adv momentum
  if nat20 and Config.Criminal and Config.Criminal.NextAdvEnabled then
    exports['aln-criminal-xp']:GrantNextAdv(src)
  end

  -- tool break
  local broke = false
  local breakChance = 0
  if hasTool and (Config.Minigame.ToolBreak and Config.Minigame.ToolBreak.Enabled) then
    if not success then
      breakChance = toolBreakChance(dc, nat1)
      local rollPct = math.random(1,100)
      if rollPct <= breakChance then
        broke = true
        exports['aln-criminal-tools']:ConsumeToolItem(src, toolItem)
      end
    end
  end

  -- wanted effects
  local wantedAdd = 0
  if nat1 then wantedAdd = wantedAdd + (Config.Minigame.CritFailWantedStars or 2) end

  return true, {
    actionId = actionId,
    label = def.label,
    dc = dc,
    level = level,
    mod = mod,
    mode = mode,
    roll = roll,
    rollA = r1,
    rollB = r2,
    total = total,
    success = success,
    critSuccess = nat20,
    critFail = nat1,
    xpGain = xpGain,
    tool = { tier = tier, item = toolItem, broke = broke, breakChance = breakChance },
    wantedAdd = wantedAdd,
  }
end

exports('DoCheck', function(src, actionId, ctx) return ALN.Minigame.DoCheck(src, actionId, ctx) end)

-- Server event interface (client requests a roll)
RegisterNetEvent('aln:minigame:doCheck', function(actionId, ctx)
  local src = source
  local ok, res = exports['aln-minigame']:DoCheck(src, actionId, ctx)
  TriggerClientEvent('aln:minigame:result', src, { ok = ok, res = res })
end)

-- console test
RegisterCommand('aln_dc', function(src, args)
  if src ~= 0 then return end
  local ps = tonumber(args[1] or 0) or 0
  local act = tostring(args[2] or 'vehicle.hotwire')
  if ps <= 0 then print('usage: aln_dc <src> <actionId>'); return end
  local ok, res = exports['aln-minigame']:DoCheck(ps, act, { wantedStars = 0, vehicleClass = 6, value = 60000 })
  print('[ALN3] ok='..tostring(ok)..' res='..(type(res)=='table' and json.encode(res) or tostring(res)))
end, true)
