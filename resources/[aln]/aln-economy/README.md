# aln-economy (ALN3)

Server-authoritative money primitives and a simple ledger.

## Accounts
- cash
- bank
- dirty

## Exports (server)
- GetIdentityKey(src) -> string
- GetBalance(identityKey, account) -> int
- CanAfford(identityKey, account, amount) -> bool
- Credit(src, account, amount, reason, meta)
- Debit(src, account, amount, reason, meta)
- Transfer(src, fromAccount, toAccount, amount, reason, meta)
- ApplyDelta(src, account, delta, reason, meta)
- LedgerRecent(n)

## Notes
Currently runs in InMemoryMode until aln-persistent-data exists.
The API stays stable when we move balances to DB-backed storage.
