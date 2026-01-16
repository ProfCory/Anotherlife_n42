-- aln_hostilezones/client/main.lua
CreateThread(function()
    AI.InitRelationships()

    local current = nil

    while true do
        Wait(500)

        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        -- detect zone membership (single zone at a time for MVP: nearest containing)
        local found = nil
        local foundDist = 999999.0

        for zoneId, zone in pairs(Config.Zones) do
            if Util.InZone(pos, zone) then
                local d = Util.Distance(pos, zone.center)
                if d < foundDist then
                    found = zoneId
                    foundDist = d
                end
            end

            -- blips + debug
            Blips.Update(zoneId, zone, pos)
            if Config.Debug then
                Util.DrawCircle(zone.center, zone.radius)
                if zone.cores then
                    for _, c in ipairs(zone.cores) do
                        Util.DrawCircle(c.center, c.radius)
                    end
                end
            end
        end

        if found ~= current then
            if current then
                Director.OnExit(current)
            end
            if found then
                Director.OnEnter(found)
            end
            current = found
        end
    end
end)
