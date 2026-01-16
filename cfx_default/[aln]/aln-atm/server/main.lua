ALN = ALN or {}

local function getIdentityKey(src)
  return exports['aln-economy']:GetIdentityKey(src)
end

local function getBalances(src)
  local idKey = getIdentityKey(src)
  return {
    cash = exports['aln-economy']:GetBalance(idKey, 'cash') or 0,
    bank = exports['aln-economy']:GetBalance(idKey, 'bank') or 0,
  }
end

-- v0 card ownership: until inventory exists, we fake it with a server-side cache.
-- If you already want this to use aln-inventory immediately, we can switch when inventory exists.
local hasCard = {}

local function playerHasCard(src)
  -- If inventory exists later, replace with: exports['aln-inventory']:HasItem(...)
  return hasCard[src] == true
end

local function setCard(src, v)
  hasCard[src] = v == true
end

RegisterNetEvent('aln:atm:requestSnapshot', function(locationId)
  local src = source
  local b = getBalances(src)
  TriggerClientEvent('aln:atm:snapshot', src, {
    cash = b.cash,
    bank = b.bank,
    hasCard = playerHasCard(src),
    cardCost = Config.ATM.CardCost or 100,
    locationId = locationId,
  })
end)

RegisterNetEvent('aln:atm:buyCard', function()
  local src = source
  if playerHasCard(src) then
    TriggerClientEvent('aln:atm:update', src, { hasCard = true, cash = getBalances(src).cash, bank = getBalances(src).bank })
    return
  end

  local cost = Config.ATM.CardCost or 100
  local ok = exports['aln-economy']:Debit(src, 'cash', cost, 'atm.card_purchase', { cost = cost })
  if ok then
    setCard(src, true)
  end

  local b = getBalances(src)
  TriggerClientEvent('aln:atm:update', src, { hasCard = playerHasCard(src), cash = b.cash, bank = b.bank })
end)

RegisterNetEvent('aln:atm:deposit', function(amount)
  local src = source
  amount = math.floor(tonumber(amount) or 0)
  if amount <= 0 then return end
  if amount > (Config.ATM.MaxDeposit or 50000) then amount = Config.ATM.MaxDeposit end
  if not playerHasCard(src) then return end

  local ok, res = exports['aln-economy']:Transfer(src, 'cash', 'bank', amount, 'atm.deposit', { amount = amount })
  local b = getBalances(src)
  TriggerClientEvent('aln:atm:update', src, { hasCard = playerHasCard(src), cash = b.cash, bank = b.bank, ok = ok, reason = res })
end)

RegisterNetEvent('aln:atm:withdraw', function(amount)
  local src = source
  amount = math.floor(tonumber(amount) or 0)
  if amount <= 0 then return end
  if amount > (Config.ATM.MaxWithdraw or 50000) then amount = Config.ATM.MaxWithdraw end
  if not playerHasCard(src) then return end

  local ok, res = exports['aln-economy']:Transfer(src, 'bank', 'cash', amount, 'atm.withdraw', { amount = amount })
  local b = getBalances(src)
  TriggerClientEvent('aln:atm:update', src, { hasCard = playerHasCard(src), cash = b.cash, bank = b.bank, ok = ok, reason = res })
end)

AddEventHandler('playerDropped', function()
  hasCard[source] = nil
end)
