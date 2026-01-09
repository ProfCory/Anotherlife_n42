local showing = false
local pending = nil
local currentCtx = nil

RegisterNUICallback('finished', function(data, cb)
  local success = true
  if currentCtx and currentCtx.dc ~= nil then
    if currentCtx.dc > 20 then success = (data.raw == 20) else success = (data.total >= currentCtx.dc) end
  end
  pending = { success = success, total = data.total, raw = data.raw }
  TriggerEvent('bg3_dice:onRollEnd', {
    success = success,
    total = data.total,
    raw = data.raw,
    dc = currentCtx and currentCtx.dc or nil,
    modifier = currentCtx and currentCtx.modifier or 0,
    mode = currentCtx and currentCtx.mode or 'normal',
    meta = currentCtx and currentCtx.meta or nil
  })
  if data.raw == 20 then TriggerEvent('bg3_dice:onNat20', currentCtx) end
  if data.raw == 1 then TriggerEvent('bg3_dice:onNat1', currentCtx) end
  TriggerServerEvent('bg3_dice:ended', success, data.total, data.raw,
    currentCtx and currentCtx.dc or nil, currentCtx and currentCtx.modifier or 0,
    currentCtx and currentCtx.mode or 'normal', currentCtx and currentCtx.meta or nil)
  cb(1)
end)

if Config.Command then
	RegisterCommand(Config.Command, function(_, args)
	  local modifier = tonumber(args[1]) or 0
	  local dc = tonumber(args[2])
	  local mode = args[3] and string.lower(args[3]) or 'normal'
	  if mode == 'advantage' then mode = 'adv' end
	  if mode == 'disadvantage' then mode = 'dis' end
	  RollD20(modifier, dc, mode)
	end)
end

exports('Roll', function(opts)
  local sides = (opts and opts.sides) or 20
  if sides ~= 20 then print('bg3_dice: only D20 visual supported. Using 20.') end
  RollD20(
    opts and (opts.modifier or 0) or 0,
    opts and opts.dc or nil,
    opts and (opts.mode or 'normal') or 'normal',
    opts and opts.meta or nil,
    { skin = opts and opts.skin or Config.Skin, edgeColor = opts and opts.edgeColor or Config.EdgeColor, numerals = opts and opts.numerals or Config.Numerals }
  )
end)

exports('RollCheck', function(opts)
  local modifier = (opts and opts.modifier) or 0
  local dc = (opts and opts.dc) or nil
  local mode = (opts and opts.mode) or 'normal'
  pending = nil
  RollD20(modifier, dc, mode, opts and opts.meta or nil, { skin = opts and opts.skin or Config.Skin, edgeColor = opts and opts.edgeColor or Config.EdgeColor, numerals = opts and opts.numerals or Config.Numerals })
  local waited = 0
  local maxWait = (Config.RollAnimMs + Config.CloseDelayMs + 5000)
  while pending == nil and waited < maxWait do
    Wait(50); waited = waited + 50
  end
  if pending == nil then
    local raw = 1
    local total = modifier + raw
    local success = (dc ~= nil) and ( (dc>20 and raw==20) or (total >= dc) ) or true
    return success, total, raw
  end
  return pending.success, pending.total, pending.raw
end)

function RollD20(modifier, dc, mode, meta, visuals)
  if showing then return end
  showing = true
  local r1 = math.random(1,20)
  local r2 = math.random(1,20)
  local raw = (mode=='adv' and math.max(r1,r2)) or (mode=='dis' and math.min(r1,r2)) or r1
  local total = raw + (modifier or 0)
  SetNuiFocus(false,false)
  currentCtx = { dc = dc, modifier = modifier or 0, mode = mode, meta = meta, visuals = visuals }
  TriggerEvent('bg3_dice:onRollStart', {
    dc = dc, modifier = modifier or 0, mode = mode, meta = meta
  })
  TriggerServerEvent('bg3_dice:started', r1, r2, raw, modifier or 0, dc, mode, meta)
  SendNUIMessage({ action='roll3d', payload={ raw=raw, r1=r1, r2=r2, total=total, modifier=modifier or 0, dc=dc, mode=mode, rollMs=Config.RollAnimMs, holdMs=Config.CloseDelayMs, faceAccurate=Config.FaceAccurate, locale=Config.Locale, skin=(visuals and visuals.skin) or Config.Skin, edgeColor=(visuals and visuals.edgeColor) or Config.EdgeColor, numerals=(visuals and visuals.numerals) or Config.Numerals } })
  TriggerServerEvent('bg3_dice:roll', raw, modifier or 0, total, dc, mode, meta)
  CreateThread(function() Wait(Config.RollAnimMs + Config.CloseDelayMs) showing=false end)
end

RegisterNetEvent('bg3_dice:broadcast', function(srcName, raw, modifier, total, dc, mode)
  local modeTxt = (mode=='adv' and ' (adv)') or (mode=='dis' and ' (dis)') or ''
  local dcTxt = dc and (' vs DC '..dc) or ''
  local ok = false
  if dc then
    if dc > 20 then
      ok = (raw == 20)
    else
      ok = (total >= dc)
    end
  end
  local passTxt = (dc and ok) and ' ✅' or (dc and ' ❌') or ''
  TriggerEvent('chat:addMessage', { color={180,120,255}, multiline=false,
    args={'🎲 '..(srcName or 'Someone'), ('rolled **'..raw..'**'..(modifier~=0 and (' '..(modifier>0 and '+' or '')..modifier) or '')..' = '..total..modeTxt..dcTxt..passTxt)} })
end)

exports('RollQuick', function()
  RollD20(0, nil, 'normal', { source = 'quick' })
end)

exports('RollQuickResult', function()
  pending = nil
  RollD20(0, nil, 'normal', { source = 'quick' })
  local waited, maxWait = 0, (Config.RollAnimMs + Config.CloseDelayMs + 5000)
  while pending == nil and waited < maxWait do Wait(50) waited = waited + 50 end
  if pending == nil then
    return true, 1, 1
  end
  return pending.success, pending.total, pending.raw
end)
