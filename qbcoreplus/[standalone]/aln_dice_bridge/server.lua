local QBCore = exports['qb-core']:GetCoreObject()

local function clamp(n, lo, hi)
  if n < lo then return lo end
  if n > hi then return hi end
  return n
end

local function getBandForXP(xp)
  local bands = Config.Criminal.Bands
  for _, b in ipairs(bands) do
    if xp <= b.max then return b end
  end
  return bands[#bands]
end

local function getXP(src)
  local Player = QBCore.Functions.GetPlayer(src)
  if not Player then return 0 end
  local md = Player.PlayerData.metadata or {}
  return tonumber(md.criminal_xp) or 0
end

local function setXP(src, xp)
  local Player = QBCore.Functions.GetPlayer(src)
  if not Player then return end
  xp = clamp(math.floor(tonumber(xp) or 0), 0, Config.Criminal.XPMax)
  Player.Functions.SetMetaData('criminal_xp', xp)
end

local function addXP(src, amount)
    local xp = getXP(src)
    local newXP = xp + (tonumber(amount) or 0)
    setXP(src, newXP)

    -- CHECK FOR LEVEL UP REWARDS
    local oldBand = getBandForXP(xp)
    local newBand = getBandForXP(newXP)

    if newBand.level > oldBand.level then
        TriggerClientEvent('QBCore:Notify', src, "LEVEL UP! Criminal Level " .. newBand.level, "primary")
    end

    -- LEVEL 3 REWARD: WEAPON LICENSE
    if newBand.level >= 3 then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            local licenses = Player.PlayerData.metadata['licences']
            
            -- Only give it if they don't have it yet
            if not licenses.weapon then
                licenses.weapon = true
                Player.Functions.SetMetaData('licences', licenses)
                TriggerClientEvent('QBCore:Notify', src, "UNLOCKED: Weapon License (Black Market Access)", "success")
            end
        end
    end
end

local function ensureMetadata(src)
  local Player = QBCore.Functions.GetPlayer(src)
  if not Player then return end
  local md = Player.PlayerData.metadata or {}
  if md.criminal_xp == nil then Player.Functions.SetMetaData('criminal_xp', 0) end
  if md.criminal_next_adv_until == nil then Player.Functions.SetMetaData('criminal_next_adv_until', 0) end
end

local function hasItem(src, itemName)
  if not itemName or itemName == '' then return false end
  local Player = QBCore.Functions.GetPlayer(src)
  return Player and Player.Functions.GetItemByName(itemName) ~= nil
end

local function removeItem(src, itemName, count)
  local Player = QBCore.Functions.GetPlayer(src)
  return Player and Player.Functions.RemoveItem(itemName, count or 1)
end

-- Compute DC Logic
local function computeDC(actionId, ctx)
  local a = Config.Actions[actionId]
  if not a then return 15 end
  local dc = a.baseDC or 15
  if ctx and ctx.vehicleClass ~= nil then
    local classDC = Config.VehicleClassDC[tonumber(ctx.vehicleClass)]
    if classDC then dc = classDC + ((a.baseDC or 0) - 12) end
  end
  if ctx and ctx.value then
    for _, bump in ipairs(Config.ValueBumps) do
      if tonumber(ctx.value) >= bump.min then dc = dc + bump.add end
    end
  end
  if ctx and ctx.dcOverride then dc = tonumber(ctx.dcOverride) or dc end
  return clamp(math.floor(dc), 1, 30)
end

-- Callbacks
lib.callback.register('aln_dice_bridge:getCriminalInfo', function(source)
  ensureMetadata(source)
  local xp = getXP(source)
  local band = getBandForXP(xp)
  return { xp = xp, level = band.level, mod = band.mod }
end)

lib.callback.register('aln_dice_bridge:computeCheck', function(source, actionId, ctx)
  ensureMetadata(source)
  local a = Config.Actions[actionId]
  if not a then return { allowed = false, reason = 'unknown_action' } end

  if a.requiresTool then
    local toolItem = ctx and ctx.toolItem
    if not toolItem or toolItem == '' or not hasItem(source, toolItem) then
      return { allowed = false, reason = 'missing_tool' }
    end
  end

  local xp = getXP(source)
  local band = getBandForXP(xp)
  local dc = computeDC(actionId, ctx or {})
  
  -- Mode Logic
  local mode = 'normal'
  local wanted = (ctx and tonumber(ctx.wantedLevel)) or 0
  if wanted >= (Config.Criminal.WantedDisThreshold or 1) then mode = 'dis' end
  if a.toolGivesAdv and ctx and ctx.toolTier == 'adv' and mode == 'normal' then mode = 'adv' end
  
  -- Next Roll Advantage Buff
  if Config.Criminal.NextAdvEnabled then
      local Player = QBCore.Functions.GetPlayer(source)
      local untilTs = tonumber(Player.PlayerData.metadata.criminal_next_adv_until) or 0
      if untilTs > os.time() then
          if mode == 'normal' then mode = 'adv' end
          Player.Functions.SetMetaData('criminal_next_adv_until', 0) -- Consume buff
      end
  end

  return { allowed = true, dc = dc, modifier = band.mod, mode = mode, xp = xp, level = band.level }
end)

-- Resolution Event
RegisterNetEvent('aln_dice_bridge:resolveCheck', function(payload)
  local src = source
  ensureMetadata(src)
  if type(payload) ~= 'table' then return end
  
  local actionId = payload.actionId
  local dc = tonumber(payload.dc)
  local raw = tonumber(payload.raw)
  local success = payload.success == true
  local ctx = payload.ctx or {}

  if not actionId or not dc or not raw then return end

  -- XP Reward
  if success then
    addXP(src, math.floor(dc * (Config.Criminal.SuccessXpPerDC or 10)))
  else
    if Config.Criminal.FailXpPerDC > 0 then addXP(src, math.floor(dc * Config.Criminal.FailXpPerDC)) end
  end

  -- Critical Success (Nat 20)
  if raw == 20 then
    if Config.Criminal.NextAdvEnabled then
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.SetMetaData('criminal_next_adv_until', os.time() + Config.Criminal.NextAdvTTLSeconds)
    end
    TriggerClientEvent('aln_dice_bridge:client:critSuccess', src, { clearWanted = true })
  end

  -- Critical Fail (Nat 1)
  if raw == 1 then
    TriggerClientEvent('aln_dice_bridge:client:critFail', src, {
      addWanted = Config.Criminal.CritFailWantedStars,
      spawnCops = Config.Criminal.SpawnCopsOnNat1,
      copCfg = Config.Criminal.CopSpawn
    })
  end

  -- Tool Breakage
  if Config.Criminal.ToolBreak.Enabled and ctx.toolItem then
    local breakChance = 0
    if raw == 1 then breakChance = Config.Criminal.ToolBreak.Nat1BreakChance
    elseif not success then
      local conf = Config.Criminal.ToolBreak
      breakChance = clamp(conf.Base + ((dc - 10) * conf.PerDc), conf.Min, conf.Max)
    end

    if breakChance > 0 and math.random(1, 100) <= breakChance then
      removeItem(src, ctx.toolItem, 1)
      TriggerClientEvent('aln_dice_bridge:client:toolBroke', src, { item = ctx.toolItem })
    end
  end
end)

-- PERCEPTION CHECK REWARD SYSTEM
RegisterNetEvent('aln_dice_bridge:server:perceptionReward', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- LOOT TABLE (Synced with your Item List)
    local lootTable = {
        -- Money
        { type = 'money', name = 'cash', amount = math.random(10, 50), weight = 20 },
        
        -- Common Items
        { type = 'item', name = 'lockpick',       amount = 1, weight = 10 },
        { type = 'item', name = 'water_bottle',   amount = 1, weight = 15 },
        { type = 'item', name = 'kurkakola',      amount = 1, weight = 15 },
        { type = 'item', name = 'sandwich',       amount = 1, weight = 10 }, 
        
        -- Special/Rare Items (Based on your screenshots)
        { type = 'item', name = 'rolling_paper',  amount = 5, weight = 8 },   
        { type = 'item', name = 'weed_baggy',     amount = 1, weight = 5 },   
        { type = 'item', name = 'weed_ak47',      amount = 1, weight = 2 },   
    }

    -- Weighted Random Logic
    local totalWeight = 0
    for _, item in pairs(lootTable) do totalWeight = totalWeight + item.weight end
    local roll = math.random(1, totalWeight)
    local current = 0
    local reward = nil

    for _, item in pairs(lootTable) do
        current = current + item.weight
        if roll <= current then reward = item break end
    end

    -- Give Reward & Notify
    if reward then
        if reward.type == 'money' then
            Player.Functions.AddMoney('cash', reward.amount, "Perception Check")
            TriggerClientEvent('QBCore:Notify', src, "Perception Success: Found $"..reward.amount..". (Added to Wallet)", "success")
        else
            local itemInfo = QBCore.Shared.Items[reward.name]
            local label = itemInfo and itemInfo.label or reward.name
            
            Player.Functions.AddItem(reward.name, reward.amount)
            TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "add")
            TriggerClientEvent('QBCore:Notify', src, "Perception Success: Found "..reward.amount.."x "..label..". (Added to Inventory)", "success")
        end
    end
end)

-- Admin Commands
if Config.Debug then
  QBCore.Commands.Add('criminal', 'Show Criminal XP', {}, false, function(source)
    local xp = getXP(source)
    local b = getBandForXP(xp)
    TriggerClientEvent('QBCore:Notify', source, ('XP: %d | Level: %d | Mod: %+d'):format(xp, b.level, b.mod))
  end)
  QBCore.Commands.Add('criminal_reset', 'Reset Criminal XP', {}, false, function(source)
    setXP(source, 0)
    TriggerClientEvent('QBCore:Notify', source, 'Criminal XP Reset.')
  end)
end

  RegisterNetEvent('aln_dice_bridge:server:evasionReward', function(stars)
      local src = source
      if not stars or stars <= 0 then return end
      
      -- CONFIG: XP Per Star (Recommended: 100)
      local xpPerStar = 100
      local totalXP = math.floor(stars * xpPerStar)

      -- Give the XP
      addXP(src, totalXP)
      
      TriggerClientEvent('QBCore:Notify', src, "Evaded " .. stars .. " Star(s): +" .. totalXP .. " Criminal XP", "success")
  end)