# aln-loot (ALN3)

Loot pools registry + deterministic server-side roller.

## Why deterministic?
If you pass stable ctx (playerKey + entityNetId + poolId), the same loot roll can be reproduced and audited.

## Exports
- `exports['aln-loot']:GetPool(poolId)`
- `exports['aln-loot']:GetAllPools()`
- `exports['aln-loot']:Roll(poolId, ctx) -> results, reason`

## ctx fields
- src (optional)
- playerKey (optional)
- entityNetId (optional)
- locationId (optional)
- timeBucket (optional)
- extraSeed (optional)

## Notes
This resource does not spawn pickups yet.
Other scripts should roll loot and then call inventory/economy endpoints to apply results.
