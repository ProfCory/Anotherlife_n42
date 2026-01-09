# aln-ui-focus (ALN3)

Single owner of UI focus + input arbitration.

## Core behavior
- Only one UI may hold focus at a time by default.
- Optional stack (modal) is supported only when explicitly enabled for both UIs.
- Universal close: ESC / Backspace triggers a close request to the top UI.
- Token-based acquire/release prevents stale releases.

## Exports (client)
- `Register(uiId, cfg)`
- `Acquire(uiId, opts) -> token|nil, reason|nil`
- `Release(uiId, token) -> ok, reason`
- `Clear(reason)`
- `Get() -> {uiId, token, opts} | nil`
- `IsFocused() -> bool`
- `RequestCloseTop()`

## Listening
- Client event: `aln:uiFocus:changed (uiId, token, opts)`

## Quick test
- `/aln_focus_test` opens debug UI
- Press ESC/Backspace to request close
- `/aln_focus_clear` hard reset focus
