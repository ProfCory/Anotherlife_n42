ALN = ALN or {}
ALN.InvStoreDB = ALN.InvStoreDB or {}

-- Placeholder. When UseDB=true we will implement:
-- LoadContainer(ownerKey, containerId) -> slots
-- SaveSlot(ownerKey, containerId, slot, itemKey, count, meta)
-- DeleteSlot(...)
-- For now, keep it simple and memory-based.

function ALN.InvStoreDB.NotImplemented()
  return false, 'db_store_not_implemented'
end
