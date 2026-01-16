local Config = Config
local Constants = Constants

ZoneState.Init()

CreateThread(function()
    while true do
        Wait(1000)
        ZoneState.DecayHeat()

        local hour = (GetClockHours and GetClockHours()) or os.date("*t").hour
        local isNight = (hour >= Config.Time.NightStartHour or hour <= Config.Time.NightEndHour)
        local timeMod = isNight and 1 or 0

        for zoneId, state in pairs(ZoneState.zones) do
            if not ZoneState.IsOnCooldown(zoneId) then
                ZoneState.RecomputeTier(zoneId, timeMod)

                if state.tier ~= state.lastTier then
                    state.lastTier = state.tier
                    if not state.activeFaction then
                        state.activeFaction = Selector.PickFaction(zoneId)
                    end
                    TriggerClientEvent(Constants.Events.TierChanged, -1, zoneId, state.tier, state.heat, state.activeFaction)
                end
            end
        end
    end
end)

RegisterNetEvent("aln_hostiles:zoneCleared", function(zoneId)
    local state = ZoneState.zones[zoneId]
    if not state then return end
    ZoneState.SetCooldown(zoneId, state.activeFaction)
    TriggerEvent(Constants.Events.ZoneCleared, zoneId)
end)

