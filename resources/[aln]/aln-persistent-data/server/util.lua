ALN = ALN or {}
ALN.Persistent = ALN.Persistent or {}

function ALN.Persistent.NowIso()
  return os.date('!%Y-%m-%dT%H:%M:%SZ')
end

function ALN.Persistent.OwnerKeyFromSrc(src)
  return exports['aln-core']:GetPlayerKey(src) or ('src:%d'):format(src)
end

local function dbg(ev, f)
  if Config and Config.Persistent and Config.Persistent.Debug then
    ALN.Log.Debug(ev, f or {})
  end
end

ALN.Persistent._dbg = dbg
