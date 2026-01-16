ALN = ALN or {}
ALN.Loot = ALN.Loot or {}

local function dbg(ev, f)
  if Config and Config.Loot and Config.Loot.Debug then
    ALN.Log.Debug(ev, f or {})
  end
end

local function pickWeighted(rng, entries)
  local total = 0
  for _, e in ipairs(entries) do total = total + (e.w or 0) end
  if total <= 0 then return nil end

  local roll = rng:nextInt(1, total)
  local acc = 0
  for _, e in ipairs(entries) do
    acc = acc + e.w
    if roll <= acc then return e end
  end
  return entries[#entries]
end

local function clampResults(results)
  local max = (Config and Config.Loot and Config.Loot.MaxResultsPerRoll) or 10
  if #results <= max then return results end
  local out = {}
  for i = 1, max do out[i] = results[i] end
  return out
end

-- ctx fields you can pass (all optional):
--   src (player source)
--   playerKey (string) - if not provided and src exists, we compute from aln-core
--   entityNetId (number) - ped/vehicle/net entity id
--   locationId (string) - optional (ties roll to a place)
--   timeBucket (number) - optional; include if you want different loot per in-game day/hour bucket
--   extraSeed (string) - optional
-- Returns array of { item=key, count=int, meta=table|nil }
function ALN.Loot.Roll(poolId, ctx)
  ctx = ctx or {}
  local pool = exports['aln-loot']:GetPool(poolId)
  if not pool then return nil, 'unknown_pool' end

  local playerKey = ctx.playerKey
  if not playerKey and ctx.src then
    playerKey = exports['aln-core']:GetPlayerKey(ctx.src)
  end
  playerKey = playerKey or 'noPlayer'

  local seedStr = table.concat({
    'aln3loot',
    poolId,
    playerKey,
    tostring(ctx.entityNetId or 'noEnt'),
    tostring(ctx.locationId or 'noLoc'),
    tostring(ctx.timeBucket or 'noTime'),
    tostring(ctx.extraSeed or 'noExtra'),
  }, '|')

  local rng = ALN.Loot.RNG.New(seedStr)
  local draws = rng:nextInt(pool.rolls.min, pool.rolls.max)

  local results = {}
  for i = 1, draws do
    local entry = pickWeighted(rng, pool.entries)
    if entry and entry.item ~= nil then
      local cnt = 1
      if entry.count and type(entry.count) == 'table' then
        cnt = rng:nextInt(entry.count.min or 1, entry.count.max or 1)
      elseif type(entry.count) == 'number' then
        cnt = entry.count
      end

      local meta = entry.meta and (type(entry.meta) == 'table') and table.clone and table.clone(entry.meta) or entry.meta

      -- Variant support: e.g. loot_valuable variants
      if entry.variant and type(entry.variant) == 'table' then
        -- variant.list = { {key='diamond', w=50}, ... }
        if entry.variant.list and type(entry.variant.list) == 'table' and #entry.variant.list > 0 then
          local v = pickWeighted(rng, entry.variant.list)
          meta = meta or {}
          meta.variant = v and v.key or nil
        end
      end

      results[#results+1] = { item = entry.item, count = cnt, meta = meta }
    end
  end

  results = clampResults(results)

  dbg('loot.roll', {
    poolId = poolId,
    draws = draws,
    out = #results,
    seedHint = seedStr:sub(1, 60)
  })

  return results, nil
end

exports('Roll', function(poolId, ctx) return ALN.Loot.Roll(poolId, ctx) end)
