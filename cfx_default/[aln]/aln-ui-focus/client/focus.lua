ALN = ALN or {}
ALN.UIFocus = ALN.UIFocus or {}

local state = {
  -- stack entries: { uiId, token, opts, openedAt }
  stack = {},
  registry = {}, -- uiId -> { onCloseEvent?, nuiCloseMsgType?, allowOverlap?, allowStack?, keepInput?, disableControls? }
  tokenCounter = 0,
}

local function dbg(event, fields)
  if Config and Config.UIFocus and Config.UIFocus.Debug then
    ALN.Log.Debug(event, fields or {})
  end
end

local function nextToken()
  state.tokenCounter = state.tokenCounter + 1
  return ('%s:%d'):format(GetCurrentResourceName(), state.tokenCounter)
end

local function top()
  return state.stack[#state.stack]
end

local function emitChanged()
  local t = top()
  TriggerEvent(ALN.UIFocus.Events.Changed, t and t.uiId or nil, t and t.token or nil, t and t.opts or nil)
end

-- Register a UI with default behavior + close routing info
-- cfg:
--   allowOverlap (bool)
--   allowStack (bool)
--   keepInput (bool) => SetNuiFocusKeepInput
--   disableControls (bool)
--   onCloseEvent (string) => client event to trigger on close
--   nuiCloseMsgType (string) => SendNUIMessage({type=...}) when close is requested
function ALN.UIFocus.Register(uiId, cfg)
  if type(uiId) ~= 'string' or uiId == '' then return false end
  state.registry[uiId] = cfg or {}
  dbg('uiFocus.register', { uiId = uiId })
  return true
end

function ALN.UIFocus.Get()
  local t = top()
  if not t then return nil end
  return { uiId = t.uiId, token = t.token, opts = t.opts }
end

function ALN.UIFocus.IsFocused()
  return top() ~= nil
end

-- Internal: apply actual NUI focus + keep input + cursor
local function applyNuiFocus(active)
  if not active then
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    return
  end

  local reg = state.registry[active.uiId] or {}
  local keepInput = (active.opts and active.opts.keepInput)
    if keepInput == nil then keepInput = reg.keepInput end
  if keepInput == nil then keepInput = false end

  local cursor = (active.opts and active.opts.cursor)
  if cursor == nil then cursor = true end

  SetNuiFocus(true, cursor)
  SetNuiFocusKeepInput(keepInput == true)
end

-- Can we place a new UI request given current top?
local function canAcquire(newUiId, opts)
  local current = top()
  if not current then return true end

  opts = opts or {}
  if opts.force == true then return true end

  local curReg = state.registry[current.uiId] or {}
  local newReg = state.registry[newUiId] or {}

  local curAllowOverlap = (curReg.allowOverlap ~= nil) and curReg.allowOverlap or (Config.UIFocus.DefaultAllowOverlap == true)
  local newAllowOverlap = (newReg.allowOverlap ~= nil) and newReg.allowOverlap or (Config.UIFocus.DefaultAllowOverlap == true)

  -- Overlap means "replace without stack"
  if curAllowOverlap and newAllowOverlap then
    return true
  end

  -- Stacking means "push onto stack"
  local curAllowStack = (curReg.allowStack ~= nil) and curReg.allowStack or (Config.UIFocus.DefaultAllowStack == true)
  local newAllowStack = (newReg.allowStack ~= nil) and newReg.allowStack or (Config.UIFocus.DefaultAllowStack == true)

  if opts.stack == true and curAllowStack and newAllowStack then
    return true
  end

  return false
end

-- Acquire focus for uiId
-- opts:
--   stack (bool) => if true, pushes onto stack (only if allowed)
--   keepInput (bool) override
--   cursor (bool) override
--   force (bool) dev/admin override (avoid using in production)
-- Returns: token|string|nil, reason|string|nil
function ALN.UIFocus.Acquire(uiId, opts)
  if type(uiId) ~= 'string' or uiId == '' then
    return nil, 'invalid_uiId'
  end

  opts = opts or {}

  if not canAcquire(uiId, opts) then
    dbg('uiFocus.acquire_denied', { uiId = uiId, current = top() and top().uiId or nil })
    return nil, 'denied_overlap'
  end

  local token = nextToken()

  local current = top()
  if current and opts.stack ~= true then
    -- replace top
    state.stack[#state.stack] = { uiId = uiId, token = token, opts = opts, openedAt = GetGameTimer() }
    dbg('uiFocus.acquire_replace', { from = current.uiId, to = uiId, token = token })
  else
    table.insert(state.stack, { uiId = uiId, token = token, opts = opts, openedAt = GetGameTimer() })
    dbg('uiFocus.acquire_push', { uiId = uiId, token = token, depth = #state.stack })
  end

  applyNuiFocus(top())
  emitChanged()
  return token, nil
end

-- Release focus
-- If uiId/token match top, pop (or clear).
-- If releasing a lower stack entry, remove it without disturbing top.
function ALN.UIFocus.Release(uiId, token)
  if type(uiId) ~= 'string' or uiId == '' then return false, 'invalid_uiId' end
  if type(token) ~= 'string' or token == '' then return false, 'invalid_token' end

  local removed = false
  for i = #state.stack, 1, -1 do
    local e = state.stack[i]
    if e.uiId == uiId and e.token == token then
      table.remove(state.stack, i)
      removed = true
      dbg('uiFocus.release', { uiId = uiId, token = token, depth = #state.stack })
      break
    end
  end

  if not removed then
    return false, 'not_found'
  end

  local t = top()
  applyNuiFocus(t)
  emitChanged()
  return true, nil
end

-- Clear all focus (hard reset)
function ALN.UIFocus.Clear(reason)
  state.stack = {}
  applyNuiFocus(nil)
  emitChanged()
  dbg('uiFocus.clear', { reason = reason or 'unknown' })
end

-- Called by controls.lua when universal close is pressed
function ALN.UIFocus.RequestCloseTop()
  local t = top()
  if not t then return end

  local reg = state.registry[t.uiId] or {}

  dbg('uiFocus.close_requested', { uiId = t.uiId, token = t.token })

  -- Notify UI in the most direct way available:
  -- 1) NUI message type
  -- 2) event callback name
  if reg.nuiCloseMsgType and reg.nuiCloseMsgType ~= '' then
    SendNUIMessage({ type = reg.nuiCloseMsgType, uiId = t.uiId, token = t.token })
  end

  if reg.onCloseEvent and reg.onCloseEvent ~= '' then
    TriggerEvent(reg.onCloseEvent, t.uiId, t.token)
  end
end

-- Exports
exports('Register', function(uiId, cfg) return ALN.UIFocus.Register(uiId, cfg) end)
exports('Acquire', function(uiId, opts) return ALN.UIFocus.Acquire(uiId, opts) end)
exports('Release', function(uiId, token) return ALN.UIFocus.Release(uiId, token) end)
exports('Clear', function(reason) return ALN.UIFocus.Clear(reason) end)
exports('Get', function() return ALN.UIFocus.Get() end)
exports('IsFocused', function() return ALN.UIFocus.IsFocused() end)
exports('RequestCloseTop', function() return ALN.UIFocus.RequestCloseTop() end)
