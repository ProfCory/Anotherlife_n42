-- Debug NUI handlers for quick testing (remove/ignore for real UIs)
RegisterNUICallback('aln_ui_focus_close', function(data, cb)
  -- This callback can be used by the debug page to close itself.
  -- Real UIs should call exports['aln-ui-focus']:Release(uiId, token) once they actually close.
  cb({ ok = true })
end)
