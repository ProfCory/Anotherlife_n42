Blips = {}
Blips.active = {}

function Blips.Update(zoneId, zone, playerPos)
    if not Config.Blips.enabled then return end

    local dist = Util.Distance(playerPos, zone.center)
    local show = dist <= Config.Blips.showNearDistance

    if show and not Blips.active[zoneId] then
        local blip = AddBlipForRadius(zone.center.x, zone.center.y, zone.center.z, zone.radius)
        SetBlipColour(blip, 1)
        SetBlipAlpha(blip, 90)
        Blips.active[zoneId] = blip
    elseif not show and Blips.active[zoneId] then
        RemoveBlip(Blips.active[zoneId])
        Blips.active[zoneId] = nil
    end
end
