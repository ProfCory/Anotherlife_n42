# aln-persistent-data (ALN3)

Persistence spine for ALN3.
- 3 character slots per player
- active slot tracking
- character lifecycle (login/logout/session_id)
- last known position
- money fields stored on character (future economy backing)

## Exports
- GetActiveIdentityKey(src) -> "char:<id>" (preferred key for other authoritative systems)
- GetActiveCharacterId(src) -> number|nil
- SetActiveSlot(src, slot) -> ok, {slot,charId,data}
- GetCharacterById(charId) -> row
- SetLastPosition(src, coords, heading)
- GetMoney(charId) / SetMoney(charId, cash, bank, dirty)

## Notes
v0 stores appearance/clothing/outfits/licenses/housing as JSON blobs.
Later resources can add normalized tables additively.
