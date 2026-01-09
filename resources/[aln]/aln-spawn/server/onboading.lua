ALN = ALN or {}
ALN.Spawn = ALN.Spawn or {}
ALN.Spawn.Onboarding = ALN.Spawn.Onboarding or {}

local function dbg(ev, f)
  if Config.Spawn.Debug then ALN.Log.Debug(ev, f or {}) end
end

local function genPlate(charId)
  -- deterministic-ish, readable, within plate limits
  local n = tonumber(charId) or 0
  local tail = (n % 99999)
  return ('ALN%05d'):format(tail)
end

function ALN.Spawn.Onboarding.IsDone(charRow)
  return (tonumber(charRow.onboarding_done) or 0) == 1
end

function ALN.Spawn.Onboarding.GetStarter(charRow)
  return charRow.starter_vehicle_model, charRow.starter_vehicle_plate
end

function ALN.Spawn.Onboarding.SetBaseModel(charId, model)
  exports['aln-db']:Update([[
    UPDATE aln3_characters
    SET base_model=?, model=?, updated_at=?
    WHERE id=?
  ]], { model, model, exports['aln-persistent-data']:GetCharacterById(charId).updated_at or os.date('!%Y-%m-%dT%H:%M:%SZ'), charId })
end

function ALN.Spawn.Onboarding.Commit(charId, baseModel, starterVehModel)
  local plate = genPlate(charId)
  local now = os.date('!%Y-%m-%dT%H:%M:%SZ')

  exports['aln-db']:Update([[
    UPDATE aln3_characters
    SET onboarding_done=1,
        base_model=?,
        model=?,
        starter_vehicle_model=?,
        starter_vehicle_plate=?,
        updated_at=?
    WHERE id=?
  ]], { baseModel, baseModel, starterVehModel, plate, now, charId })

  dbg('spawn.onboarding_commit', { charId = charId, baseModel = baseModel, starterVehModel = starterVehModel, plate = plate })
  return true, { plate = plate }
end
