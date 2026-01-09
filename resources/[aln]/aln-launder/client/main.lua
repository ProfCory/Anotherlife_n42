ALN = ALN or {}

local uiId = 'aln.launder'
local token = nil
local nearby = nil

local function dbg(ev, f)
  if Config.Launder.Debug then
    ALN.Log.Debug(ev, f or {})
  end
end

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

local function acquire()
  if token then return true end
  token = exports['aln-ui-focus']:Acquire(uiId, { cursor = false, keepInput = true })
  return token ~= nil
end

local function release()
  if token then
    exports['aln-ui-focus']:Release(uiId, token)
    token = nil
  end
end

CreateThread(function()
  exports['aln-ui-focus']:Register(uiId, {
    allowOverlap = false,
    allowStack = false,
    keepInput = true,
  })
end)

-- Find nearest launder location
CreateThread(function()
  Wait(1000)
  while true do
    local list = exports['aln-locations']:FindByTag(Config.Launder.LocationTag) or {}
    local ped = PlayerPedId()
    if ped ~= 0 and #list > 0 then
      local p = GetEntityCoords(ped)
      local best, bestD = nil, 9999.0
      for _, e in ipairs(list) do
        local c = e.loc.coords
        local d = #(p - c)
        if d < bestD then bestD = d; best = e end
      end
      if best and bestD <= (Config.Launder.UseDist or 1.8) then
        nearby = best
      else
        nearby = nil
      end
    end
    Wait(300)
  end
end)

local function runMenu(snapshot)
  local outAccount = snapshot.outAccount or 'cash'
  local calc = snapshot.calc or {}
  local dirty = snapshot.dirty or 0

  local input = math.floor(math.min(math.max(calc.dirtyIn or 0, Config.Launder.MinDirtyIn or 100), Config.Launder.MaxDirtyIn or 50000))
  local done = false

  while not done do
    DisableAllControlActions(0)
    EnableControlAction(0, 172, true) -- up
    EnableControlAction(0, 173, true) -- down
    EnableControlAction(0, 174, true) -- left
    EnableControlAction(0, 175, true) -- right
    EnableControlAction(0, 191, true) -- enter
    EnableControlAction(0, 202, true) -- back

    if IsControlJustReleased(0, 202) then
      done = true
      break
    end

    -- change amount
    if IsControlJustReleased(0, 172) then input = input + 100 end
    if IsControlJustReleased(0, 173) then input = input - 100 end
    if IsControlPressed(0, 172) and IsControlPressed(0, 21) then input = input + 1000 end -- shift+up
    if IsControlPressed(0, 173) and IsControlPressed(0, 21) then input = input - 1000 end -- shift+down

    local minIn = Config.Launder.MinDirtyIn or 100
    local maxIn = Config.Launder.MaxDirtyIn or 50000
    if input < minIn then input = minIn end
    if input > maxIn then input = maxIn end
    if input > dirty then input = dirty end

    -- toggle out account
    if IsControlJustReleased(0, 174) or IsControlJustReleased(0, 175) then
      outAccount = (outAccount == 'cash') and 'bank' or 'cash'
    end

    -- compute locally for preview (server will compute again)
    local rate = Config.Launder.PayoutRate or 0.70
    local flat = Config.Launder.FlatFee or 0
    local pct = Config.Launder.PercentFee or 0.0
    local gross = math.floor(input * rate)
    local afterFlat = math.max(0, gross - flat)
    local pctFee = math.floor(afterFlat * pct)
    local cleanOut = math.max(0, afterFlat - pctFee)

    local cd = snapshot.cooldown or { active=false, remaining=0 }
    local cdLine = cd.active and ('~r~Cooldown: %ds~s~\n'):format(cd.remaining or 0) or ''

    drawCenter(
      ('Launder Money\n\nDirty Available: ~y~$%d~s~\n%s\nInput: ~y~$%d~s~\nOutput: ~g~$%d~s~ → %s\n\n~c~Up/Down (+Shift=1000) • Left/Right toggle cash/bank • Enter confirm • Back cancel~s~')
      :format(dirty, cdLine, input, cleanOut, outAccount:upper())
    )

    if IsControlJustReleased(0, 191) then
      if cd.active then
        -- ignore
      else
        local ped = PlayerPedId()
        local p = GetEntityCoords(ped)
        TriggerServerEvent('aln:launder:do', {
          dirtyIn = input,
          outAccount = outAccount,
          coords = { x = p.x, y = p.y, z = p.z },
        })
        done = true
      end
    end

    Wait(0)
  end
end

local pendingOpen = false

CreateThread(function()
  while true do
    if nearby and not token then
      drawHelp('Press ~INPUT_CONTEXT~ to launder dirty money')
      if IsControlJustReleased(0, 38) then -- E
        if acquire() then
          pendingOpen = true
          TriggerServerEvent('aln:launder:snapshot', { outAccount = Config.Launder.DefaultOutAccount or 'cash' })
        end
      end
      Wait(0)
    else
      Wait(200)
    end
  end
end)

RegisterNetEvent('aln:launder:snapshot', function(snapshot)
  if not token then return end
  if pendingOpen then
    pendingOpen = false
    runMenu(snapshot)
    -- menu closes on confirm/cancel; keep focus discipline
    -- we will release after result or cancel
    if token then release() end
  end
end)

RegisterNetEvent('aln:launder:result', function(res)
  dbg('launder.result', res or {})
  if token then release() end
end)

-- Debug command if you want (works anywhere if RequireLocation=false)
RegisterCommand('aln_launder', function()
  if acquire() then
    pendingOpen = true
    TriggerServerEvent('aln:launder:snapshot', { outAccount = 'cash' })
  end
end, false)
