# BG3 Dice — Exports & Events

> Minimal reference for integrating the BG3-inspired D20 rolls into any script (ESX/QBCore/Qbox/custom).

## Exports (Client)

### 1) `Roll(opts)`
Fire-and-forget visual roll (non-blocking).

```lua
exports['bg3_dice']:Roll({
  modifier = 2,          -- optional (number)
  dc = 15,               -- optional (number) - if omitted, no success/fail state
  mode = 'adv',          -- 'normal' | 'adv' | 'dis' (optional; default 'normal')
  meta = { system='lockpick', door='Fleeca_1' },  -- optional table echoed in events

  -- optional visuals (fallback to Config.*):
  skin = 'gold',         -- 'obsidian' | 'gold' | 'arcane' | 'marble'
  edgeColor = '#d4af37', -- hex color
  numerals = 'arabic'    -- 'arabic' | 'roman'
})
```

### 2) `RollCheck(opts) → success, total, raw`
Blocking roll that **returns** the outcome.

```lua
local success, total, raw = exports['bg3_dice']:RollCheck({
  modifier = 3,
  dc = 18,
  mode = 'normal',
  meta = { system='hack', step=2 },

  -- optional visuals:
  skin='marble', edgeColor='#9ad1ff', numerals='roman'
})
-- success: boolean (BG3 rule applied: if dc > 20, only nat20 succeeds)
-- total  : number  (raw + modifier)
-- raw    : number  (1..20)
```

### 3) `RollQuick()`
Zero-argument **single d20 with defaults** (great for ox_inventory items).

```lua
exports['bg3_dice']:RollQuick()
```

### 4) `RollQuickResult() → success, total, raw`
Blocking version of the quick roll.

```lua
local success, total, raw = exports['bg3_dice']:RollQuickResult()
```

---

## Events API

You can listen on **client** or **server**. The `meta` table you pass in exports is echoed back.

### Client Events

```lua
-- Fired when a roll starts (right before the animation begins)
AddEventHandler('bg3_dice:onRollStart', function(ctx)
  -- ctx = { dc, modifier, mode, meta }
end)

-- Fired when the roll finishes (after the animation settles)
AddEventHandler('bg3_dice:onRollEnd', function(res)
  -- res = { success, total, raw, dc, modifier, mode, meta }
end)

-- Special cases
AddEventHandler('bg3_dice:onNat20', function(ctx) end) -- { dc, modifier, mode, meta }
AddEventHandler('bg3_dice:onNat1',  function(ctx) end) -- { dc, modifier, mode, meta }
```

### Server Events

```lua
-- Emitted when a client starts a roll
AddEventHandler('bg3_dice:onRollStart', function(src, name, ctx)
  -- src: player id, name: GetPlayerName(src)
  -- ctx = { r1, r2, raw, modifier, dc, mode, meta }  -- r1/r2 provided for adv/dis
end)

-- Emitted when a client ends a roll (resolved on client, then reported)
AddEventHandler('bg3_dice:onRollEnd', function(src, name, res)
  -- res = { success, total, raw, dc, modifier, mode, meta }
end)

AddEventHandler('bg3_dice:onNat20', function(src, name, ctx) end) -- { dc, modifier, mode, meta }
AddEventHandler('bg3_dice:onNat1',  function(src, name, ctx) end) -- { dc, modifier, mode, meta }
```

> **BG3 rule:** when `dc > 20`, success is **only** if `raw == 20` (natural 20).  
> This rule is applied in `RollCheck()`’s return and the `onRollEnd` payload’s `success`.

---

## Common Integration Patterns

### Lockpick check (blocking)

```lua
local ok, total, raw = exports['bg3_dice']:RollCheck({
  modifier = 2,
  dc = 15,
  mode = 'adv',
  meta = { system='lockpick', door='Fleeca_1' }
})

if ok then
  -- open lock
else
  -- fail logic (e.g., durability loss, alarm chance)
end
```

### Heist step with events (server-side listener)

```lua
AddEventHandler('bg3_dice:onRollEnd', function(src, name, res)
  if res.meta and res.meta.system == 'heist' and res.meta.step == 'vault' then
    if res.success then
      -- advance heist stage
    else
      -- trigger guards or timer penalty
    end
  end
end)
```

### ox_inventory item (client, zero-arg)

```lua
-- items.lua
['d20_dice'] = {
  label = 'D20 Dice',
  weight = 0, stack = true, close = true, consume = 0,
  description = 'Click to roll a D20.',
  client = { export = 'bg3_dice.RollQuick' }
}
```
