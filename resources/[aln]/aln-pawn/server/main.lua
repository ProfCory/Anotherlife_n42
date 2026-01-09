ALN = ALN or {}
ALN.Pawn = ALN.Pawn or {}

local function dbg(ev, f)
  if Config.Pawn.Debug then
    ALN.Log.Debug(ev, f or {})
  end
end

local function vec3(t) return vector3(t.x, t.y, t.z) end
local function dist(a, b)
  local dx = a.x-b.x; local dy = a.y-b.y; local dz = a.z-b.z
  return math.sqrt(dx*dx+dy*dy+dz*dz)
end

local function getPlayerCoordsServer(src)
  local ped = GetPlayerPed(src)
  if ped and ped ~= 0 then
    local c = GetEntityCoords(ped)
    if c then return c end
  end
  return nil
end

local function validateNearPawn(src, coords)
  if not (Config.Pawn.RequireLocation == true) then return true end
  local list = exports['aln-locations']:FindByTag(Config.Pawn.LocationTag) or {}
  local best = 1e12
  for _, e in ipairs(list) do
    local c = e.loc.coords
    local d = dist(coords, c)
    if d < best then best = d end
  end
  return best <= (Config.Pawn.UseDist or 1.8)
end

-- client asks what they could sell: we’ll return only configured prices (not reading inventory yet)
RegisterNetEvent('aln:pawn:catalog', function()
  local src = source
  local out = {}
  for k, v in pairs(PawnPrices or {}) do
    out[#out+1] = { item = k, base = v.base, variants = v.variants }
  end
  TriggerClientEvent('aln:pawn:catalog', src, out)
end)

-- Execute a sell
-- payload.items = { {item="loot_valuable", count=1, meta={variant="ring"}}, ... }
RegisterNetEvent('aln:pawn:sell', function(payload)
  local src = source
  payload = payload or {}

  local coords = getPlayerCoordsServer(src)
  if not coords and payload.coords then coords = vec3(payload.coords) end
  if coords and not validateNearPawn(src, coords) then
    TriggerClientEvent('aln:pawn:result', src, { ok=false, reason='not_near_pawn' })
    return
  end

  local items = payload.items
  if type(items) ~= 'table' or #items < 1 then
    TriggerClientEvent('aln:pawn:result', src, { ok=false, reason='bad_items' })
    return
  end

  local maxItems = tonumber(Config.Pawn.MaxItemsPerSell or 10) or 10
  if #items > maxItems then
    TriggerClientEvent('aln:pawn:result', src, { ok=false, reason='too_many_items' })
    return
  end

  local total = 0
  local priced = {}

  -- First: price everything and validate it is pawnable
  for i, it in ipairs(items) do
    local itemKey = tostring(it.item or '')
    local count = math.floor(tonumber(it.count or 1) or 1)
    if itemKey == '' or count <= 0 then
      TriggerClientEvent('aln:pawn:result', src, { ok=false, reason='bad_entry' })
      return
    end

    local def = exports['aln-items']:GetItem(itemKey)
    if not def then
      TriggerClientEvent('aln:pawn:result', src, { ok=false, reason='unknown_item', item=itemKey })
      return
    end

    local price = ALN.Pawn.PriceOne(itemKey, count, it.meta)
    if not price then
      TriggerClientEvent('aln:pawn:result', src, { ok=false, reason='not_accepted', item=itemKey })
      return
    end

    total = total + price
    priced[#priced+1] = { item=itemKey, count=count, meta=it.meta, price=price }
  end

  local cap = tonumber(Config.Pawn.MaxPayout or 50000) or 50000
  if total > cap then total = cap end

  -- Second: remove items from pockets (v0 sells only from pockets)
  -- If any removal fails, abort with no payout. (No partial sells in v0.)
  for _, p in ipairs(priced) do
    local ok, reason = exports['aln-inventory']:RemoveFromPockets(src, p.item, p.count, p.meta)
    if not ok then
      TriggerClientEvent('aln:pawn:result', src, { ok=false, reason='missing_items', item=p.item, detail=reason })
      return
    end
  end

  -- Third: credit cash
  local okPay = exports['aln-economy']:Credit(src, Config.Pawn.OutAccount or 'cash', total, 'pawn.sell', {
    items = priced,
    total = total
  })

  if not okPay then
    -- best-effort rollback: give items back
    for _, p in ipairs(priced) do
      exports['aln-inventory']:AddToPockets(src, p.item, p.count, p.meta)
    end
    TriggerClientEvent('aln:pawn:result', src, { ok=false, reason='pay_failed' })
    return
  end

  dbg('pawn.sell_ok', { src=src, total=total, n=#priced })
  TriggerClientEvent('aln:pawn:result', src, { ok=true, total=total, items=priced })
end)

AddEventHandler('onResourceStart', function(res)
  if res ~= GetCurrentResourceName() then return end
  ALN.Log.Info('pawn.start', {})
end)
