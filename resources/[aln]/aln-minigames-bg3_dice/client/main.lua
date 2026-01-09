ALN = ALN or {}

local function dbg(msg, data)
  if Config.BG3Dice.Debug then
    print('[ALN3][bg3dice] ' .. msg .. (data and (' ' .. json.encode(data)) or ''))
  end
end

local function isDiceReady()
  if not (Config.BG3Dice.Enabled == true) then return false end
  local rn = Config.BG3Dice.ResourceName
  if not rn or rn == '' then return false end
  return GetResourceState(rn) == 'started'
end

-- Try to call the dice resource exports in a safe way.
-- Since we don't know the exact export names until you install it,
-- we support multiple common patterns and fail silently if none match.
local function playDiceVisual(payload)
  if not isDiceReady() then return end
  local rn = Config.BG3Dice.ResourceName

  local res = payload.res or {}
  if type(res) ~= 'table' then return end

  local mode = res.mode or 'normal'   -- normal/adv/dis
  local roll = tonumber(res.roll or 0) or 0
  local a = tonumber(res.rollA or roll) or roll
  local b = tonumber(res.rollB or roll) or nil
  local dc = tonumber(res.dc or 0) or 0
  local total = tonumber(res.total or roll) or roll
  local success = res.success == true

  local ok = false

  -- Pattern 1: exports.<resource>:Roll({...})
  local try1 = pcall(function()
    exports[rn]:Roll({
      mode = mode,
      roll = roll,
      a = a,
      b = b,
      dc = dc,
      total = total,
      success = success,
      label = res.label or res.actionId or 'Check',
    })
  end)
  if try1 then ok = true end

  -- Pattern 2: exports.<resource>:PlayDice(a,b,mode,dc,total,success,label)
  if not ok then
    local try2 = pcall(function()
      exports[rn]:PlayDice(a, b, mode, dc, total, success, res.label or res.actionId or 'Check')
    end)
    if try2 then ok = true end
  end

  -- Pattern 3: TriggerEvent interface
  if not ok then
    local try3 = pcall(function()
      TriggerEvent(rn .. ':roll', {
        mode = mode, a = a, b = b, dc = dc, total = total, success = success,
        label = res.label or res.actionId or 'Check',
      })
    end)
    if try3 then ok = true end
  end

  if Config.BG3Dice.Debug then
    dbg(ok and 'dice_visual_played' or 'dice_visual_no_match', { mode=mode, a=a, b=b, dc=dc, total=total })
  end
end

RegisterNetEvent('aln:minigame:result', function(payload)
  -- Only visuals. The core minigame + wanted handler still runs in aln-minigame itself.
  if not payload or payload.ok ~= true then return end
  playDiceVisual(payload)
end)
