ALN = ALN or {}
ALN.Stash = ALN.Stash or {}

-- Pure helpers for stash IDs and slot caps.
function ALN.Stash.IdHome(locationId)   return ('stash:home:%s'):format(locationId) end
function ALN.Stash.IdMotel(locationId)  return ('stash:motel:%s'):format(locationId) end
function ALN.Stash.IdVehicle(plate)     return ('stash:veh:%s'):format(plate) end

function ALN.Stash.MaxSlotsFor(stashId)
  if stashId:find('^stash:veh:') then return Config.Inventory.Stash.MaxSlotsVehicle or 20 end
  if stashId:find('^stash:home:') then return Config.Inventory.Stash.MaxSlotsHome or 30 end
  if stashId:find('^stash:motel:') then return Config.Inventory.Stash.MaxSlotsMotel or 15 end
  return 10
end
