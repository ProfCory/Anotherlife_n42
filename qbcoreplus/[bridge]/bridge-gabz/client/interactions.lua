-- bridge-gabz: optional qb-target interactions

local function qbTargetReady()
  return BG_CFG.Integrations.UseQbTarget
    and BG_CFG.Interactions.Enabled
    and GetResourceState(BG_CFG.Integrations.QbTargetResource) == 'started'
end

local TargetIds = {}

local function isClosed(id)
  local untilMs = (exports['bridge-gabz']:getClosedUntil() or {})[id] or 0
  local nowServerMs = (lib.getServerTime() or os.time()) * 1000
  return untilMs > nowServerMs
end

local function addLocationTargets()
  if not qbTargetReady() then return end

  local locs = exports['bridge-gabz']:getLocations() or {}
  for _, loc in ipairs(locs) do
    if loc.enabled and loc.visitors and loc.visitors.entry then
      local center = loc.visitors.entry
      local zoneName = ('bridge-gabz:%s'):format(loc.id)

      if TargetIds[zoneName] then
        -- avoid duplicates
      else
        TargetIds[zoneName] = true

        exports[BG_CFG.Integrations.QbTargetResource]:AddCircleZone(zoneName, vec3(center.x, center.y, center.z), 2.5, {
          name = zoneName,
          useZ = true,
          debugPoly = BG_CFG.Debug
        }, {
          options = {
            {
              icon = 'fas fa-comment',
              label = BG_CFG.Interactions.TalkLabel,
              action = function()
                lib.notify({ title = loc.label or loc.id, description = 'Busy. Come back later.', type = 'inform' })
              end,
              canInteract = function()
                return not isClosed(loc.id)
              end
            },
            {
              icon = 'fas fa-mask',
              label = BG_CFG.Interactions.RobLabel,
              action = function()
                lib.notify({ title = loc.label or loc.id, description = 'People panic and scatter...', type = 'warning' })
                if BG_CFG.Interactions.RobTriggersCooldown then
                  TriggerServerEvent('bridge-gabz:server:closeLocation', loc.id, BG_CFG.Cleanup.CloseForSeconds, 'robbery')
                end
              end,
              canInteract = function()
                return not isClosed(loc.id)
              end
            }
          },
          distance = 2.5
        })
      end
    end
  end
end

AddEventHandler('onResourceStart', function(res)
  if res == GetCurrentResourceName() or res == BG_CFG.Integrations.QbTargetResource then
    SetTimeout(750, addLocationTargets)
  end
end)

RegisterNetEvent('bridge-gabz:client:locationsUpdated', function()
  -- qb-target does not expose a universal remove API for all versions.
  -- On updates, server restarts are the cleanest path.
  SetTimeout(750, addLocationTargets)
end)

CreateThread(function()
  Wait(1000)
  addLocationTargets()
end)
