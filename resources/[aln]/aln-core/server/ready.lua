ALN = ALN or {}
ALN.Core = ALN.Core or {}

local _ready = false
local _readyAt = 0
local _callbacks = {}

local function flushCallbacks()
  for _, fn in ipairs(_callbacks) do
    local ok, err = pcall(fn)
    if not ok then
      ALN.Log.Error('core.ready.callback_failed', { err = tostring(err) })
    end
  end
  _callbacks = {}
end

function ALN.Core.IsReady()
  return _ready
end

-- Register a function to run once when core is ready.
function ALN.Core.OnReady(fn)
  if type(fn) ~= 'function' then return end
  if _ready then
    local ok, err = pcall(fn)
    if not ok then
      ALN.Log.Error('core.ready.callback_failed', { err = tostring(err) })
    end
    return
  end
  table.insert(_callbacks, fn)
end

-- Mark core ready (server-only)
function ALN.Core._SetReady()
  if _ready then return end
  _ready = true
  _readyAt = GetGameTimer()

  ALN.Log.Info('core.ready', { readyAtMs = _readyAt })
  TriggerEvent(ALN.Events.CoreReady)

  flushCallbacks()
end

-- Exported helpers
exports('IsReady', function() return ALN.Core.IsReady() end)
exports('OnReady', function(fn) ALN.Core.OnReady(fn) end)
