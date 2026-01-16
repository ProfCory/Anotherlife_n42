# aln-carjack (ALN3)

Vehicle lock + entry + hotwire loop driven by `aln-minigame`.

- Parked vehicles treated as locked
- Entry attempts use DC actions:
  - vehicle.entry.smash
  - vehicle.entry.lockpick
- Stolen vehicles require hotwire (vehicle.hotwire) to enable engine
- nat1 adds wanted level via aln-minigame client hook
