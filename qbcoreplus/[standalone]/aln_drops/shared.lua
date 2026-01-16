ALN_DROPS = ALN_DROPS or {}

ALN_DROPS.Events = {
  ReportNpcDeath = 'aln_drops:server:ReportNpcDeath',
  CreateLootBag  = 'aln_drops:client:CreateLootBag',
  LootBagTakeAll = 'aln_drops:server:LootBagTakeAll',
  CleanupCorpse  = 'aln_drops:client:CleanupCorpse',
  ReviveNpc      = 'aln_drops:client:ReviveNpc',
}

function ALN_DROPS.Clamp(n, mn, mx)
  if n < mn then return mn end
  if n > mx then return mx end
  return n
end
