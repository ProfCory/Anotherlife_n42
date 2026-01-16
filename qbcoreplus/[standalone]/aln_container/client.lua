local insideContainer = false
local containerStash, containerCooler

-- ENTER (called by radial menu)
RegisterNetEvent('aln_container:client:Enter', function()
    if insideContainer then return end
    TriggerServerEvent('aln_container:server:Load')
end)

-- AFTER LOAD
RegisterNetEvent('aln_container:client:Loaded', function(stash, cooler)
    containerStash = stash
    containerCooler = cooler

    exports['k4mb1-startershells']:CreateShell({
        shell = 'container_shell',
        offset = vector3(0.0, 0.0, -1.0),
        exit = vector3(0.0, -2.2, 1.0)
    }, function()
        insideContainer = true
        RegisterExitTarget()
    end)
end)

-- EXIT ZONE (qb-target eye)
function RegisterExitTarget()
    exports['qb-target']:AddBoxZone(
        'aln_container_exit',
        vector3(0.0, -2.2, 1.0),
        1.2, 1.2,
        {
            name = 'aln_container_exit',
            heading = 0,
            minZ = 0.0,
            maxZ = 2.0
        },
        {
            options = {
                {
                    label = 'Leave Container (Save)',
                    icon = 'fas fa-box-archive',
                    action = function()
                        LeaveContainer(true)
                    end
                },
                {
                    label = 'Leave + Take All',
                    icon = 'fas fa-person-walking',
                    action = function()
                        LeaveContainer(false)
                    end
                }
            },
            distance = 1.5
        }
    )
end

-- LEAVE
function LeaveContainer(save)
    exports['qb-target']:RemoveZone('aln_container_exit')

    if not save then
        TriggerServerEvent('qb-inventory:server:ClearStash', containerStash)
        TriggerServerEvent('qb-inventory:server:ClearStash', containerCooler)
        TriggerServerEvent('aln_container:server:Delete')
    end

    insideContainer = false
    exports['k4mb1-startershells']:DespawnShell()
end
