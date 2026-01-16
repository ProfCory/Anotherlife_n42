ALN = ALN or {}
ALN.Persistent = ALN.Persistent or {}
local Repo = nil

local function dbg(ev, f) ALN.Persistent._dbg(ev, f) end

-- Public exports

-- Active identity key that other authoritative systems can use
-- We return "char:<id>" which is stable across the server and works as a key.
function ALN.Persistent.GetActiveIdentityKey(src)
  local ownerKey = ALN.Persistent.OwnerKeyFromSrc(src)
  local p = Repo.GetPlayer(ownerKey)
  if p and p.active_char_id then
    return ('char:%d'):format(tonumber(p.active_char_id))
  end
  return ownerKey -- fallback
end

function ALN.Persistent.GetActiveCharacterId(src)
  local ownerKey = ALN.Persistent.OwnerKeyFromSrc(src)
  local p = Repo.GetPlayer(ownerKey)
  return p and tonumber(p.active_char_id) or nil
end

function ALN.Persistent.SetActiveSlot(src, slot)
  slot = math.floor(tonumber(slot) or 0)
  if slot < 1 or slot > (Config.Persistent.Slots or 3) then
    return false, 'bad_slot'
  end

  local ownerKey = ALN.Persistent.OwnerKeyFromSrc(src)
  local p = Repo.GetPlayer(ownerKey)

  local c = Repo.GetCharacterBySlot(ownerKey, slot)
  local charId = c and tonumber(c.id) or nil
  if not charId then
    charId = Repo.CreateCharacter(ownerKey, slot)
    c = Repo.GetCharacterById(charId)
  end

  Repo.SetActive(ownerKey, slot, charId)
  Repo.TouchLogin(charId)

  TriggerEvent(ALN.Persistent.Events.ActiveChanged, src, ownerKey, charId, slot)
  TriggerEvent(ALN.Persistent.Events.Loaded, src, charId, c)

  dbg('pdata.active_set', { ownerKey=ownerKey, slot=slot, charId=charId })
  return true, { slot = slot, charId = charId, data = c }
end

function ALN.Persistent.GetCharacterById(charId)
  return Repo.GetCharacterById(tonumber(charId))
end

function ALN.Persistent.SetLastPosition(src, coords, heading)
  local charId = ALN.Persistent.GetActiveCharacterId(src)
  if not charId then return false, 'no_active_char' end
  Repo.SetLastPos(charId, coords, heading or 0.0)
  return true
end

-- Money sync helpers (used later when economy moves to DB-backed)
function ALN.Persistent.GetMoney(charId)
  local c = Repo.GetCharacterById(tonumber(charId))
  if not c then return nil end
  return { cash = tonumber(c.money_cash) or 0, bank = tonumber(c.money_bank) or 0, dirty = tonumber(c.money_dirty) or 0 }
end

function ALN.Persistent.SetMoney(charId, cash, bank, dirty)
  Repo.SetMoney(tonumber(charId), math.floor(cash or 0), math.floor(bank or 0), math.floor(dirty or 0))
  TriggerEvent(ALN.Persistent.Events.Saved, tonumber(charId))
  return true
end

exports('GetActiveIdentityKey', function(src) return ALN.Persistent.GetActiveIdentityKey(src) end)
exports('GetActiveCharacterId', function(src) return ALN.Persistent.GetActiveCharacterId(src) end)
exports('SetActiveSlot', function(src, slot) return ALN.Persistent.SetActiveSlot(src, slot) end)
exports('GetCharacterById', function(charId) return ALN.Persistent.GetCharacterById(charId) end)
exports('SetLastPosition', function(src, coords, heading) return ALN.Persistent.SetLastPosition(src, coords, heading) end)
exports('GetMoney', function(charId) return ALN.Persistent.GetMoney(charId) end)
exports('SetMoney', function(charId, cash, bank, dirty) return ALN.Persistent.SetMoney(charId, cash, bank, dirty) end)

-- Lifecycle
AddEventHandler('onResourceStart', function(resName)
  if resName ~= GetCurrentResourceName() then return end
  exports['aln-core']:OnReady(function()
    ALN.Persistent.RunMigrations()
    Repo = ALN.Persistent.Repo
    ALN.Log.Info('pdata.start', { slots = Config.Persistent.Slots or 3 })
  end)
end)

AddEventHandler('playerDropped', function()
  local src = source
  if not Repo then return end
  local charId = ALN.Persistent.GetActiveCharacterId(src)
  if charId then
    Repo.TouchLogout(charId)
  end
end)

-- Console test helpers
RegisterCommand('aln_char_setslot', function(src, args)
  if src ~= 0 then return end
  local playerSrc = tonumber(args[1] or 0) or 0
  local slot = tonumber(args[2] or 1) or 1
  if playerSrc <= 0 then print('usage: aln_char_setslot <src> <slot>'); return end
  local ok, res = exports['aln-persistent-data']:SetActiveSlot(playerSrc, slot)
  print('[ALN3] setslot => ok=' .. tostring(ok) .. ' res=' .. (type(res)=='table' and json.encode(res) or tostring(res)))
end, true)

RegisterCommand('aln_char_get', function(src, args)
  if src ~= 0 then return end
  local playerSrc = tonumber(args[1] or 0) or 0
  if playerSrc <= 0 then print('usage: aln_char_get <src>'); return end
  local charId = exports['aln-persistent-data']:GetActiveCharacterId(playerSrc)
  print('[ALN3] active charId=' .. tostring(charId))
  if charId then
    print(json.encode(exports['aln-persistent-data']:GetCharacterById(charId)))
  end
end, true)
