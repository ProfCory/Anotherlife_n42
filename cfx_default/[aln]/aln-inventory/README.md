# aln-inventory (ALN3)

Server-authoritative inventory primitives.
- pockets (5 slots)
- stashes (vehicle/home/motel) helpers
- stacking rules
- server events for UI integration

## Exports
- AddToPockets(src, itemKey, count, meta)
- RemoveFromPockets(src, itemKey, count, meta)
- GetSnapshot(src, containerId)

## Notes
Weapons/ammo stay in weapon wheel domain and are rejected by inventory.
DB persistence is staged: flip Config.Inventory.UseDB when DB store is implemented.
