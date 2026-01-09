ALN = ALN or {}
ALN.Inventory = ALN.Inventory or {}
ALN.Inv = ALN.Inv or {}

local function ownerKeyFromSrc(src)
  return exports['aln-economy']:GetIdentityKey(src)
end

local function dbg(ev, f)
  if Config and Config.Inventory and Config.Inventory.Debug then
    ALN.Log.Debug(ev, f or {})
  end
end

local function pocketsId()
  return 'pockets'
end

local function wearableId()
  return 'wearables'
end

-- Determine wearable extra slots based on equipped wearable item (future).
-- v0: no equipped system yet, so default only.
local function ownerKeyFromSrc(src)
  return exports['aln-economy']:GetIdentityKey(src)
end

-- Container helpers
function ALN.Inventory.GetContainer(ownerKey, containerId)
  return ALN.InvStore.GetContainer(ownerKey, containerId)
end

function ALN.Inventory.GetSlotsSnapshot(src, containerId)
  local ownerKey = ownerKeyFromSrc(src)
  return ALN.InvStore.Export(ownerKey, containerId)
end

local function findFirstFree(ownerKey, containerId, maxSlots)
  for i=1, maxSlots do
    if ALN.InvStore.GetSlot(ownerKey, containerId, i) == nil then
      return i
    end
  end
  return nil
end

local function findStackableSlot(ownerKey, containerId, maxSlots, itemKey, meta)
  for i=1, maxSlots do
    local s = ALN.InvStore.GetSlot(ownerKey, containerId, i)
    if s and s.item == itemKey then
      -- v0 meta stacking: only stack if meta.variant matches or both nil.
      local a = s.meta or {}
      local b = meta or {}
      if (a.variant == b.variant) then
        return i, s
      end
    end
  end
  return nil
end

-- Add item into container with stacking rules.
-- Returns: ok, {added=..., slotsChanged={...}} or reason
function ALN.Inventory.AddToContainer(src, containerId, itemKey, count, meta, maxSlots)
  local ownerKey = ownerKeyFromSrc(src)
  local ok, defOrReason = ALN.Inv.ValidateAdd(itemKey, count, meta)
  if not ok then return false, defOrReason end
  local def = defOrReason

  maxSlots = maxSlots or ALN.Inventory.GetPocketSlots(src)
  local maxStack = ALN.Inv.GetMaxStack(def)

  local remaining = count
  local changed = {}

  -- stack first if allowed
  if ALN.Inv.CanStack(def) then
    while remaining > 0 do
      local slot, cur = findStackableSlot(ownerKey, containerId, maxSlots, itemKey, meta)
      if not slot then break end
      if cur.count < maxStack then
        local add = math.min(remaining, (maxStack - cur.count))
        cur.count = cur.count + add
        ALN.InvStore.SetSlot(ownerKey, containerId, slot, cur)
        changed[#changed+1] = { slot = slot, value = cur }
        remaining = remaining - add
      else
        break
      end
    end
  end

  -- then place into free slots
  while remaining > 0 do
    local free = findFirstFree(ownerKey, containerId, maxSlots)
    if not free then
      return false, 'no_space'
    end

    local put = math.min(remaining, maxStack)
    local entry = { item = itemKey, count = put, meta = meta }
    ALN.InvStore.SetSlot(ownerKey, containerId, free, entry)
    changed[#changed+1] = { slot = free, value = entry }
    remaining = remaining - put
  end

  dbg('inv.add', { ownerKey=ownerKey, containerId=containerId, item=itemKey, count=count })
  return true, { added = count, slotsChanged = changed }
end

function ALN.Inventory.RemoveFromContainer(src, containerId, itemKey, count, meta, maxSlots)
  local ownerKey = ownerKeyFromSrc(src)
  count = math.floor(tonumber(count) or 0)
  if count <= 0 then return false, 'bad_count' end

  maxSlots = maxSlots or ALN.Inventory.GetPocketSlots(src)
  local remaining = count
  local changed = {}

  for i=1, maxSlots do
    local s = ALN.InvStore.GetSlot(ownerKey, containerId, i)
    if s and s.item == itemKey then
      local a = s.meta or {}
      local b = meta or {}
      if (a.variant == b.variant) then
        local take = math.min(remaining, s.count)
        s.count = s.count - take
        remaining = remaining - take

        if s.count <= 0 then
          ALN.InvStore.SetSlot(ownerKey, containerId, i, nil)
          changed[#changed+1] = { slot = i, value = nil }
        else
          ALN.InvStore.SetSlot(ownerKey, containerId, i, s)
          changed[#changed+1] = { slot = i, value = s }
        end

        if remaining <= 0 then break end
      end
    end
  end

  if remaining > 0 then
    return false, 'insufficient_items'
  end

  dbg('inv.remove', { ownerKey=ownerKey, containerId=containerId, item=itemKey, count=count })
  return true, { removed = count, slotsChanged = changed }
end

-- Convenience: pockets
function ALN.Inventory.AddToPockets(src, itemKey, count, meta)
  return ALN.Inventory.AddToContainer(src, pocketsId(), itemKey, count, meta, ALN.Inventory.GetPocketSlots(src))
end

function ALN.Inventory.RemoveFromPockets(src, itemKey, count, meta)
  return ALN.Inventory.RemoveFromContainer(src, pocketsId(), itemKey, count, meta, ALN.Inventory.GetPocketSlots(src))
end

exports('AddToPockets', function(src, itemKey, count, meta) return ALN.Inventory.AddToPockets(src, itemKey, count, meta) end)
exports('RemoveFromPockets', function(src, itemKey, count, meta) return ALN.Inventory.RemoveFromPockets(src, itemKey, count, meta) end)
exports('GetSnapshot', function(src, containerId) return ALN.Inventory.GetSlotsSnapshot(src, containerId) end)
