ALN = ALN or {}

local function clamp(n, a, b)
  if n < a then return a end
  if n > b then return b end
  return n
end

RegisterNetEvent('aln:minigame:result', function(payload)
  payload = payload or {}
  if not payload.ok then return end
  local res = payload.res
  if type(res) ~= 'table' then return end

  local add = math.floor(tonumber(res.wantedAdd or 0) or 0)
  if add <= 0 then return end

  local pid = PlayerId()
  local cur = GetPlayerWantedLevel(pid)
  local nxt = clamp(cur + add, 0, 5)

  SetPlayerWantedLevel(pid, nxt, false)
  SetPlayerWantedLevelNow(pid, false)

  if Config and Config.Minigame and Config.Minigame.Debug then
    print(('[ALN3][minigame] wantedAdd=%d cur=%d nxt=%d'):format(add, cur, nxt))
  end
end)
