ALN = ALN or {}
ALN.Economy = ALN.Economy or {}

local A = ALN.Economy.Accounts

-- In-memory balances: identityKey -> { cash=..., bank=..., dirty=... }
local balances = {}

local function dbg(ev, f)
  if Config and Config.Economy and Config.Economy.Debug then
    ALN.Log.Debug(ev, f or {})
  end
end

local function cap(account, value)
  local caps = (Config.Economy and Config.Economy.Caps) or {}
  local c = caps[account]
  if type(c) == 'number' and value > c then return c end
  return value
end

local function ensureIdentity(identityKey)
  if not balances[identityKey] then
    local d = (Config.Economy and Config.Economy.Defaults) or { cash=0, bank=0, dirty=0 }
    balances[identityKey] = {
      [A.CASH]  = tonumber(d.cash)  or 0,
      [A.BANK]  = tonumber(d.bank)  or 0,
      [A.DIRTY] = tonumber(d.dirty) or 0,
    }
    dbg('economy.identity_init', { identityKey = identityKey, defaults = balances[identityKey] })
  end
  return balances[identityKey]
end

function ALN.Economy.GetBalance(identityKey, account)
  local b = ensureIdentity(identityKey)
  return b[account] or 0
end

function ALN.Economy.SetBalance(identityKey, account, value)
  local b = ensureIdentity(identityKey)
  value = tonumber(value) or 0
  value = cap(account, value)
  b[account] = value
  return value
end

function ALN.Economy.Add(identityKey, account, amount)
  local b = ensureIdentity(identityKey)
  amount = tonumber(amount) or 0
  local newValue = cap(account, (b[account] or 0) + amount)
  b[account] = newValue
  return newValue
end

function ALN.Economy.CanAfford(identityKey, account, amount)
  amount = tonumber(amount) or 0
  if amount <= 0 then return true end
  local bal = ALN.Economy.GetBalance(identityKey, account)
  return bal >= amount
end

exports('GetBalance', function(identityKey, account) return ALN.Economy.GetBalance(identityKey, account) end)
exports('CanAfford', function(identityKey, account, amount) return ALN.Economy.CanAfford(identityKey, account, amount) end)
