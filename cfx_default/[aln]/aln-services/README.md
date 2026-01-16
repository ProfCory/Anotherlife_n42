# aln-services (ALN3)

Callable service simulations:
- police / ems / fire: spawns a unit and drives to player
- taxi: spawns taxi, drives to player, then to waypoint, charges fare

Server-authoritative:
- cooldowns + enable toggles validated server-side
- money debits done server-side via aln-economy

Notes:
- Ambient dispatch should be disabled by aln-world-population.
- This is a v0 simulation layer; later we can add:
  - wanted-star hooks
  - response tiers/accuracy
  - station-based spawn (use station coords as origin)
  - UI integration via phone/radial
