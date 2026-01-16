local QBCore = exports['qb-core']:GetCoreObject()
local pedProcessed = {}   -- victimNetId -> true
local lootBags = {}       -- bagNetId -> { items=..., expiresAt=... }
local bg3RollWindow = {}  -- second -> count (simple rate limit)

local function nowSec()
  return os.time()
end

local function rnd(min, max)
  if max <= min then return min end
  return math.random(min, max)
end

local function chance(p)
  return math.random() < p
end

local function getRelationshipProfile(victimPed)
  -- Relationship group is client-side native; server doesn’t have victim entity reliably.
  -- So: we keep server logic simple:
  -- - By default classify as HOSTILE if wielding weapon at death (not unarmed)
  -- - Otherwise CIV
  -- You can upgrade classification later via client-sent relationship group if you want.

  return nil
end

local function weaponClassFromHash(weaponHash)
  if not weaponHash or weaponHash == 0 then return nil end
  if weaponHash == `WEAPON_UNARMED` then return nil end

  -- Very basic classing
  if weaponHash == `WEAPON_PUMPSHOTGUN` or weaponHash == `WEAPON_SAWNOFFSHOTGUN` then return 'shotgun' end

  if weaponHash == `WEAPON_SMG` or weaponHash == `WEAPON_MICROSMG` or weaponHash == `WEAPON_MINISMG` then return 'smg' end

  if weaponHash == `WEAPON_CARBINERIFLE` or weaponHash == `WEAPON_ASSAULTRIFLE` or weaponHash == `WEAPON_COMPACTRIFLE` then return 'rifle' end

  if weaponHash == `WEAPON_PISTOL` or weaponHash == `WEAPON_COMBATPISTOL` or weaponHash == `WEAPON_APPISTOL` then return 'pistol' end

  return 'pistol'
end

