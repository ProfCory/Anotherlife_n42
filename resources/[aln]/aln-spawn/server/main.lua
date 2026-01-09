-- aln-spawn/server/main.lua
-- Server-authoritative spawn coordinator

local Log
local Spawn = {}

-- ===== Helpers =====

local function dbg(event, fields)
  if not Log then return end
  if Config.Spawn and Config.Spawn.Debug then
    Log.Debug(event, fields or {})
  end
end

-- ===== Core Logic =====

CreateThread(function()
  exports['aln-core']:OnReady(function()
    Log = exports['aln-core']:Log()

    Log.Info('spawn.start', {
      resource = GetCurrentResourceName()
    })

    -- Ensure slot 1 active for now (temporary until slot picker)
    AddEventHandler('playerJoining', function()
      local src = source

      local charId = exports['aln-persistent-data']:GetActiveCharacterId(src)
      if not charId then
        exports['aln-persistent-data']:SetActiveSlot(src, 1)
      end

      local payload, reason = Spawn.GetSpawnFor(src)
      if not payload then
        dbg('spawn.join_fail', { src = src, reason = reason })
        return
      end

      TriggerClientEvent('aln:spawn:begin', src, payload)
    end)

    -- Client requests snapshot (fallback)
    RegisterNetEvent('aln:spawn:request', function()
      local src = source

      local payload, reason = Spawn.GetSpawnFor(src)
      if not payload then
        TriggerClientEvent('aln:spawn:deny', src, { reason = reason })
        return
      end

      TriggerClientEvent('aln:spawn:begin', src, payload)
    end)

    -- Onboarding commit from client
    RegisterNetEvent('aln:spawn:onboardingCommit', function(data)
      local src = source
      data = data or {}

      local charId = exports['aln-persistent-data']:GetActiveCharacterId(src)
      if not charId then
        TriggerClientEvent('aln:spawn:onboardingResult', src, {
          ok = false,
          reason = 'no_active_char'
        })
        return
      end

      local baseModel = tostring(data.baseModel or '')
      local starterVeh = tostring(data.starterVehicleModel or '')

      if baseModel == '' or starterVeh == '' then
        TriggerClientEvent('aln:spawn:onboardingResult', src, {
          ok = false,
          reason = 'bad_data'
        })
        return
      end

      local ok, res = Spawn.Onboarding.Commit(charId, baseModel, starterVeh)
      if not ok then
        TriggerClientEvent('aln:spawn:onboardingResult', src, {
          ok = false,
          reason = 'db_fail'
        })
        return
      end

      exports['aln-persistent-data']:SetLastPosition(
        src,
        Config.Spawn.DefaultStart.coords,
        Config.Spawn.DefaultStart.heading
      )

      local payload = Spawn.GetSpawnFor(src)
      TriggerClientEvent('aln:spawn:onboardingResult', src, {
        ok = true,
        plate = res.plate,
        payload = payload
      })
    end)
  end)
end)
