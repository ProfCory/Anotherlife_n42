ALN = ALN or {}
ALN.Launder = ALN.Launder or {}

local lastUse = {} -- identityKey -> ts

local function dbg(ev, f)
  if Config.Launder.Debug then
    ALN.Log.Debug(ev, f or {})
  end
end

local function now() return os.time() end

local function isOnCooldown(identityKey)
  local cd = tonumber(Config.Launder.CooldownSeconds or 60) or 60
  local t = lastUse[identityKey] or 0
  return (now() - t) < cd, (cd - (now() - t))
end

local function markUse(identityKey)
  lastUse[identityKey] = now()
end

local function vec3(tbl)
  return vector3(tbl.x, tbl.y, tbl.z)
end

local function dist(a, b)
  local dx = a.x - b.x
  local dy = a.y - b.y
  local dz = a.z - b.z
  return math.sqrt(dx*dx + dy*dy + dz*dz)
end

local function validateNearLaunderPoint(src, coords)
  if not (Config.Launder.RequireLocation == true) then return true end
  local list = exports['aln-locations']:FindByTag(Config.Launder.LocationTag) or {}
  local best = 1e12
  for _, e in ipairs(list) do
    local c = e.loc.coords
    local d = dist(coords, c)
    if d < best then best = d end
  end
  return best <= (Config.Launder.UseDist or 1.8)
end

local function getPlayerCoordsServer(src)
  local ped = GetPlayerPed(src)
  if ped and ped ~= 0 then
    local c = GetEntityCoords(ped)
    if c then return c end
  end
  return nil
end

-- Snapshot for UI: how much dirty + computed payout
RegisterNetEvent('aln:launder:snapshot', function(payload)
  local src = source
  payload = payload or {}

  local identityKey = exports['aln-economy']:GetIdentityKey(src)
  local dirty = exports['aln-economy']:GetBalance(identityKey, 'dirty') or 0

  local outAccount = tostring(payload.outAccount or Config.Launder.DefaultOutAccount or 'cash')
  if not (Config.Launder.AllowOutAccounts and Config.Launder.AllowOutAccounts[outAccount]) then
    outAccount = Config.Launder.DefaultOutAccount or 'cash'
  end

  local calc = ALN.Launder.Compute(ALN.Launder.ClampDirtyIn(dirty))

  TriggerClientEvent('aln:launder:snapshot', src, {
    dirty = dirty,
    outAccount = outAccount,
    calc = calc,
    cooldown = (function()
      local onCd, remain = isOnCooldown(identityKey)
      return { active = onCd, remaining = remain }
    end)()
  })
end)

-- Execute laundering
RegisterNetEvent('aln:launder:do', function(payload)
  local src = source
  payload = payload or {}

  local identityKey = exports['aln-economy']:GetIdentityKey(src)

  local onCd, remain = isOnCooldown(identityKey)
  if onCd then
    TriggerClientEvent('aln:launder:result', src, { ok=false, reason='cooldown', remaining=remain })
    return
  end

  local outAccount = tostring(payload.outAccount or Config.Launder.DefaultOutAccount or 'cash')
  if not (Config.Launder.AllowOutAccounts and Config.Launder.AllowOutAccounts[outAccount]) then
    TriggerClientEvent('aln:launder:result', src, { ok=false, reason='bad_out_account' })
    return
  end

  local dirtyIn = ALN.Launder.ClampDirtyIn(payload.dirtyIn or 0)
  if dirtyIn < (Config.Launder.MinDirtyIn or 100) then
    TriggerClientEvent('aln:launder:result', src, { ok=false, reason='below_min' })
    return
  end

  -- Location check (server-side)
  local coords = getPlayerCoordsServer(src)
  if not coords and payload.coords then coords = vec3(payload.coords) end
  if coords and not validateNearLaunderPoint(src, coords) then
    TriggerClientEvent('aln:launder:result', src, { ok=false, reason='not_near_location' })
    return
  end

  -- Validate funds
  local dirtyBal = exports['aln-economy']:GetBalance(identityKey, 'dirty') or 0
  if dirtyBal < dirtyIn then
    TriggerClientEvent('aln:launder:result', src, { ok=false, reason='insufficient_dirty' })
    return
  end

  local calc = ALN.Launder.Compute(dirtyIn)
  if calc.cleanOut <= 0 then
    TriggerClientEvent('aln:launder:result', src, { ok=false, reason='no_payout' })
    return
  end

  -- Apply: debit dirty, credit outAccount
  local ok1 = exports['aln-economy']:Debit(src, 'dirty', calc.dirtyIn, 'launder.dirty_in', {
    dirtyIn = calc.dirtyIn, cleanOut = calc.cleanOut
  })

  if not ok1 then
    TriggerClientEvent('aln:launder:result', src, { ok=false, reason='debit_failed' })
    return
  end

  local ok2 = exports['aln-economy']:Credit(src, outAccount, calc.cleanOut, 'launder.clean_out', {
    dirtyIn = calc.dirtyIn, cleanOut = calc.cleanOut, outAccount = outAccount
  })

  if not ok2 then
    -- rollback best-effort: re-credit dirty
    exports['aln-economy']:Credit(src, 'dirty', calc.dirtyIn, 'launder.rollback', { outAccount = outAccount })
    TriggerClientEvent('aln:launder:result', src, { ok=false, reason='credit_failed' })
    return
  end

  markUse(identityKey)

  dbg('launder.success', {
    identityKey = identityKey,
    dirtyIn = calc.dirtyIn,
    cleanOut = calc.cleanOut,
    out = outAccount
  })

  -- Return updated balances for UI
  local cash = exports['aln-economy']:GetBalance(identityKey, 'cash') or 0
  local bank = exports['aln-economy']:GetBalance(identityKey, 'bank') or 0
  local dirty = exports['aln-economy']:GetBalance(identityKey, 'dirty') or 0

  TriggerClientEvent('aln:launder:result', src, {
    ok = true,
    calc = calc,
    balances = { cash = cash, bank = bank, dirty = dirty },
  })
end)

AddEventHandler('playerDropped', function()
  -- no per-src caches except identityKey cooldown map; safe to keep.
end)

AddEventHandler('onResourceStart', function(res)
  if res ~= GetCurrentResourceName() then return end
  ALN.Log.Info('launder.start', {})
end)
