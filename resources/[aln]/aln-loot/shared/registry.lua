ALN = ALN or {}
ALN.Loot = ALN.Loot or {}
ALN_LOOT_MODULES = ALN_LOOT_MODULES or {}

local function dbg(ev, f)
  if Config and Config.Loot and Config.Loot.Debug then
    ALN.Log.Debug(ev, f or {})
  end
end

local function err(msg)
  if Config and Config.Loot and Config.Loot.StrictValidation then
    error(msg)
  else
    ALN.Log.Error('loot.validation', { msg = msg })
  end
end

local function validatePool(id, p)
  if type(p) ~= 'table' then err(('Pool %s not a table'):format(id)); return end
  if type(p.label) ~= 'string' or p.label == '' then err(('Pool %s missing label'):format(id)) end
  if type(p.rolls) ~= 'table' or type(p.rolls.min) ~= 'number' or type(p.rolls.max) ~= 'number' then
    err(('Pool %s rolls must be {min,max}'):format(id))
  end
  if p.rolls.min < 0 or p.rolls.max < p.rolls.min then err(('Pool %s invalid rolls range'):format(id)) end
  if type(p.entries) ~= 'table' or #p.entries < 1 then err(('Pool %s missing entries'):format(id)) end

  if Config.Loot.ValidateItems then
    local items = exports['aln-items']:GetAll()
    for i, e in ipairs(p.entries) do
      if e.item ~= nil then
        if not items[e.item] then
          err(('Pool %s entry %d references unknown item "%s"'):format(id, i, tostring(e.item)))
        end
      end
      if type(e.w) ~= 'number' or e.w <= 0 then
        err(('Pool %s entry %d invalid weight'):format(id, i))
      end
    end
  end
end

local function build()
  local out = {}
  for moduleName, tbl in pairs(ALN_LOOT_MODULES) do
    if type(tbl) ~= 'table' then
      err(('Loot module "%s" is not a table'):format(moduleName))
    else
      for id, pool in pairs(tbl) do
        if out[id] then err(('Duplicate loot pool id "%s" (module %s)'):format(id, moduleName)) end
        out[id] = pool
        validatePool(id, pool)
      end
    end
  end
  return out
end

ALN.Loot.Registry = build()

exports('GetPool', function(id) return ALN.Loot.Registry[id] end)
exports('GetAllPools', function() return ALN.Loot.Registry end)

dbg('loot.registry_ready', { count = (function() local c=0; for _ in pairs(ALN.Loot.Registry) do c=c+1 end; return c end)() })
