ALN = ALN or {}

local uiId = 'aln.pawn'
local token = nil
local nearby = nil
local catalog = nil

local function dbg(ev, f)
  if Config.Pawn.Debug then ALN.Log.Debug(ev, f or {}) end
end

local function acquire()
  if token then return true end
  token = exports['aln-ui-focus']:Acquire(uiId, { cursor=false, keepInput=true })
  return token ~= nil
end

local function release()
  if token then
    exports['aln-ui-focus']:Release(uiId, token)
    token = nil
  end
end

CreateThread(function()
  exports['aln-ui-focus']:Register(uiId, { allowOverlap=false, allowStack=false, keepInput=true })
end)

local function drawHelp(msg)
  BeginTextCommandDisplayHelp('STRING')
  AddTextComponentSubstringPlayerName(msg)
  EndTextCommandDisplayHelp(0, false, true, 1)
end

local function drawCenter(text)
  SetTextFont(4)
  SetTextScale(0.45, 0.45)
  SetTextColour(255,255,255,220)
  SetTextCentre(true)
  SetTextOutline()
  BeginTextCommandDisplayText('STRING')
  AddTextComponentSubstringPlayerName(text)
  EndTextCommandDisplayText(0.5, 0.45)
end

-- Find pawn nearby
CreateThread(function()
  Wait(1000)
  while true do
    local list = exports['aln-locations']:FindByTag(Config.Pawn.LocationTag) or {}
    local ped = PlayerPedId()
    if ped ~= 0 and #list > 0 then
      local p = GetEntityCoords(ped)
      local best, bestD = nil, 9999.0
      for _, e in ipairs(list) do
        local c = e.loc.coords
        local d = #(p - c)
        if d < bestD then bestD = d; best = e end
      end
      if best and bestD <= (Config.Pawn.UseDist or 1.8) then nearby = best else nearby = nil end
    end
    Wait(300)
  end
end)

local function menu()
  if not catalog then
    TriggerServerEvent('aln:pawn:catalog')
    return
  end

  local idx = 1
  while true do
    DisableAllControlActions(0)
    EnableControlAction(0, 172, true) -- up
    EnableControlAction(0, 173, true) -- down
    EnableControlAction(0, 191, true) -- enter
    EnableControlAction(0, 202, true) -- back

    if IsControlJustReleased(0, 172) then idx = idx - 1 end
    if IsControlJustReleased(0, 173) then idx = idx + 1 end
    if idx < 1 then idx = #catalog end
    if idx > #catalog then idx = 1 end

    local row = catalog[idx]
    local item = row.item
    local base = row.base or 0

    drawCenter(
      ('Pawn Shop\n\nSelected: ~y~%s~s~\nBase: ~g~$%d~s~\n\n~c~Up/Down select • Enter sell 1 • Back close~s~')
      :format(item, base)
    )

    if IsControlJustReleased(0, 202) then break end

    if IsControlJustReleased(0, 191) then
      local ped = PlayerPedId()
      local p = GetEntityCoords(ped)
      TriggerServerEvent('aln:pawn:sell', {
        coords = { x = p.x, y = p.y, z = p.z },
        items = { { item = item, count = 1, meta = nil } }
      })
      break
    end

    Wait(0)
  end
end

CreateThread(function()
  while true do
    if nearby and not token then
      drawHelp('Press ~INPUT_CONTEXT~ to use Pawn Shop')
      if IsControlJustReleased(0, 38) then
        if acquire() then
          menu()
          release()
        end
      end
      Wait(0)
    else
      Wait(200)
    end
  end
end)

RegisterNetEvent('aln:pawn:catalog', function(rows)
  catalog = rows
  dbg('pawn.catalog', { n = #rows })
end)

RegisterNetEvent('aln:pawn:result', function(res)
  dbg('pawn.result', res or {})
end)
