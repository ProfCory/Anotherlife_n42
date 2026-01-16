-- Deterministic RNG for loot rolls.
-- We seed from a stable context string (playerKey + poolId + entityNetId + etc).

ALN = ALN or {}
ALN.Loot = ALN.Loot or {}
ALN.Loot.RNG = ALN.Loot.RNG or {}

local function fnv1a32(str)
  local hash = 2166136261
  for i = 1, #str do
    hash = hash ~ str:byte(i)
    hash = (hash * 16777619) & 0xffffffff
  end
  return hash
end

local function xorshift32(seed)
  seed = seed & 0xffffffff
  seed = seed ~ (seed << 13) & 0xffffffff
  seed = seed ~ (seed >> 17) & 0xffffffff
  seed = seed ~ (seed << 5) & 0xffffffff
  return seed & 0xffffffff
end

function ALN.Loot.RNG.New(seedString)
  local s = fnv1a32(seedString or 'seed')
  return {
    _s = s,
    nextU32 = function(self)
      self._s = xorshift32(self._s)
      return self._s
    end,
    nextFloat = function(self)
      local u = self:nextU32()
      return (u / 0xffffffff)
    end,
    nextInt = function(self, min, max)
      if max <= min then return min end
      local f = self:nextFloat()
      return min + math.floor(f * ((max - min) + 1))
    end
  }
end
