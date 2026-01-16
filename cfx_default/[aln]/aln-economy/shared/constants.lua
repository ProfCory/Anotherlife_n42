ALN = ALN or {}
ALN.Economy = ALN.Economy or {}

ALN.Economy.Accounts = {
  CASH  = 'cash',
  BANK  = 'bank',
  DIRTY = 'dirty',
}

ALN.Economy.Events = {
  Changed = 'aln:economy:changed', -- server event (src, account, newBalance, delta, reason, meta)
  Ledger  = 'aln:economy:ledger',  -- server event (entry)
}
