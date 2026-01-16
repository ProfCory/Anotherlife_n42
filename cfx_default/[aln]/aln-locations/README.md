# aln-locations (ALN3)

Location registry with stable IDs and optional client blip spawner.

## Adding locations
- Add entries in the correct module file under `shared/modules/`.
- Never rename a location ID once referenced by persistence or other registries.

## Clustering
Use `clusterKey = "payphone_sandy"` (etc.) to ensure only one blip appears for that group.

## Reload blips
Use command: `/aln_loc_blips_reload`
