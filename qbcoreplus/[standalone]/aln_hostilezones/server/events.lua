local Constants = Constants

RegisterNetEvent("aln_hostiles:addHeat", function(zoneId, amount, incidentType)
    ZoneState.AddHeat(zoneId, amount)
    TriggerEvent(Constants.Events.Incident, zoneId, incidentType, amount)
end)
