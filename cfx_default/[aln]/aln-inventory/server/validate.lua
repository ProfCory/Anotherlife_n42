ALN = ALN or {}
ALN.Inv = ALN.Inv or {}

local function dbg(ev, f)
  if Config and Config.Inventory and Config.Inventory.Debug then
    ALN.Log.Debug(ev, f or {})
  end
end

local function isPositiveInt(n) return type(n) == 'number' and n >= 1 and math.floor(n) == n end

function ALN.Inv.GetItemDef(itemKey)
  return exports['aln-items']:GetItem(itemKey)
end

function ALN.Inv.ValidateAdd(itemKey, count, meta)
  local def = ALN.Inv.GetItemDef(itemKey)
  if not def then return false, 'unknown_item' end

  -- weapons/ammo stay out of inventory domain
  if def.domain == 'weapon' or def.domain == 'ammo' then
    return false, 'weaponwheel_domain'
  end

  if not isPositiveInt(count) then return false, 'bad_count' end
  return true, def
end

function ALN.Inv.GetMaxStack(def)
  if def.stackable == true then
    if type(def.maxStack) == 'number' and def.maxStack >= 1 then return math.floor(def.maxStack) end
    return Config.Inventory.MaxStackDefault or 10
  end
  return 1
end

function ALN.Inv.CanStack(def)
  return def.stackable == true
end

return dbg
