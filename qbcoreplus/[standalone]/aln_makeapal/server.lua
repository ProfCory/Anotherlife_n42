local Persist = require("persistence")

local Pals = {}   -- [playerKey] = { pals = { [palId]=palData }, onDuty = { [palId]=true/false }, meta = {loaded=true} }

-- Simple fallback wallet (in-memory). Replace these functions with your economy later.
local Cash = {}   -- [playerKey] = number

local function GetCitizenKey(src)
  local ids = GetPlayerIdentifiers(src)
  for _, v in ipairs(ids) do
    if v:find("license:") == 1 then return v end
  end
  return ("src:%d"):format(src)
end

local function EnsurePlayer(src)
  local key = GetCitizenKey(src)
  Pals[key] = Pals[key] or { pals = {}, onDuty = {}, meta = {} }

  if not Pals[key].meta.loaded then
    local saved = Persist.LoadPlayer(key)
    Pals[key].pals = saved.pals or {}
    Pals[key].meta = saved.meta or {}
    Pals[key].meta.loaded = true
  end

  Cash[key] = Cash[key] or 5000
  return key
end

local function SavePlayerNow(key)
  Persist.SavePlayer(key, { pals = Pals[key].pals, meta = Pals[key].meta })
end

local function GetMoney(src)
  local key = EnsurePlayer(src)
  return Cash[key] or 0
end

local function RemoveMoney(src, amount)
  local key = EnsurePlayer(src)
  amount = math.floor(amount)
  if amount <= 0 then return true end
  if (Cash[key] or 0) < amount then return false end
  Cash[key] = (Cash[key] or 0) - amount
  return true
end

local function CountOnDuty(key)
  local c = 0
  for _, v in pairs(Pals[key].onDuty) do
    if v then c = c + 1 end
  end
  return c
end

local function ComputeHireCost(key, pal, opts)
  opts = opts or {}
  local base = Config.BaseHireCost
  if opts.armor then base = base + Config.CostArmor end
  if opts.weapon then base = base + Config.CostWeapon end
  if opts.stealth then base = base + Config.CostStealth end

  local tier = (pal and pal.tier) or 1
  local wageMult = (Config.Tiers[tier] and Config.Tiers[tier].wageMult) or 1.0
  base = base * wageMult

  local dutyCount = CountOnDuty(key)
  local scale = Shared.ScaleForCrewCount(dutyCount + 1)
  return math.floor(base * scale)
end

RegisterNetEvent("aln_makeapal:server:getRoster", function()
  local src = source
  local key = EnsurePlayer(src)
  TriggerClientEvent("aln_makeapal:client:roster", src, Pals[key].pals, Pals[key].onDuty, GetMoney(src))
end)

RegisterNetEvent("aln_makeapal:server:registerPal", function(netId, pedModel, opts)
  local src = source
  local key = EnsurePlayer(src)
  local state = Pals[key]

  local totalRegistered = 0
  for _ in pairs(state.pals) do totalRegistered = totalRegistered + 1 end
  if totalRegistered >= Config.MaxCrew then
    TriggerClientEvent("ox_lib:notify", src, { type="error", description=("Max pals reached (%d)."):format(Config.MaxCrew) })
    return
  end

  local palId = ("pal_%d_%d"):format(src, os.time() + math.random(9999))
  local name = Shared.RandomName()
  local hangout = Shared.RandomHangout()

  opts = opts or {}
  local tier = tonumber(opts.tier) or 1
  if tier < 1 then tier = 1 end
  if tier > 3 then tier = 3 end

  state.pals[palId] = {
    palId = palId,
    name = name,
    hangout = hangout,
    netId = netId,
    model = pedModel,
    createdAt = os.time(),
    tier = tier,
    prefers = {
      armor = opts.armor or false,
      weapon = opts.weapon or false,
      stealth = opts.stealth or false,
    },
    upgrades = opts.upgrades or { weapon=false, armor=false, driver=false, vehicle=nil },
    ownedVehicle = opts.ownedVehicle or nil,
    notes = { lastHireCost = 0, totalPaid = 0 },
  }

  SavePlayerNow(key)
  TriggerClientEvent("aln_makeapal:client:registeredPal", src, state.pals[palId])
end)

RegisterNetEvent("aln_makeapal:server:hireOnDuty", function(palId, opts)
  local src = source
  local key = EnsurePlayer(src)
  local state = Pals[key]
  local pal = state.pals[palId]
  if not pal then return end

  if state.onDuty[palId] then
    TriggerClientEvent("ox_lib:notify", src, { type="inform", description=(pal.name .. " is already on duty.") })
    return
  end

  opts = opts or pal.prefers or {}
  local cost = ComputeHireCost(key, pal, opts)

  if not RemoveMoney(src, cost) then
    TriggerClientEvent("ox_lib:notify", src, { type="error", description=("Not enough %s. Need %d."):format(Config.CurrencyLabel, cost) })
    return
  end

  state.onDuty[palId] = true

  pal.prefers.armor = opts.armor or pal.prefers.armor
  pal.prefers.weapon = opts.weapon or pal.prefers.weapon
  pal.prefers.stealth = opts.stealth or pal.prefers.stealth
  pal.ownedVehicle = opts.ownedVehicle or pal.ownedVehicle

  pal.notes = pal.notes or { lastHireCost = 0, totalPaid = 0 }
  pal.notes.lastHireCost = cost
  pal.notes.totalPaid = (pal.notes.totalPaid or 0) + cost

  SavePlayerNow(key)

  TriggerClientEvent("aln_makeapal:client:setOnDuty", src, palId, true, pal)
  TriggerClientEvent("ox_lib:notify", src, { type="success", description=("Hired %s (Cost: %d %s)"):format(pal.name, cost, Config.CurrencyLabel) })
end)

RegisterNetEvent("aln_makeapal:server:setDuty", function(palId, onDuty)
  local src = source
  local key = EnsurePlayer(src)
  local state = Pals[key]
  local pal = state.pals[palId]
  if not pal then return end
  state.onDuty[palId] = onDuty and true or false
  TriggerClientEvent("aln_makeapal:client:setOnDuty", src, palId, state.onDuty[palId], pal)
end)

RegisterNetEvent("aln_makeapal:server:needBackup", function()
  local src = source
  local key = EnsurePlayer(src)
  local state = Pals[key]

  for palId, _ in pairs(state.pals) do
    state.onDuty[palId] = true
  end

  TriggerClientEvent("aln_makeapal:client:backup", src, state.pals, state.onDuty)
  TriggerClientEvent("ox_lib:notify", src, { type="inform", description="Backup requested. Your registered pals are responding." })
end)

RegisterNetEvent("aln_makeapal:server:updatePalTier", function(palId, tier)
  local src = source
  local key = EnsurePlayer(src)
  local pal = Pals[key].pals[palId]
  if not pal then return end

  tier = tonumber(tier) or 1
  if tier < 1 then tier = 1 end
  if tier > 3 then tier = 3 end
  pal.tier = tier

  SavePlayerNow(key)
  TriggerClientEvent("aln_makeapal:client:palUpdated", src, palId, pal)
end)

AddEventHandler("playerDropped", function()
  local src = source
  local key = GetCitizenKey(src)
  if Pals[key] and Pals[key].meta and Pals[key].meta.loaded then
    Persist.SavePlayer(key, { pals = Pals[key].pals, meta = Pals[key].meta })
  end
end)

exports("GetMoney", function(src) return GetMoney(src) end)
exports("RemoveMoney", function(src, amt) return RemoveMoney(src, amt) end)
