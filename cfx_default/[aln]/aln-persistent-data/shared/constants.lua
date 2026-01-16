ALN = ALN or {}
ALN.Persistent = ALN.Persistent or {}

ALN.Persistent.Events = {
  ActiveChanged = 'aln:pdata:activeChanged',   -- (src, ownerKey, charId, slot)
  Loaded        = 'aln:pdata:loaded',          -- (src, charId, data)
  Saved         = 'aln:pdata:saved',           -- (charId)
}
