ALN = ALN or {}

AddEventHandler('onClientResourceStart', function(resName)
  if resName ~= GetCurrentResourceName() then return end

  -- Register a debug UI so you can test focus right away.
  exports['aln-ui-focus']:Register('debug.ui', {
    allowOverlap = false,
    allowStack = false,
    keepInput = true,
    nuiCloseMsgType = 'aln_ui_close',
    onCloseEvent = 'aln:uiFocus:debugClose',
  })

  RegisterNetEvent('aln:uiFocus:debugClose', function(uiId, token)
    -- For debug UI, we just release immediately.
    exports['aln-ui-focus']:Release(uiId, token)
  end)

  -- Convenience commands to test focus:
  RegisterCommand('aln_focus_test', function()
    local token, reason = exports['aln-ui-focus']:Acquire('debug.ui', { cursor = true, keepInput = true })
    if not token then
      ALN.Log.Warn('uiFocus.test_failed', { reason = reason })
      return
    end
    ALN.Log.Info('uiFocus.test_open', { token = token })
    SendNUIMessage({ type = 'aln_ui_open', uiId = 'debug.ui', token = token })
  end, false)

  RegisterCommand('aln_focus_clear', function()
    exports['aln-ui-focus']:Clear('manual_clear')
  end, false)

  ALN.Log.Info('uiFocus.client_start', {})
end)

-- Broadcast changes locally (other resources can listen)
AddEventHandler(ALN.UIFocus.Events.Changed, function(uiId, token, opts)
  ALN.Log.Debug('uiFocus.changed', { uiId = uiId, token = token, hasFocus = uiId ~= nil })
end)
