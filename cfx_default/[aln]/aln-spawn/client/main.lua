ALN = ALN or {}

local function dbg(ev, f)
  if Config.Spawn.Debug then ALN.Log.Debug(ev, f or {}) end
end

local function doSpawnPlayer(payload)
  exports.spawnmanager:setAutoSpawn(false)

  local c = payload.coords
  local h = payload.heading or 0.0

  DoScreenFadeOut(300)
  while not IsScreenFadedOut() do Wait(10) end

  exports.spawnmanager:spawnPlayer({
    x = c.x, y = c.y, z = c.z, heading = h,
    model = payload.baseModel or 'mp_m_freemode_01',
    skipFade = true
  }, function()
    local ped = PlayerPedId()
    SetEntityCoordsNoOffset(ped, c.x, c.y, c.z, false, false, false)
    SetEntityHeading(ped, h)

    DoScreenFadeIn(600)
  end)
end

local function runOnboarding(payload)
  if not (Config.Spawn.Onboarding and Config.Spawn.Onboarding.Enabled) then return end

  -- Model pick
  local modelOpt = ALN.SpawnUI.Pick(Config.Spawn.Onboarding.Models, 'Choose Base Character')
  -- Vehicle pick
  local vehOpt = ALN.SpawnUI.Pick(Config.Spawn.Onboarding.StarterVehicles, 'Choose Starter Vehicle')

  TriggerServerEvent('aln:spawn:onboardingCommit', {
    baseModel = modelOpt.model,
    starterVehicleModel = vehOpt.model
  })
end

RegisterNetEvent('aln:spawn:begin', function(payload)
  dbg('spawn.begin', payload)

  if payload.onboardingDone == false then
    runOnboarding(payload)
    return
  end

  -- Spawn player at last location
  doSpawnPlayer(payload)

  -- Spawn starter vehicle if set
  if payload.starterVehicleModel and payload.starterVehiclePlate then
    CreateThread(function()
      Wait(1200)
      ALN.SpawnVeh.Spawn(payload.starterVehicleModel, payload.starterVehiclePlate)
    end)
  end
end)

RegisterNetEvent('aln:spawn:onboardingResult', function(res)
  if not res or not res.ok then
    dbg('spawn.onboarding_fail', res or {})
    return
  end

  dbg('spawn.onboarding_ok', res)

  -- Use returned payload to spawn now
  if res.payload then
    TriggerEvent('aln:spawn:begin', res.payload)
  end
end)

RegisterNetEvent('aln:spawn:deny', function(res)
  dbg('spawn.deny', res or {})
end)

-- Debug: force request
RegisterCommand('aln_spawn', function()
  TriggerServerEvent('aln:spawn:request')
end, false)
