ALN = ALN or {}
ALN.DB = ALN.DB or {}

local function dbg(event, fields)
  if Config and Config.DB and Config.DB.Debug then
    ALN.Log.Debug(event, fields or {})
  end
end

ALN.DB._dbg = dbg

function ALN.DB._nowIso()
  return os.date('!%Y-%m-%dT%H:%M:%SZ')
end
