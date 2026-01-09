ALN = ALN or {}
ALN.Launder = ALN.Launder or {}

local function clamp(n, a, b)
  if n < a then return a end
  if n > b then return b end
  return n
end

-- Compute clean payout from dirty input
function ALN.Launder.Compute(dirtyIn)
  dirtyIn = math.floor(tonumber(dirtyIn) or 0)

  local rate = tonumber(Config.Launder.PayoutRate or 0.70) or 0.70
  local flat = math.floor(tonumber(Config.Launder.FlatFee or 0) or 0)
  local pct  = tonumber(Config.Launder.PercentFee or 0.0) or 0.0

  local gross = math.floor(dirtyIn * rate)
  local afterFlat = gross - flat
  if afterFlat < 0 then afterFlat = 0 end

  local pctFee = math.floor(afterFlat * pct)
  local cleanOut = afterFlat - pctFee
  if cleanOut < 0 then cleanOut = 0 end

  return {
    dirtyIn = dirtyIn,
    rate = rate,
    gross = gross,
    flatFee = flat,
    percentFee = pctFee,
    cleanOut = cleanOut,
    totalFees = (dirtyIn - cleanOut),
  }
end

function ALN.Launder.ClampDirtyIn(dirtyIn)
  dirtyIn = math.floor(tonumber(dirtyIn) or 0)
  local minIn = math.floor(tonumber(Config.Launder.MinDirtyIn or 100) or 100)
  local maxIn = math.floor(tonumber(Config.Launder.MaxDirtyIn or 50000) or 50000)
  return clamp(dirtyIn, minIn, maxIn)
end
