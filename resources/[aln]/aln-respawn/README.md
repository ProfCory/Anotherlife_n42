# aln-respawn (ALN3)

Solo death/respawn system:
- detects death client-side
- server arms a respawn timer and selects a registry-driven endpoint
- client performs resurrect at endpoint after timer
- persists last position via aln-persistent-data

v0 rules:
- wanted >= 1 => police station
- else => hospital/clinic

Later:
- cause-of-death routing (suicide -> fire, etc.)
- optional menu to pick from nearby endpoints
- inventory/needs restoration hooks
