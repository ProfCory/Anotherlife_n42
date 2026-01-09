ALN = ALN or {}
ALN.Respawn = ALN.Respawn or {}

local function dbg(ev, f)
  if Config.Respawn.Debug then
    ALN.Log.Debug(ev, f or {})
  end
end

local function dist(a, b)
  local dx = a.x - b.x
  local dy = a.y - b.y
  local dz = a.z - b.z
  return math.sqrt(dx*dx + dy*dy + dz*dz)
end

local function nearestByTag(tag, coords)
  local list = exports['aln-locations']:FindByTag(tag) or {}
  local best, bestD = nil, 1e12
  for _, e in ipairs(list) do
    local c = e.loc.coords
    local d = dist(coords, c)
    if d < bestD then
      bestD = d
      best = { id = e.id, coords = c, label = e.loc.label }
    end
  end
  return best
end

-- src -> session lock
local locks = {}

function ALN.Respawn.IsLocked(src)
  local l = locks[src]
  if not l then return false end
  if os.time() > (l.untilTs or 0) then
    locks[src] = nil
    return false
  end
  return true
end

function ALN.Respawn.Lock(src, seconds, meta)
  locks[src] = {
    untilTs = os.time() + seconds,
    meta = meta or {}
  }
end

function ALN.Respawn.ComputeTimerSeconds(wantedStars)
  local base = Config.Respawn.TimerSeconds or 25
  local per = Config.Respawn.ExtraSecondsPerStar or 8
  wantedStars = math.floor(tonumber(wantedStars) or 0)
  if wantedStars < 0 then wantedStars = 0 end
  return base + (wantedStars * per)
end

-- Select endpoint based on rules.
-- ctx: { wantedStars, coords }
function ALN.Respawn.SelectEndpoint(ctx)
  local stars = math.floor(tonumber(ctx.wantedStars or 0) or 0)
  local coords = ctx.coords

  if stars >= 1 then
    return nearestByTag(Config.Respawn.Tags.police, coords) or nearestByTag(Config.Respawn.Tags.hospital, coords)
  end

  return nearestByTag(Config.Respawn.Tags.hospital, coords) or nearestByTag(Config.Respawn.Tags.police, coords)
end

dbg('respawn.logic_ready', {})
