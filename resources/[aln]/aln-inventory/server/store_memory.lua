ALN = ALN or {}
ALN.InvStore = ALN.InvStore or {}

-- owner_key -> container_id -> slots table (1..N) where slot can be nil or {item,count,meta}
local store = {}

local function getOwner(ownerKey)
  store[ownerKey] = store[ownerKey] or {}
  return store[ownerKey]
end

function ALN.InvStore.GetContainer(ownerKey, containerId)
  local o = getOwner(ownerKey)
  o[containerId] = o[containerId] or {}
  return o[containerId]
end

function ALN.InvStore.SetSlot(ownerKey, containerId, slot, value)
  local c = ALN.InvStore.GetContainer(ownerKey, containerId)
  c[slot] = value
end

function ALN.InvStore.GetSlot(ownerKey, containerId, slot)
  local c = ALN.InvStore.GetContainer(ownerKey, containerId)
  return c[slot]
end

function ALN.InvStore.ClearContainer(ownerKey, containerId)
  local o = getOwner(ownerKey)
  o[containerId] = {}
end

function ALN.InvStore.Export(ownerKey, containerId)
  local c = ALN.InvStore.GetContainer(ownerKey, containerId)
  local out = {}
  for k,v in pairs(c) do out[k]=v end
  return out
end
