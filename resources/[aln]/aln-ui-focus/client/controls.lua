ALN = ALN or {}
ALN.UIFocus = ALN.UIFocus or {}

local disabling = false

-- Conservative disable list while any ALN UI has focus
-- (Keep this minimal; expand only when you observe conflicts.)
local DISABLE = {
  -- Attack/aim
  24, 25, 257, 263, 140, 141, 142,
  -- Weapon wheel / select
  37, 157, 158, 159, 160, 161, 162, 163, 164, 165,
  -- Melee / reload
  45, 80, 143,
  -- Enter / exit vehicle
  23, 75,
  -- Phone
  27,
  -- Pause menu (we still capture close via 200)
  199,
}

CreateThread(function()
  while true do
    local focused = exports['aln-ui-focus']:IsFocused()
    if focused then
      -- universal close keys
      for _, c in ipairs((Config and Config.UIFocus and Config.UIFocus.CloseControls) or {200,177}) do
        if IsControlJustReleased(0, c) then
          exports['aln-ui-focus']:RequestCloseTop()
        end
      end

      -- disable controls (default behavior)
      if (Config and Config.UIFocus and Config.UIFocus.DefaultDisableControls) then
        DisableAllControlActions(0)
        -- Re-enable look/mouse so NUI can feel normal
        EnableControlAction(0, 1, true)   -- LookLeftRight
        EnableControlAction(0, 2, true)   -- LookUpDown
        EnableControlAction(0, 106, true) -- VehicleMouseControlOverride

        -- Re-enable push-to-talk if you use it (optional)
        EnableControlAction(0, 249, true)

        -- Some controls we *still* want blocked even if DisableAll isn't used
        for _, ctrl in ipairs(DISABLE) do
          DisableControlAction(0, ctrl, true)
        end
      else
        for _, ctrl in ipairs(DISABLE) do
          DisableControlAction(0, ctrl, true)
        end
      end

      Wait(0)
    else
      Wait(150)
    end
  end
end)
