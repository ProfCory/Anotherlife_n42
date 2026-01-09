ALN = ALN or {}

local function findRoadsideSpawnNear(target, minD, maxD)
  -- crude but cheap: pick random points around the player and find a safe spot
  for _=1, 18 do
    local ang = math.random() * math.pi * 2
    local d = minD + math.random() * (maxD - minD)
    local x = target.x + math.cos(ang) * d
    local y = target.y + math.sin(ang) * d
    local z = target.z + 50.0

    local found, outPos, outHeading = GetNthClosestVehicleNodeWithHeading(x, y, z, 1, 0, 0, 0)
    if found then
      return vector3(outPos.x, outPos.y, outPos.z), outHeading
    end
  end
  return nil, 0.0
end

local function loadModel(hash)
  if not IsModelInCdimage(hash) then return false end
  RequestModel(hash)
  local t = GetGameTimer() + 5000
  while not HasModelLoaded(hash) and GetGameTimer() < t do Wait(10) end
  return HasModelLoaded(hash)
end

local function createVehicle(modelHash, coords, heading)
  if not loadModel(modelHash) then return nil end
  local veh = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading or 0.0, true, false)
  SetEntityAsMissionEntity(veh, true, true)
  SetVehicleOnGroundProperly(veh)
  return veh
end

local function createPedInVehicle(veh, pedHash)
  if not loadModel(pedHash) then return nil end
  local ped = CreatePedInsideVehicle(veh, 26, pedHash, -1, true, false)
  SetEntityAsMissionEntity(ped, true, true)
  SetPedKeepTask(ped, true)
  return ped
end

function ALN_Services_SpawnAndDrive(job, vehModel, pedModel, driveFlags)
  local pcoords = job.player.coords
  local spawnMin = job.config.spawnMin or 80.0
  local spawnMax = job.config.spawnMax or 160.0

  local spawnPos, spawnH = findRoadsideSpawnNear(pcoords, spawnMin, spawnMax)
  if not spawnPos then return false, 'no_spawn' end

  local veh = createVehicle(vehModel, spawnPos, spawnH)
  if not veh then return false, 'veh_fail' end

  local ped = createPedInVehicle(veh, pedModel)
  if not ped then
    DeleteEntity(veh)
    return false, 'ped_fail'
  end

  SetDriverAbility(ped, 1.0)
  SetDriverAggressiveness(ped, 0.35)
  SetPedCombatAttributes(ped, 46, true) -- BF_CanFightArmedPeds (harmless in most cases)

  TaskVehicleDriveToCoordLongrange(
    ped, veh,
    pcoords.x, pcoords.y, pcoords.z,
    22.0,
    driveFlags or 786603,
    10.0
  )

  return true, { veh = veh, ped = ped }
end

function ALN_Services_Cleanup(ent, delayMs)
  CreateThread(function()
    Wait(delayMs or 1000)
    if ent and ent.ped and DoesEntityExist(ent.ped) then DeleteEntity(ent.ped) end
    if ent and ent.veh and DoesEntityExist(ent.veh) then DeleteEntity(ent.veh) end
  end)
end
