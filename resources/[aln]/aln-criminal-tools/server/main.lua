ALN = ALN or {}
ALN.CriminalTools = ALN.CriminalTools or {}

local function snapshotPockets(src)
  return exports['aln-inventory']:GetSnapshot(src, 'pockets') or {}
end

local function countItemInPockets(src, itemKey)
  local snap = snapshotPockets(src)
  local total = 0
  for _, slot in pairs(snap) do
    if slot and slot.item == itemKey then
      total = total + (tonumber(slot.count) or 0)
    end
  end
  return total
end

local function bestTierForItems(src, basicItem, advItem)
  local advCount = advItem and countItemInPockets(src, advItem) or 0
  if advCount > 0 then return 'adv', advItem end
  local basicCount = basicItem and countItemInPockets(src, basicItem) or 0
  if basicCount > 0 then return 'basic', basicItem end
  return 'none', nil
end

-- Resolve “best applicable tool tier” for an action
-- actionId convention: vehicle.entry.lockpick / vehicle.hotwire / hack.panel etc.
function ALN.CriminalTools.GetBestToolForAction(src, actionId)
  actionId = tostring(actionId or '')

  if actionId:find('lockpick') then
    return bestTierForItems(src, Config.CriminalTools.Tools.lockpick_basic.item, Config.CriminalTools.Tools.lockpick_adv.item)
  end

  if actionId:find('hotwire') then
    return bestTierForItems(src, Config.CriminalTools.Tools.hotwire_basic.item, Config.CriminalTools.Tools.hotwire_adv.item)
  end

  if actionId:find('hack') then
    return bestTierForItems(src, Config.CriminalTools.Tools.hacker_basic.item, Config.CriminalTools.Tools.hacker_adv.item)
  end

  return 'none', nil
end

-- Consume one unit of a tool item (on break)
function ALN.CriminalTools.ConsumeToolItem(src, itemKey)
  if not itemKey or itemKey == '' then return false end
  return exports['aln-inventory']:RemoveFromPockets(src, itemKey, 1, nil)
end

exports('GetBestToolForAction', function(src, actionId) return ALN.CriminalTools.GetBestToolForAction(src, actionId) end)
exports('ConsumeToolItem', function(src, itemKey) return ALN.CriminalTools.ConsumeToolItem(src, itemKey) end)
