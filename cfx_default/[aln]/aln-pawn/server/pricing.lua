ALN = ALN or {}
ALN.Pawn = ALN.Pawn or {}

local function dbg(ev, f)
  if Config.Pawn.Debug then
    ALN.Log.Debug(ev, f or {})
  end
end

local function clamp(n, a, b)
  if n < a then return a end
  if n > b then return b end
  return n
end

local function randFloat(min, max)
  return min + (math.random() * (max - min))
end

-- Determine base price for an item+meta
function ALN.Pawn.GetBasePrice(itemKey, meta)
  local p = PawnPrices[itemKey]
  if not p then return nil end
  if p.variants and meta and meta.variant then
    local v = p.variants[tostring(meta.variant)]
    if v then return v end
  end
  return p.base
end

-- Condition multiplier: later you can tie to item meta.condition / durability
function ALN.Pawn.GetConditionMult(meta)
  if not (Config.Pawn.Condition and Config.Pawn.Condition.Enabled) then
    return 1.0
  end

  local mult = tonumber(Config.Pawn.Condition.DefaultMult or 1.0) or 1.0
  -- If meta.condition exists (0..100), map it
  if meta and meta.condition then
    local c = tonumber(meta.condition) or 100
    c = clamp(c, 0, 100)
    -- 0 => MinMult, 100 => MaxMult
    local minM = tonumber(Config.Pawn.Condition.MinMult or 0.6) or 0.6
    local maxM = tonumber(Config.Pawn.Condition.MaxMult or 1.1) or 1.1
    mult = minM + (c / 100.0) * (maxM - minM)
  end

  return mult
end

function ALN.Pawn.GetRandomBand()
  if not (Config.Pawn.RandomBand and Config.Pawn.RandomBand.Enabled) then
    return 1.0
  end
  local mn = tonumber(Config.Pawn.RandomBand.Min or 0.92) or 0.92
  local mx = tonumber(Config.Pawn.RandomBand.Max or 1.08) or 1.08
  return randFloat(mn, mx)
end

function ALN.Pawn.PriceOne(itemKey, count, meta)
  local base = ALN.Pawn.GetBasePrice(itemKey, meta)
  if not base then return nil end
  local cond = ALN.Pawn.GetConditionMult(meta)
  local band = ALN.Pawn.GetRandomBand()
  local each = math.floor(base * cond * band)
  if each < 0 then each = 0 end
  return each * math.max(1, math.floor(count or 1))
end
