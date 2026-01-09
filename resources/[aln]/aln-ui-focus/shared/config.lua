Config = Config or {}

Config.UIFocus = {
  Debug = true,

  -- Which controls to treat as "universal close" when UI is focused
  CloseControls = {
    200, -- ESC / Pause menu back
    177, -- BACKSPACE
  },

  -- While focused, we disable a bunch of controls to prevent stuck states.
  -- We still allow mouse look if the UI wants it (configurable per UI).
  DefaultDisableControls = true,

  -- Default behavior: no overlap. A new UI request will be denied unless:
  -- - current UI allows it (allowOverlap) OR
  -- - request opts.force = true (not recommended; admin/dev only)
  DefaultAllowOverlap = false,

  -- Optional: allow stacking (modal stack). Only if both UIs explicitly allow stacking.
  DefaultAllowStack = false,
}
