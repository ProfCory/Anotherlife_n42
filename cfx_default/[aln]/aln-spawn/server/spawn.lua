ALN = ALN or {}
ALN.Spawn = ALN.Spawn or {}

local function dbg(ev, f)
  if Config.Spawn.Debug then ALN.Log.Debug(ev, f or {}) end
end

local function rowToVec(row)
  return vector3(tonumber(row.last_x) or 0, tonumber(row.last_y) or 0, tonumber(row.last_z) or 0), tonumber(row.last_h) or 0.0
end

function ALN.Spawn.GetSpawnFor(src)
  local charId = exports['aln-persistent-data']:GetActiveCharacterId(src)
  if not charId then
    return nil, 'no_active_char'
  end

  local c = exports['aln-persistent-data']:GetCharacterById(charId)
  if not c then
    return nil, 'missing_char'
  end

  local onboardingDone = (tonumber(c.onboarding_done) or 0) == 1
  local coords, heading = rowToVec(c)

  -- If last pos is zeroed (new char), use default start
  if coords.x == 0 and coords.y == 0 and coords.z == 0 then
    coords = Config.Spawn.DefaultStart.coords
    heading = Config.Spawn.DefaultStart.heading
  end

  local payload = {
    charId = charId,
    onboardingDone = onboardingDone,
    coords = { x = coords.x, y = coords.y, z = coords.z },
    heading = heading,
    baseModel = c.base_model or c.model or (Config.Persistent and Config.Persistent.Defaults and Config.Persistent.Defaults.model) or 'mp_m_freemode_01',
    starterVehicleModel = c.starter_vehicle_model,
    starterVehiclePlate = c.starter_vehicle_plate,
  }

  dbg('spawn.payload', { src = src, charId = charId, onboardingDone = onboardingDone })
  return payload, nil
end