local function pickOne(list)
  if not list or #list == 0 then return nil end
  return list[math.random(1, #list)]
end

local function addItem(items, name, amount, info)
  if not name or amount <= 0 then return end
  items[#items+1] = { name = name, amount = amount, info = info or {} }
end

local function rollLoot(profile, victimWeaponHash)
  local t = Config.Tables[profile] or Config.Tables.HOSTILE

  local items = {}

  -- cash
  local cash = rnd(t.cashMin, t.cashMax)

  -- ammo
  if chance(t.chanceAmmo) then
    local wc = weaponClassFromHash(victimWeaponHash) or pickOne(t.weaponBias) or 'pistol'
    local ammoItem = Config.AmmoItems[wc] or Config.AmmoItems.pistol
    addItem(items, ammoItem, rnd(Config.Qty.ammoMin, Config.Qty.ammoMax))
  end

  -- drugs
  if chance(t.chanceDrugs) then
    addItem(items, pickOne(Config.DrugItems), rnd(Config.Qty.drugMin, Config.Qty.drugMax))
  end

  -- general loot
  if chance(t.chanceLoot) then
    addItem(items, pickOne(Config.GeneralLoot), rnd(Config.Qty.lootMin, Config.Qty.lootMax))
  end

  -- rare weapon as loot (optional / conservative)
  local eligibleWeapon = victimWeaponHash and victimWeaponHash ~= 0 and victimWeaponHash ~= `WEAPON_UNARMED`
  if Config.WeaponLootOnlyIfWielded and not eligibleWeapon then
    -- no weapon
  else
    if eligibleWeapon and chance(Config.WeaponLootChance) then
      -- Convert hash to qb weapon item name (basic mapping; extend as needed)
      local weaponItem = nil
      if victimWeaponHash == `WEAPON_PISTOL` then weaponItem = 'weapon_pistol' end
      if victimWeaponHash == `WEAPON_COMBATPISTOL` then weaponItem = 'weapon_combatpistol' end
      if victimWeaponHash == `WEAPON_PUMPSHOTGUN` then weaponItem = 'weapon_pumpshotgun' end
      if victimWeaponHash == `WEAPON_SMG` then weaponItem = 'weapon_smg' end
      if victimWeaponHash == `WEAPON_CARBINERIFLE` then weaponItem = 'weapon_carbinerifle' end

      if weaponItem then
        addItem(items, weaponItem, 1, { serial = ('ALN%06d'):format(math.random(1, 999999)) })
      end
    end
  end

  return cash, items
end

local function giveCash(src, amount)
  if amount <= 0 then return end
  local Player = QBCore.Functions.GetPlayer(src)
  if not Player then return end

  if Config.CashMode == 'account' then
    Player.Functions.AddMoney(Config.CashAccountName, amount, 'aln_drops')
  else
    Player.Functions.AddItem(Config.CashItemName, amount, false, {})
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.CashItemName], 'add')
  end
end

local function giveItems(src, items)
  local Player = QBCore.Functions.GetPlayer(src)
  if not Player then return end
  for _, it in ipairs(items) do
    if it.name and it.amount and it.amount > 0 then
      Player.Functions.AddItem(it.name, it.amount, false, it.info or {})
    end
  end
end

local function anyWitnessNear(x, y, z, radius)
  local players = QBCore.Functions.GetPlayers()
  for _, src in ipairs(players) do
    local ped = GetPlayerPed(src)
    if ped and ped ~= 0 then
      local coords = GetEntityCoords(ped)
      local dx = coords.x - x
      local dy = coords.y - y
      local dz = coords.z - z
      local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
      if dist <= radius then
        return true
      end
    end
  end
  return false
end

local function bg3RateLimitOk()
  if not Config.BG3Dice.enabled then return false end
  local s = math.floor(GetGameTimer() / 1000)
  bg3RollWindow[s] = bg3RollWindow[s] or 0
  if bg3RollWindow[s] >= Config.BG3Dice.maxRollsPerSecond then
    return false
  end
  bg3RollWindow[s] = bg3RollWindow[s] + 1
  return true
end

-- Creates a simple world loot bag (prop) that is “take all”
local function createLootBagForAll(x, y, z, items, expiresAt)
  local model = Config.LootBagModel
  local obj = CreateObject(model, x, y, z - 0.98, true, true, true)
  local netId = NetworkGetNetworkIdFromEntity(obj)

  SetNetworkIdExistsOnAllMachines(netId, true)
  SetNetworkIdCanMigrate(netId, true)

  lootBags[netId] = { items = items, expiresAt = expiresAt }
  TriggerClientEvent(ALN_DROPS.Events.CreateLootBag, -1, netId, items, expiresAt)
end

RegisterNetEvent(ALN_DROPS.Events.ReportNpcDeath, function(victimNetId, x, y, z, victimWeaponHash)
  local src = source
  if pedProcessed[victimNetId] then return end
  pedProcessed[victimNetId] = true

  -- Corpse persistence + possible EMS revive
  local witnessed = anyWitnessNear(x, y, z, Config.WitnessRadius)
  local emsWillRevive = witnessed and chance(Config.WitnessCallEmsChance)

  -- Loot profile (starter heuristic):
  -- If the NPC was armed, treat as HOSTILE; else CIV.
  local profile = 'CIV'
  if victimWeaponHash and victimWeaponHash ~= 0 and victimWeaponHash ~= `WEAPON_UNARMED` then
    profile = 'HOSTILE'
  end

  -- Optional BG3 dice integration (kept minimal + rate limited)
  -- If you wire a server export/event from bg3_dice later, place it here.
  -- For now, it always falls back to RNG unless you implement the dice call.
  local cash, items = rollLoot(profile, victimWeaponHash)

  -- Create loot bag in world OR give directly (bag recommended)
  if Config.UseWorldLootBag and #items > 0 then
    local expiresAt = nowSec() + Config.LootBagDespawnSeconds
    createLootBagForAll(x, y, z, items, expiresAt)
  else
    -- fallback: give to killer only
    giveItems(src, items)
  end

  -- cash always goes to killer (basic + low overhead)
  giveCash(src, cash)

  -- EMS behavior
  if emsWillRevive then
    local delay = rnd(Config.EmsReviveDelayMinSeconds, Config.EmsReviveDelayMaxSeconds)
    SetTimeout(delay * 1000, function()
      TriggerClientEvent(ALN_DROPS.Events.ReviveNpc, -1, victimNetId)
    end)
  end

  -- Cleanup after persist window (only if not revived; revive event doesn't mark state,
  -- so we just delay cleanup and delete entity; if you want "revived keeps living",
  -- set DeleteCorpseOnTimeout=false)
  if Config.DeleteCorpseOnTimeout then
    SetTimeout(Config.CorpsePersistSeconds * 1000, function()
      TriggerClientEvent(ALN_DROPS.Events.CleanupCorpse, -1, victimNetId)
      pedProcessed[victimNetId] = nil
    end)
  end
end)

RegisterNetEvent(ALN_DROPS.Events.LootBagTakeAll, function(bagNetId)
  local src = source
  local data = lootBags[bagNetId]
  if not data then return end
  if data.expiresAt and nowSec() > data.expiresAt then
    lootBags[bagNetId] = nil
    return
  end

  giveItems(src, data.items)

  -- cleanup bag object + server cache
  local ent = NetworkGetEntityFromNetworkId(bagNetId)
  if ent and ent ~= 0 then
    DeleteEntity(ent)
  end
  lootBags[bagNetId] = nil
end)
