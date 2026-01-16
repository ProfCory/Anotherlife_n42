-- aln-ui-focus/server/main.lua
-- UI focus authority (server-side)

local Log

CreateThread(function()
  exports['aln-core']:OnReady(function()
    Log = exports['aln-core']:Log()

    Log.Info('uiFocus.start', {
      resource = GetCurrentResourceName()
    })

    -- Future server-side UI arbitration hooks go here
    -- This resource intentionally stays minimal
  end)
end)
