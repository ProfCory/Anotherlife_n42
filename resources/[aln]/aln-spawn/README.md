# aln-spawn (ALN3)

Spawn + onboarding owner.

v0:
- ensures active slot (defaults to slot 1)
- if onboarding not done:
  - pick base model (male/female/street)
  - pick starter vehicle (faggio/voodoo/rebel)
  - server stores: onboarding_done, base_model, starter_vehicle_model/plate
  - sets last position to Sandy clinic start
- spawns at last known position otherwise
- spawns starter vehicle (client executes; server chooses model/plate)

Notes:
- This resource disables spawnmanager autos-spawn so ALN can control deterministically.
- Vehicle ownership/persistence will be tightened later under aln-vehicles + server-side authority.
