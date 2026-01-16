-- Redirect qb-clothing events to your real clothing script

RegisterNetEvent('qb-clothing:client:openMenu', function()
    -- Example: replace with wspdoogie export/event
    TriggerEvent('wsp-clothing:openMenu')
end)

RegisterNetEvent('qb-clothing:client:openOutfitMenu', function()
    TriggerEvent('wsp-clothing:openOutfitMenu')
end)
