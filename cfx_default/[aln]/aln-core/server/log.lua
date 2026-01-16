-- aln-core/server/log.lua
-- Canonical ALN3 structured logger (server-side)

ALN = ALN or {}
ALN.Log = {}

local Log = {}
Log.__index = Log

local function safeJsonEncode(obj)
  if ALN.Util and ALN.Util.SafeJsonEncode then
    return ALN.Util.SafeJsonEncode(obj)
  end

  -- Fallback: best-effort JSON
  local ok, json = pcall(json.encode, obj)
  return ok and json or '{"error":"json_encode_failed"}'
end

local function printLine(level, payload)
  -- Single-line JSON for grepability
  print(('[ALN3][%s] %s'):format(level, safeJsonEncode(payload)))
end

local function write(level, event, fields)
  fields = fields or {}

  if level == 'debug' and not (Config and Config.Core and Config.Core.Debug) then
    return
  end

  local payload = {
    ts = os.date('!%Y-%m-%dT%H:%M:%SZ'),
    resource = GetCurrentResourceName(),
    level = level,
    event = event,
    fields = fields
  }

  printLine(level, payload)
end

-- Public API
function Log.Debug(event, fields) write('debug', event, fields) end
function Log.Info(event, fields)  write('info',  event, fields) end
function Log.Warn(event, fields)  write('warn',  event, fields) end
function Log.Error(event, fields) write('error', event, fields) end

-- Attach to ALN namespace for internal use
ALN.Log = Log

-- 🔑 EXPORT (this was missing)
exports('Log', function()
  return Log
end)

-- Optional: immediate availability signal
CreateThread(function()
  write('info', 'log.ready', {})
end)
