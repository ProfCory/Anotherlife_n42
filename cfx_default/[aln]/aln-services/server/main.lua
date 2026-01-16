ALN = ALN or {}
ALN.Services = ALN.Services or {}

AddEventHandler('onResourceStart', function(res)
  if res ~= GetCurrentResourceName() then return end

  -- build station cache
  ALN.Services.Registry.Refresh()

  ALN.Log.Info('services.start', {})
end)

-- Server events from client (UI/radial/phone later)
RegisterNetEvent('aln:services:call', function(serviceType, opts)
  local src = source
  opts = opts or {}
  -- If server can't read coords (non-OneSync), allow client to provide coords.
  if opts.coords and type(opts.coords) ~= 'vector3' then
    opts.coords = vector3(opts.coords.x, opts.coords.y, opts.coords.z)
  end
  if opts.waypoint and type(opts.waypoint) ~= 'vector3' then
    opts.waypoint = vector3(opts.waypoint.x, opts.waypoint.y, opts.waypoint.z)
  end

  local ok, res = exports['aln-services']:RequestService(src, serviceType, opts)
  TriggerClientEvent('aln:services:callResult', src, { ok = ok, res = res, type = serviceType })
end)

-- Taxi payment finalize (client sends fare estimate; server clamps)
RegisterNetEvent('aln:services:taxi:pay', function(payload)
  local src = source
  payload = payload or {}
  local fee = math.floor(tonumber(payload.fee or 0) or 0)
  if fee < 0 then fee = 0 end
  local maxFee = (Config.Services.Taxi and Config.Services.Taxi.MaxFee) or 2500
  if fee > maxFee then fee = maxFee end

  local account = (Config.Services.Taxi and Config.Services.Taxi.PayAccount) or 'cash'
  local ok = exports['aln-economy']:Debit(src, account, fee, 'taxi.fare', { fee = fee })

  if not ok and (Config.Services.Taxi and Config.Services.Taxi.AllowBankFallback) then
    ok = exports['aln-economy']:Debit(src, 'bank', fee, 'taxi.fare_bank', { fee = fee })
  end

  TriggerClientEvent('aln:services:taxi:payResult', src, { ok = ok == true, fee = fee })
end)
