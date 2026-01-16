ALN = ALN or {}

local function dbg(ev, f)
  if Config and Config.ATM and Config.ATM.Debug then
    ALN.Log.Debug(ev, f or {})
  end
end

local atmPoints = {}
local nearId = nil

local function refreshAtmPoints()
  -- We rely on aln-locations having ATM-tagged entries.
  -- If you don’t have them yet, we’ll add a small ATM module next.
  local list = exports['aln-locations']:FindByTag('atm')
  atmPoints = {}
  for _, e in ipairs(list or {}) do
    atmPoints[#atmPoints+1] = { id = e.id, coords = e.loc.coords }
  end
  dbg('atm.points_loaded', { count = #atmPoints })
end

CreateThread(function()
  Wait(1000)
  refreshAtmPoints()

  while true do
    local ped = PlayerPedId()
    local p = GetEntityCoords(ped)
    local best, bestDist = nil, 9999.0

    for _, a in ipairs(atmPoints) do
      local d = #(p - a.coords)
      if d < bestDist then
        bestDist = d
        best = a
      end
    end

    if best and bestDist <= (Config.ATM.UseDist or 1.8) then
      nearId = best.id
    else
      nearId = nil
    end

    Wait(250)
  end
end)

exports('GetNearbyATM', function()
  return nearId
end)

RegisterCommand('aln_atm_reload', function()
  refreshAtmPoints()
end, false)
