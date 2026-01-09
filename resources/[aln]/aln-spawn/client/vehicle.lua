ALN = ALN or {}
ALN.SpawnVeh = ALN.SpawnVeh or {}

local function loadModel(model)
  local hash = type(model) == 'number' and model or GetHashKey(model)
  if not IsModelInCdimage(hash) then return false end
  RequestModel(hash)
  local t = GetGameTimer() + 8000
  while not HasModelLoaded(hash) and GetGameTimer() < t do Wait(10) end
  return HasModelLoaded(hash), hash
end

local function findVehicleSpawnNear(ped, forward, right)
  local p = GetEntityCoords(ped)
  local h = GetEntityHeading(ped)
  local f = forward or 6.0
  local r = right or 2.0

  local fx = p.x + (math.cos(math.rad(h)) * f) + (math.cos(math.rad(h + 90.0)) * r)
  local fy = p.y + (math.sin(math.rad(h)) * f) + (math.sin(math.rad(h + 90.0)) * r)
  local fz = p.z + 1.0

  local found, outPos, outHeading = GetNthClosestVehicleNodeWithHeading(fx, fy, fz, 1, 0, 0, 0)
  if found then
    return vector3(outPos.x, outPos.y, outPos.z), outHeading
  end
  return vector3(fx, fy, fz), h
end

function ALN.SpawnVeh.Spawn(modelName, plate)
  local ok, hash = loadModel(modelName)
  if not ok then return false, 'bad_model' end

  local ped = PlayerPedId()
  local pos, heading = findVehicleSpawnNear(ped, Config.Spawn.VehicleSpawn.OffsetForward, Config.Spawn.VehicleSpawn.OffsetRight)

  local veh = CreateVehicle(hash, pos.x, pos.y, pos.z, heading or 0.0, true, false)
  if not veh or veh == 0 then return false, 'spawn_fail' end

  SetEntityAsMissionEntity(veh, true, true)
  SetVehicleOnGroundProperly(veh)

  if plate and plate ~= '' then
    SetVehicleNumberPlateText(veh, plate)
  end

  SetModelAsNoLongerNeeded(hash)
  return true, veh
end
