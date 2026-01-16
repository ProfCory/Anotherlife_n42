# aln-launder (ALN3)

Dirty money laundering endpoint.
- Server authoritative conversion using aln-economy.
- Optionally requires being near a launder-tagged location.

v0:
- Simple text menu near launder points (E).
- Converts dirty -> cash or bank (config).
- Cooldown + min/max limits.

Integrations:
- Locations: tag `launder`
- Economy: Debit dirty, Credit cash/bank with ledger reasons:
  - launder.dirty_in
  - launder.clean_out
