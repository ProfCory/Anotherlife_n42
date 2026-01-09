# aln-core (ALN3)

Core spine resource.

## Provides
- Server: readiness gate + structured logging + stable player key resolution.
- Client: readiness listener + log helpers.

## Exports (server)
- `exports['aln-core']:IsReady() -> bool`
- `exports['aln-core']:OnReady(function)`
- `exports['aln-core']:GetPlayerKey(src) -> string|nil`
- `exports['aln-core']:GetIdentifiers(src) -> table`

## Exports (client)
- `exports['aln-core']:IsReady() -> bool`
- `exports['aln-core']:OnReady(function)`

## Events
- `aln:core:ready` (server -> client broadcast via TriggerEvent on server; other resources can also listen server-side)

## Notes
Core intentionally does not contain gameplay logic. Other resources should depend on core readiness before initializing.
