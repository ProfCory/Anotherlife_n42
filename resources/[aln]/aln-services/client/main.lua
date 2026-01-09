ALN = ALN or {}

local function dbg(ev, f)
  if Config.Services.Debug then
    ALN.Log.Debug(ev, f or {})
  end
end

local activeJob = nil

RegisterNetEvent('aln:services:job', function(job)
  activeJob = job
  dbg('services.job_recv', { jobId = job.jobId, type = job.type })

  if job.type == 'police' then
    local ok, ent = ALN_Services_SpawnAndDrive(job, `POLICE`, `S_M_Y_COP_01`)
    if ok then
      -- siren + lights on approach
      SetVehicleSiren(ent.veh, true)
      SetVehicleHasMutedSirens(ent.veh, false)
      Wait((job.config.dwell or 45) * 1000)
      ALN_Services_Cleanup(ent, 1)
    end
    return
  end

  if job.type == 'ems' then
    local ok, ent = ALN_Services_SpawnAndDrive(job, `AMBULANCE`, `S_M_M_PARAMEDIC_01`)
    if ok then
      SetVehicleSiren(ent.veh, true)
      Wait((job.config.dwell or 45) * 1000)
      ALN_Services_Cleanup(ent, 1)
    end
    return
  end

  if job.type == 'fire' then
    local ok, ent = ALN_Services_SpawnAndDrive(job, `FIRETRUK`, `S_M_Y_FIREMAN_01`)
    if ok then
      SetVehicleSiren(ent.veh, true)
      Wait((job.config.dwell or 45) * 1000)
      ALN_Services_Cleanup(ent, 1)
    end
    return
  end

  if job.type == 'taxi' then
    -- Taxi: spawn taxi, drive to player, then to waypoint if set
    local ok, ent = ALN_Services_SpawnAndDrive(job, `TAXI`, `S_M_M_TAXIDRIVER_01`)
    if not ok then return end

    -- When close to player: allow entry; then drive to waypoint
    CreateThread(function()
      local ped = PlayerPedId()
      local p = GetEntityCoords(ped)

      -- wait taxi arrives
      local timeout = GetGameTimer() + 90000
      while GetGameTimer() < timeout do
        if DoesEntityExist(ent.veh) then
          local vpos = GetEntityCoords(ent.veh)
          if #(vpos - p) < 18.0 then break end
        end
        Wait(500)
      end

      -- Drive to waypoint if exists
      local wp = job.waypoint
      if wp then
        -- estimate fee by straight-line distance (good enough for v0)
        local distM = #(wp - p)
        local km = distM / 1000.0
        local base = (Config.Services.Taxi and Config.Services.Taxi.BaseFee) or 40
        local perKm = (Config.Services.Taxi and Config.Services.Taxi.PerKm) or 18
        local fee = math.floor(base + (km * perKm))

        -- send driver to waypoint
        TaskVehicleDriveToCoordLongrange(ent.ped, ent.veh, wp.x, wp.y, wp.z, 24.0, 786603, 10.0)

        -- wait until close to waypoint
        while DoesEntityExist(ent.veh) do
          local vpos = GetEntityCoords(ent.veh)
          if #(vpos - wp) < 18.0 then break end
          Wait(1000)
        end

        TriggerServerEvent('aln:services:taxi:pay', { fee = fee })
      end

      Wait(15000)
      ALN_Services_Cleanup(ent, 1)
    end)

    return
  end
end)

RegisterNetEvent('aln:services:callResult', function(payload)
  dbg('services.call_result', payload or {})
end)

RegisterNetEvent('aln:services:taxi:payResult', function(payload)
  dbg('services.taxi_pay_result', payload or {})
end)

-- Debug client commands (temporary)
RegisterCommand('aln_call_police', function()
  TriggerServerEvent('aln:services:call', 'police', {})
end, false)

RegisterCommand('aln_call_ems', function()
  TriggerServerEvent('aln:services:call', 'ems', {})
end, false)

RegisterCommand('aln_call_fire', function()
  TriggerServerEvent('aln:services:call', 'fire', {})
end, false)

RegisterCommand('aln_call_taxi', function()
  local wp = nil
  if IsWaypointActive() then
    local blip = GetFirstBlipInfoId(8)
    local c = GetBlipInfoIdCoord(blip)
    wp = vector3(c.x, c.y, c.z)
  end
  TriggerServerEvent('aln:services:call', 'taxi', { waypoint = wp })
end, false)
