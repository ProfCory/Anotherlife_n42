-- aln_hostilezones/client/k4mb1_adapter.lua
-- Adapter for k4mb1-startershells
-- Spawns interiors when hostilezones says they are available

K4MB1 = {}
K4MB1.active = nil

local RESOURCE = Config.Integrations.K4mb1Startershells.resourceName

---------------------------------------------------------
-- Safety check
---------------------------------------------------------
local function isK4mb1Running()
    return GetResourceState(RESOURCE) == "started"
end

---------------------------------------------------------
-- Spawn shell
---------------------------------------------------------
function K4MB1.EnterShell(shellId)
    if not isK4mb1Running() then
        print("[aln_hostilezones] k4mb1 not running; cannot spawn shell")
        return
    end

    local shell = Config.Interiors.shells[shellId]
    if not shell then return end

    -- k4mb1 uses exports to create shells
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    local interior = exports[RESOURCE]:CreateShell({
        shell = shell.model,
        offset = vec3(0.0, 0.0, 0.0),
        coords = pos,
        heading = GetEntityHeading(ped)
    })

    if interior then
        K4MB1.active = interior
    end
end

---------------------------------------------------------
-- Exit shell
---------------------------------------------------------
function K4MB1.ExitShell(zoneId, shellId)
    if K4MB1.active and isK4mb1Running() then
        exports[RESOURCE]:DeleteShell(K4MB1.active)
        K4MB1.active = nil

        TriggerEvent(Constants.Events.InteriorCleared, zoneId, shellId)
    end
end

---------------------------------------------------------
-- Listen for hostilezones events
---------------------------------------------------------
AddEventHandler(Constants.Events.InteriorEntered, function(zoneId, shellId)
    K4MB1.EnterShell(shellId)

    -- simple exit key (BACKSPACE) for MVP
    CreateThread(function()
        while K4MB1.active do
            Wait(0)
            if IsControlJustPressed(0, 177) then
                K4MB1.ExitShell(zoneId, shellId)
                return
            end
        end
    end)
end)
