ALN = ALN or {}
ALN.Persistent = ALN.Persistent or {}

local dbg = ALN.Persistent._dbg

local function upsertPlayer(ownerKey)
  exports['aln-db']:Insert([[
    INSERT INTO aln3_players (owner_key, active_slot, active_char_id, updated_at)
    VALUES (?, 1, NULL, ?)
    ON DUPLICATE KEY UPDATE updated_at=VALUES(updated_at)
  ]], { ownerKey, ALN.Persistent.NowIso() })
end

local function getPlayer(ownerKey)
  upsertPlayer(ownerKey)
  return exports['aln-db']:Single('SELECT * FROM aln3_players WHERE owner_key=?', { ownerKey })
end

local function setActive(ownerKey, slot, charId)
  exports['aln-db']:Update([[
    UPDATE aln3_players
    SET active_slot=?, active_char_id=?, updated_at=?
    WHERE owner_key=?
  ]], { slot, charId, ALN.Persistent.NowIso(), ownerKey })
end

local function getCharacterBySlot(ownerKey, slot)
  return exports['aln-db']:Single(
    'SELECT * FROM aln3_characters WHERE owner_key=? AND slot=?',
    { ownerKey, slot }
  )
end

local function getCharacterById(charId)
  return exports['aln-db']:Single('SELECT * FROM aln3_characters WHERE id=?', { charId })
end

local function createCharacter(ownerKey, slot)
  local d = Config.Persistent.Defaults or {}
  local pos = d.position or { x=0,y=0,z=0,h=0 }
  local money = d.money or { cash=0, bank=0, dirty=0 }
  local model = d.model or 'mp_m_freemode_01'
  local now = ALN.Persistent.NowIso()
  local sessionId = ('%s|%s|%d'):format(ownerKey, now, math.random(1000, 9999))

  local id = exports['aln-db']:Insert([[
    INSERT INTO aln3_characters (
      owner_key, slot, name, model,
      appearance_json, clothing_json, outfits_json, licenses_json, housing_json,
      fav_vehicle_plate, fav_outfit_key,
      money_cash, money_bank, money_dirty,
      last_x, last_y, last_z, last_h,
      session_id, last_login_at, last_logout_at,
      created_at, updated_at
    ) VALUES (
      ?, ?, NULL, ?,
      NULL, NULL, NULL, NULL, NULL,
      NULL, NULL,
      ?, ?, ?,
      ?, ?, ?, ?,
      ?, ?, NULL,
      ?, ?
    )
  ]], {
    ownerKey, slot, model,
    math.floor(tonumber(money.cash) or 0),
    math.floor(tonumber(money.bank) or 0),
    math.floor(tonumber(money.dirty) or 0),
    tonumber(pos.x) or 0, tonumber(pos.y) or 0, tonumber(pos.z) or 0, tonumber(pos.h) or 0,
    sessionId, now,
    now, now
  })

  return id
end

local function touchLogin(charId)
  local now = ALN.Persistent.NowIso()
  local sessionId = ('char:%d|%s|%d'):format(charId, now, math.random(1000, 9999))
  exports['aln-db']:Update([[
    UPDATE aln3_characters
    SET session_id=?, last_login_at=?, updated_at=?
    WHERE id=?
  ]], { sessionId, now, now, charId })
end

local function touchLogout(charId)
  local now = ALN.Persistent.NowIso()
  exports['aln-db']:Update([[
    UPDATE aln3_characters
    SET last_logout_at=?, updated_at=?
    WHERE id=?
  ]], { now, now, charId })
end

local function setLastPos(charId, coords, heading)
  local now = ALN.Persistent.NowIso()
  exports['aln-db']:Update([[
    UPDATE aln3_characters
    SET last_x=?, last_y=?, last_z=?, last_h=?, updated_at=?
    WHERE id=?
  ]], { coords.x, coords.y, coords.z, heading or 0.0, now, charId })
end

local function setMoney(charId, cash, bank, dirty)
  local now = ALN.Persistent.NowIso()
  exports['aln-db']:Update([[
    UPDATE aln3_characters
    SET money_cash=?, money_bank=?, money_dirty=?, updated_at=?
    WHERE id=?
  ]], { cash, bank, dirty, now, charId })
end

ALN.Persistent.Repo = {
  GetPlayer = getPlayer,
  SetActive = setActive,
  GetCharacterBySlot = getCharacterBySlot,
  GetCharacterById = getCharacterById,
  CreateCharacter = createCharacter,
  TouchLogin = touchLogin,
  TouchLogout = touchLogout,
  SetLastPos = setLastPos,
  SetMoney = setMoney,
}
