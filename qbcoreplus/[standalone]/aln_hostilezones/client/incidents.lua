-- aln_hostilezones/client/incidents.lua
CreateThread(function()
    local opsSecondsInZone = 0
    local lastOpsTick = 0

    while true do
        Wait(250)

        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        -- gunshots add heat
        if IsPedShooting(ped) then
            for zoneId, zone in pairs(Config.Zones) do
                if Util.InZone(pos, zone) then
                    TriggerServerEvent("aln_hostiles:addHeat", zoneId, Config.Heat.IncidentWeights.gunshot, Constants.Incident.GUNSHOT)
                end
            end
        end

        -- ops lingering: if a zone has ops rules, being inside increments pressure/heat on interval
        for zoneId, zone in pairs(Config.Zones) do
            if zone.rules and zone.rules.ops and zone.rules.ops.enabled then
                if Util.InZone(pos, zone) then
                    opsSecondsInZone = opsSecondsInZone + 0.25

                    local warnAt = zone.rules.ops.lingerSecondsToWarn or 25
                    local hostileAt = zone.rules.ops.lingerSecondsToHostile or 60
                    if opsSecondsInZone >= warnAt and opsSecondsInZone < hostileAt then
                        TriggerEvent(Constants.Events.OpsPressure, zoneId, math.floor(opsSecondsInZone), 0)
                    end

                    local tickInt = (zone.rules.ops.heatTickIntervalSec or 10)
                    if GetGameTimer() - lastOpsTick > (tickInt * 1000) then
                        lastOpsTick = GetGameTimer()
                        TriggerServerEvent("aln_hostiles:addHeat", zoneId, Config.Heat.IncidentWeights.opsLingering, Constants.Incident.OPS_LINGER)
                        TriggerEvent(Constants.Events.OpsPressure, zoneId, math.floor(opsSecondsInZone), 1)
                    end
                else
                    opsSecondsInZone = 0
                    lastOpsTick = 0
                end
            end
        end
    end
end)
