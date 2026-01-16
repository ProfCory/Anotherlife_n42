ALN = ALN or {}
ALN.Core = ALN.Core or {}

local _ready = false
local _callbacks = {}

function ALN.Core.IsReady()
  return _ready
end

function ALN.Core.OnReady(fn)
  if type(fn) ~= 'function' then return end
  if _ready then
    pcall(fn)
    return
  end
  table.insert(_callbacks, fn)
end

local function flush()
  for _, fn in ipairs(_callbacks) do
    pcall(fn)
  end
  _callbacks = {}
end

RegisterNetEvent(ALN.Events.CoreReady, function()
  if _ready then return end
  _ready = true
  ALN.Log.Info('core.ready', {})
  flush()
end)

exports('IsReady', function() return ALN.Core.IsReady() end)
exports('OnReady', function(fn) ALN.Core.OnReady(fn) end)
