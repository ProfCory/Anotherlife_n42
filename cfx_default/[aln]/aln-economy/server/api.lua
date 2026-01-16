-- aln-economy/server/api.lua
-- Server-authoritative economy API (SQL-backed ledger, v0)

local Log
local DB

local Economy = {}

-- ===== Internal helpers =====

local function assertIdentity(identityKey)
  if type(identityKey) ~= 'string' or identityKey == '' then
    return false, 'invalid_identity'
  end
  return true
end

local function assertAccount(account)
  if account ~= 'cash' and account ~= 'bank' then
    return false, 'invalid_account'
  end
  return true
end

-- ===== SQL helpers =====

local function ensureAccount(identityKey)
  DB.Execute([[
    INSERT IGNORE INTO accounts (identity_key, cash, bank)
    VALUES (?, 0, 0)
  ]], { identityKey })
end

-- ===== Public API =====

function Economy.GetBalance(identityKey, account)
  local ok, err = assertIdentity(identityKey)
  if not ok then return nil, err end

  local row = DB.FetchOne(
    'SELECT cash, bank FROM accounts WHERE identity_key = ?',
    { identityKey }
  )

  if not row then
    ensureAccount(identityKey)
    return 0
  end

  return tonumber(row[account] or 0)
end

function Economy.Add(identityKey, account, amount, reason)
  local ok, err = assertIdentity(identityKey)
  if not ok then return false, err end

  local ok2, err2 = assertAccount(account)
  if not ok2 then return false, err2 end

  amount = tonumber(amount)
  if not amount or amount <= 0 then
    return false, 'invalid_amount'
  end

  ensureAccount(identityKey)

  DB.Execute([[
    UPDATE accounts
    SET ]] .. account .. [[ = ]] .. account .. [[ + ?, updated_at = CURRENT_TIMESTAMP
    WHERE identity_key = ?
  ]], { amount, identityKey })

  Log.Info('economy.add', {
    identity = identityKey,
    account = account,
    amount = amount,
    reason = reason
  })

  return true
end

function Economy.Remove(identityKey, account, amount, reason)
  local ok, err = assertIdentity(identityKey)
  if not ok then return false, err end

  local ok2, err2 = assertAccount(account)
  if not ok2 then return false, err2 end

  amount = tonumber(amount)
  if not amount or amount <= 0 then
    return false, 'invalid_amount'
  end

  ensureAccount(identityKey)

  local bal = Economy.GetBalance(identityKey, account)
  if bal < amount then
    return false, 'insufficient_funds'
  end

  DB.Execute([[
    UPDATE accounts
    SET ]] .. account .. [[ = ]] .. account .. [[ - ?, updated_at = CURRENT_TIMESTAMP
    WHERE identity_key = ?
  ]], { amount, identityKey })

  Log.Info('economy.remove', {
    identity = identityKey,
    account = account,
    amount = amount,
    reason = reason
  })

  return true
end

-- ===== Exports =====

exports('GetBalance', Economy.GetBalance)
exports('Add', Economy.Add)
exports('Remove', Economy.Remove)

-- ===== Init =====

CreateThread(function()
  exports['aln-core']:OnReady(function()
    Log = exports['aln-core']:Log()
    DB  = exports['aln-db']

    Log.Info('economy.api.ready', {
      resource = GetCurrentResourceName()
    })
  end)
end)
