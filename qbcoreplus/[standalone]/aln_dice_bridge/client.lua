local QBCore = exports['qb-core']:GetCoreObject()

local function notify(msg, type)
    QBCore.Functions.Notify(msg, type or "primary")
end

-- Spawn cops near player (PVE)
local function spawnCops(count, radius, weaponHash)
  local ped = PlayerPedId()
  local pcoords = GetEntityCoords(ped)
  RequestModel(`s_m_y_cop_01`)
  while not HasModelLoaded(`s_m_y_cop_01`) do Wait(10) end

  for i=1, (count or 2) do
    local angle = math.random() * math.pi * 2
    local dist = math.random() * (radius or 35.0)
    local x = pcoords.x + math.cos(angle) * dist
    local y = pcoords.y + math.sin(angle) * dist
    local z = pcoords.z
    local _, groundZ = GetGroundZFor_3dCoord(x, y, z + 50.0, false)
    if groundZ then z = groundZ end

    local cop = CreatePed(4, `s_m_y_cop_01`, x, y, z, math.random()*360.0, true, true)
    if DoesEntityExist(cop) then
      SetPedAsCop(cop, true)
      SetPedArmour(cop, 50)
      GiveWeaponToPed(cop, weaponHash or `WEAPON_PISTOL`, 120, false, true)
      SetPedDropsWeaponsWhenDead(cop, false)
      SetPedCombatAbility(cop, 2)
      SetPedCombatRange(cop, 2)
      TaskCombatPed(cop, ped, 0, 16)
    end
  end
  SetModelAsNoLongerNeeded(`s_m_y_cop_01`)
end

-- Events
RegisterNetEvent('aln_dice_bridge:client:critFail', function(data)
  local pid = PlayerId()
  local addWanted = (data and tonumber(data.addWanted)) or 2
  local cur = GetPlayerWantedLevel(pid)
  local newLevel = math.min(5, cur + addWanted)
  SetPlayerWantedLevel(pid, newLevel, false)
  SetPlayerWantedLevelNow(pid, false)
  notify(('CRIT FAIL: Wanted Level Increased!'), 'error')

  if data and data.spawnCops and data.copCfg then
    spawnCops(data.copCfg.Count or 2, data.copCfg.Radius or 35.0, data.copCfg.Weapon or `WEAPON_PISTOL`)
  end
end)

RegisterNetEvent('aln_dice_bridge:client:critSuccess', function(data)
  if data and data.clearWanted then
    SetPlayerWantedLevel(PlayerId(), 0, false)
    SetPlayerWantedLevelNow(PlayerId(), false)
    notify('CRIT SUCCESS: Wanted Cleared & Next Roll Advantage!', 'success')
  else
    notify('CRIT SUCCESS!', 'success')
  end
end)

RegisterNetEvent('aln_dice_bridge:client:toolBroke', function(data)
  notify('Your tool broke!', 'error')
end)

-- EXPORT: DoCheck
exports('DoCheck', function(actionId, ctx)
  ctx = ctx or {}
  ctx.wantedLevel = GetPlayerWantedLevel(PlayerId())

  local computed = lib.callback.await('aln_dice_bridge:computeCheck', false, actionId, ctx)
  if not computed or not computed.allowed then
    local reason = computed and computed.reason or 'denied'
    notify(('Check denied: %s'):format(reason), 'error')
    return false, 0, 0, computed
  end

  local ok, total, raw = exports['bg3_dice']:RollCheck({
    modifier = computed.modifier or 0,
    dc = computed.dc,
    mode = computed.mode or 'normal',
    meta = { system = 'aln_dice_bridge', action = actionId, ctx = ctx }
  })

  TriggerServerEvent('aln_dice_bridge:resolveCheck', {
    actionId = actionId,
    ctx = ctx,
    dc = computed.dc,
    success = ok,
    total = total,
    raw = raw
  })

  return ok, total, raw, computed
end)

-- EXPORT: GetCriminalInfo
exports('GetCriminalInfo', function()
  return lib.callback.await('aln_dice_bridge:getCriminalInfo', false)
end)

-- ==========================================
-- NEW FEATURES (Perception, Rep, Commands)
-- ==========================================

-- 1. Perception Check (Radial Menu)
RegisterNetEvent('aln_dice_bridge:client:perceptionCheck', function()
    local success = exports['aln_dice_bridge']:DoCheck('generic.check', {
        dcOverride = 12, 
        label = "Perception Check"
    })

    if success then
        TriggerEvent('animations:client:EmoteCommandStart', {"search"})
        QBCore.Functions.Progressbar("perception_search", "Searching...", 2000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Done
            TriggerEvent('animations:client:EmoteCommandStart', {"c"}) 
            TriggerServerEvent('aln_dice_bridge:server:perceptionReward')
        end, function() -- Cancel
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        end)
    else
        QBCore.Functions.Notify("You didn't notice anything interesting.", "error")
    end
end)

-- 2. Check Criminal Rep (Radial Menu)
RegisterNetEvent('aln_dice_bridge:client:checkRep', function()
    local info = exports['aln_dice_bridge']:GetCriminalInfo()
    if info then
        local msg = string.format("Criminal Level: %d | XP: %d | Dice Bonus: +%d", info.level, info.xp, info.mod)
        QBCore.Functions.Notify(msg, "primary", 5000)
    else
        QBCore.Functions.Notify("Could not retrieve criminal reputation.", "error")
    end
end)

-- 3. Command: /luck (Generic d20)
RegisterCommand('luck', function()
    local success = exports['aln_dice_bridge']:DoCheck('generic.check', {
        dcOverride = 10,
        label = "Luck Check"
    })
    if success then notify("Lucky! (Success)", "success") else notify("Unlucky... (Fail)", "error") end
end)

-- 4. Command: /forcepick (Bypass broken scripts)
RegisterCommand('forcepick', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local vehicle = QBCore.Functions.GetClosestVehicle()
    
    if vehicle ~= 0 and #(coords - GetEntityCoords(vehicle)) < 3.0 then
        local success = exports['aln_dice_bridge']:DoCheck('vehicle.entry.lockpick', {
            toolItem = 'lockpick'
        })
        if success then
            local plate = QBCore.Functions.GetPlate(vehicle)
            TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
            notify("You forced the lock open.", "success")
        end
    else
        notify("No vehicle nearby to pick.", "error")
    end
end)
-- ==========================================
-- WANTED LEVEL EVASION TRACKER
-- ==========================================
CreateThread(function()
    local lastWanted = 0
    
    while true do
        Wait(1000) -- Check every second
        
        local player = PlayerId()
        local currentWanted = GetPlayerWantedLevel(player)

        -- If we had stars (lastWanted > 0) and now we have 0, we evaded!
        -- We also check if we are ALIVE, so dying doesn't count as "evading"
        if lastWanted > 0 and currentWanted == 0 and not IsEntityDead(PlayerPedId()) then
            TriggerServerEvent('aln_dice_bridge:server:evasionReward', lastWanted)
            lastWanted = 0
        end

        -- Update tracker only if we gain stars, not if we lose them (to prevent exploiting dipping stars)
        if currentWanted > lastWanted then
            lastWanted = currentWanted
        end
    end
end)