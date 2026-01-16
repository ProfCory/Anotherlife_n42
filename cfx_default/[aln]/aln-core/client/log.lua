ALN = ALN or {}
ALN.Log = ALN.Log or {}

local function _printLine(level, payload)
  print(('[ALN3][%s] %s'):format(level, json.encode(payload)))
end

function ALN.Log.Write(level, event, fields)
  fields = fields or {}
  local payload = {
    ts = GetGameTimer(),
    resource = GetCurrentResourceName(),
    level = level,
    event = event,
    fields = fields
  }

  if level == 'debug' and not (Config and Config.Core and Config.Core.Debug) then
    return
  end

  _printLine(level, payload)
end

function ALN.Log.Debug(event, fields) ALN.Log.Write('debug', event, fields) end
function ALN.Log.Info(event, fields)  ALN.Log.Write('info',  event, fields) end
function ALN.Log.Warn(event, fields)  ALN.Log.Write('warn',  event, fields) end
function ALN.Log.Error(event, fields) ALN.Log.Write('error', event, fields) end
