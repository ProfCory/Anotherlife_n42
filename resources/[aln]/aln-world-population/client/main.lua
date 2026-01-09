ALN = ALN or {}

local function dbg(ev, f)
  if Config.WorldPop.Debug then
    ALN.Log.Debug(ev, f or {})
  end
end

local function applyDensities()
  local d = Config.WorldPop.Density

  -- Every-frame multipliers (Rockstar pattern)
  SetPedDensityMultiplierThisFrame(d.Ped or 1.0)
  SetScenarioPedDensityMultiplierThisFrame(d.ScenarioPed or 1.0, d.ScenarioPed or 1.0)

  SetVehicleDensityMultiplierThisFrame(d.Vehicle or 1.0)
  SetParkedVehicleDensityMultiplierThisFrame(d.ParkedVehicle or 1.0)
  SetRandomVehicleDensityMultiplierThisFrame(d.RandomVehicle or 1.0)

  -- Optional near-player soft cap
  if Config.WorldPop.NearPlayer and Config.WorldPop.NearPlayer.Enabled then
    -- We don’t hard-delete; we just slightly reduce densities.
    -- (Hard deletion should be handled elsewhere if desired.)
    local ped = PlayerPedId()
    if ped ~= 0 then
      local p = GetEntityCoords(ped)
      -- cheap approximation: if in dense area, nudge down a bit
      -- (We avoid heavy entity scanning.)
      if IsPedInAnyVehicle(ped, false) then
        SetVehicleDensityMultiplierThisFrame((d.Vehicle or 1.0) * (Config.WorldPop.NearPlayer.VehicleMultiplier or 1.0))
      else
        SetPedDensityMultiplierThisFrame((d.Ped or 1.0) * (Config.WorldPop.NearPlayer.PedMultiplier or 1.0))
      end
    end
  end
end

AddEventHandler('onClientResourceStart', function(res)
  if res ~= GetCurrentResourceName() then return end
  dbg('worldpop.client_start', {
    Enabled = Config.WorldPop.Enabled,
    densities = Config.WorldPop.Density,
  })

  -- Apply one-time toggles
  if Config.WorldPop.Enabled and Config.WorldPop.ManageScenarios then
    ALN_WorldPop_ApplyScenarioToggles()
  end

  if Config.WorldPop.Enabled and Config.WorldPop.ManageDispatch then
    ALN_WorldPop_ApplyDispatchToggles()
  end
end)

CreateThread(function()
  while true do
    if Config.WorldPop.Enabled and Config.WorldPop.ManageDensities then
      applyDensities()
      Wait(0) -- every frame
    else
      Wait(500)
    end
  end
end)

-- Debug command (client)
RegisterCommand('aln_worldpop_print', function()
  print('[ALN3] WorldPop Config: ' .. json.encode(Config.WorldPop))
end, false)
