local roster = {}
local onDuty = {}
local palEntities = {}  -- [palId] = { ped=entity, blip=blipId, vehicle=entity? }
local myMoney = 0

local function notify(t, msg)
  lib.notify({ type=t, description=msg })
end

local function ensureRelationshipGroup()
  AddRelationshipGroup(Config.RelationshipGroup)
  local h = joaat(Config.RelationshipGroup)
  SetRelationshipBetweenGroups(0, h, h)
  SetRelationshipBetweenGroups(0, h, joaat("PLAYER"))
  SetRelationshipBetweenGroups(0, joaat("PLAYER"), h)
end

local function applyTier(ped, tier)
  local t = Config.Tiers[tier or 1] or Config.Tiers[1]
  SetPedAccuracy(ped, t.accuracy or 25)
  SetPedCombatAbility(ped, t.combatAbility or 1)
  SetPedCombatMovement(ped, t.combatMove or 2)
end

local function applyBasics(ped)
  SetBlockingOfNonTemporaryEvents(ped, true)
  SetPedFleeAttributes(ped, 0, false)
  SetPedCombatAttributes(ped, 46, true) -- Always fight
end

local function armPal(ped, prefers)
  prefers = prefers or {}
  if prefers.armor then SetPedArmour(ped, 100) end
  if prefers.weapon then
    local w = Config.WeaponList[math.random(#Config.WeaponList)]
    GiveWeaponToPed(ped, w, 180, false, true)
    SetCurrentPedWeapon(ped, w, true)
  end
end

local function setStealth(ped, prefers)
  if prefers and prefers.stealth then
    SetPedSeeingRange(ped, 25.0)
    SetPedHearingRange(ped, 25.0)
  else
    SetPedSeeingRange(ped, 70.0)
    SetPedHearingRange(ped, 70.0)
  end
end

local function followPlayer(ped, tier)
  local t = Config.Tiers[tier or 1] or Config.Tiers[1]
  local speed = t.followSpeed or 3.0
  local playerPed = PlayerPedId()
  ClearPedTasks(ped)
  TaskFollowToOffsetOfEntity(ped, playerPed, 0.0, 0.9, 0.0, speed, -1, 1.0, true)
end

local function tryEnterMyVehicle(ped)
  local playerPed = PlayerPedId()
  local veh = GetVehiclePedIsIn(playerPed, false)
  if veh == 0 then return false end

  local maxSeats = GetVehicleModelNumberOfSeats(GetEntityModel(veh))
  for seat = -1, maxSeats - 2 do
    if IsVehicleSeatFree(veh, seat) then
      TaskEnterVehicle(ped, veh, 8000, seat, 2.0, 1, 0)
      return true
    end
  end
  return false
end

local function startDownedRegenLoop(palId, ped)
  if not Config.EnableDownedRegen then return end
  CreateThread(function()
    while palEntities[palId] and DoesEntityExist(ped) do
      Wait(250)
      if IsEntityDead(ped) then
        local coords = GetEntityCoords(ped)
        ResurrectPed(ped)
        SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
        ClearPedTasksImmediately(ped)
        SetPedToRagdoll(ped, Config.DownTimeMs, Config.DownTimeMs, 0, true, true, false)
        Wait(Config.DownTimeMs)
        SetEntityHealth(ped, Config.ReviveHealth)
        ClearPedTasksImmediately(ped)
      end
    end
  end)
end

local function setPalBlip(palId, ped, pal, enabled)
  if not Config.EnableBlips then return end
  palEntities[palId] = palEntities[palId] or {}

  if palEntities[palId].blip and DoesBlipExist(palEntities[palId].blip) then
    RemoveBlip(palEntities[palId].blip)
    palEntities[palId].blip = nil
  end

  if not enabled then return end
  if not ped or not DoesEntityExist(ped) then return end

  local blip = AddBlipForEntity(ped)
  SetBlipSprite(blip, Config.BlipSprite)
  SetBlipScale(blip, Config.BlipScale)
  SetBlipAsShortRange(blip, false)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(("Pal: %s"):format(pal.name or "Unknown"))
  EndTextCommandSetBlipName(blip)

  palEntities[palId].blip = blip
end

local function findNearbyNPC()
  local playerPed = PlayerPedId()
  local pcoords = GetEntityCoords(playerPed)

  local handle, ped = FindFirstPed()
  local success = true
  local closest, bestDist = nil, 999.0

  repeat
    if DoesEntityExist(ped) and not IsPedAPlayer(ped) and not IsEntityDead(ped) then
      local d = #(GetEntityCoords(ped) - pcoords)
      if d < bestDist and d <= Config.MakeDistance then
        if not IsPedInAnyVehicle(ped, false) then
          closest, bestDist = ped, d
        end
      end
    end
    success, ped = FindNextPed(handle)
  until not success
  EndFindPed(handle)

  return closest
end

function openMakePalMenu()
  lib.registerContext({
    id = "aln_makeapal_create",
    title = "Make a Pal",
    options = {
      {
        title = "Register nearby NPC",
        description = "Converts a nearby NPC into your roster (persistent)",
        onSelect = function()
          local target = findNearbyNPC()
          if not target then notify("error","No suitable NPC nearby.") return end

          local input = lib.inputDialog("Pal Setup", {
            { type="select", label="Tier", options = {
              { label="1 - Noob", value=1 },
              { label="2 - Basic", value=2 },
              { label="3 - Chad", value=3 },
            }, default=2 },
            { type="checkbox", label="Armor preference", checked=false },
            { type="checkbox", label="Weapon preference", checked=false },
            { type="checkbox", label="Stealth preference", checked=false },
          })
          if not input then return end

          local tier = input[1]
          local armor = input[2]
          local weapon = input[3]
          local stealth = input[4]

          SetEntityAsMissionEntity(target, true, true)
          SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(target), false)

          local netId = NetworkGetNetworkIdFromEntity(target)
          local model = GetEntityModel(target)

          TriggerServerEvent("aln_makeapal:server:registerPal", netId, model, {
            tier = tier, armor = armor, weapon = weapon, stealth = stealth
          })
        end
      },
      {
        title = "Open roster",
        onSelect = function()
          TriggerServerEvent("aln_makeapal:server:getRoster")
        end
      },
      {
        title = "I need backup",
        onSelect = function()
          TriggerServerEvent("aln_makeapal:server:needBackup")
        end
      }
    }
  })
  lib.showContext("aln_makeapal_create")
end

local function openRosterMenu()
  local options = {}

  for palId, pal in pairs(roster) do
    local duty = onDuty[palId] and "On Duty" or "Off Duty"
    local tier = pal.tier or 1
    local tierLabel = (Config.Tiers[tier] and Config.Tiers[tier].label) or ("Tier "..tier)

    options[#options+1] = {
      title = ("%s [%s] (%s)"):format(pal.name or "Unknown", duty, tierLabel),
      description = ("Hangout: %s | Last hire: %s"):format(pal.hangout or "?", pal.notes and pal.notes.lastHireCost or "0"),
      onSelect = function()
        lib.registerContext({
          id = "aln_makeapal_pal_"..palId,
          title = pal.name or "Pal",
          options = {
            {
              title = "Hire / On Duty",
              description = "Pay to activate this pal",
              onSelect = function()
                local input = lib.inputDialog("Hire Options", {
                  { type="checkbox", label="Armor", checked=pal.prefers and pal.prefers.armor or false },
                  { type="checkbox", label="Weapon", checked=pal.prefers and pal.prefers.weapon or false },
                  { type="checkbox", label="Stealth", checked=pal.prefers and pal.prefers.stealth or false },
                })
                if not input then return end
                TriggerServerEvent("aln_makeapal:server:hireOnDuty", palId, {
                  armor = input[1], weapon = input[2], stealth = input[3]
                })
              end
            },
            {
              title = "Set Off Duty",
              onSelect = function()
                TriggerServerEvent("aln_makeapal:server:setDuty", palId, false)
              end
            },
            {
              title = "Command: Follow",
              onSelect = function()
                local ent = palEntities[palId] and palEntities[palId].ped
                if ent and DoesEntityExist(ent) then followPlayer(ent, pal.tier) end
              end
            },
            {
              title = "Command: Enter my vehicle",
              onSelect = function()
                local ent = palEntities[palId] and palEntities[palId].ped
                if ent and DoesEntityExist(ent) then
                  if not tryEnterMyVehicle(ent) then notify("error","No seat or you are not in a vehicle.") end
                end
              end
            },
            {
              title = "Set Tier",
              description = "Adjust tier for future hires",
              onSelect = function()
                local tIn = lib.inputDialog("Set Tier", {
                  { type="select", label="Tier", options = {
                    { label="1 - Noob", value=1 },
                    { label="2 - Basic", value=2 },
                    { label="3 - Chad", value=3 },
                  }, default=pal.tier or 2 }
                })
                if not tIn then return end
                TriggerServerEvent("aln_makeapal:server:updatePalTier", palId, tIn[1])
              end
            },
          }
        })
        lib.showContext("aln_makeapal_pal_"..palId)
      end
    }
  end

  lib.registerContext({
    id = "aln_makeapal_roster",
    title = ("Pals (Money: %d %s)"):format(myMoney or 0, Config.CurrencyLabel),
    options = options
  })
  lib.showContext("aln_makeapal_roster")
end

RegisterNetEvent("aln_makeapal:client:registeredPal", function(pal)
  roster[pal.palId] = pal

  local ped = NetToPed(pal.netId)
  if ped ~= 0 and DoesEntityExist(ped) then
    ensureRelationshipGroup()
    SetPedRelationshipGroupHash(ped, joaat(Config.RelationshipGroup))
    applyBasics(ped)
    applyTier(ped, pal.tier)

    palEntities[pal.palId] = palEntities[pal.palId] or {}
    palEntities[pal.palId].ped = ped

    setPalBlip(pal.palId, ped, pal, true)
    startDownedRegenLoop(pal.palId, ped)
  end

  notify("success", ("Registered %s (Tier %d). Usual area: %s"):format(pal.name, pal.tier or 1, pal.hangout or "?"))
end)

RegisterNetEvent("aln_makeapal:client:setOnDuty", function(palId, duty, pal)
  onDuty[palId] = duty
  roster[palId] = pal or roster[palId]
  pal = roster[palId]
  if not pal then return end

  local ped = palEntities[palId] and palEntities[palId].ped
  if ped and DoesEntityExist(ped) then
    applyBasics(ped)
    applyTier(ped, pal.tier)
    armPal(ped, pal.prefers)
    setStealth(ped, pal.prefers)

    if duty then
      followPlayer(ped, pal.tier)
      tryEnterMyVehicle(ped)
      setPalBlip(palId, ped, pal, true)
    else
      ClearPedTasks(ped)
      TaskStandStill(ped, -1)
      setPalBlip(palId, ped, pal, true) -- keep blip even off duty (still “a pal”)
    end
  end
end)

RegisterNetEvent("aln_makeapal:client:roster", function(pals, duty, money)
  roster = pals or {}
  onDuty = duty or {}
  myMoney = money or 0
  openRosterMenu()
end)

RegisterNetEvent("aln_makeapal:client:backup", function(pals, duty)
  roster = pals or roster
  onDuty = duty or onDuty
  for palId, pal in pairs(roster) do
    local ped = palEntities[palId] and palEntities[palId].ped
    if ped and DoesEntityExist(ped) then
      applyTier(ped, pal.tier)
      followPlayer(ped, pal.tier)
      tryEnterMyVehicle(ped)
    end
  end
end)

RegisterNetEvent("aln_makeapal:client:palUpdated", function(palId, pal)
  roster[palId] = pal
  local ped = palEntities[palId] and palEntities[palId].ped
  if ped and DoesEntityExist(ped) then
    applyTier(ped, pal.tier)
  end
  notify("inform", ("Updated %s to Tier %d."):format(pal.name or "Pal", pal.tier or 1))
end)

lib.addKeybind({
  name = 'aln_makeapal_make',
  description = 'Make a Pal menu',
  defaultKey = Config.MakeKey,
  onPressed = function()
    openMakePalMenu()
  end
})

_G.openMakePalMenu = openMakePalMenu

RegisterCommand("pals", function()
  TriggerServerEvent("aln_makeapal:server:getRoster")
end, false)

RegisterCommand("needbackup", function()
  TriggerServerEvent("aln_makeapal:server:needBackup")
end, false)
