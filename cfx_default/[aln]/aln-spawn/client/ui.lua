ALN = ALN or {}
ALN.SpawnUI = ALN.SpawnUI or {}

local function drawCenter(text)
  SetTextFont(4)
  SetTextScale(0.5, 0.5)
  SetTextColour(255,255,255,220)
  SetTextCentre(true)
  SetTextOutline()
  BeginTextCommandDisplayText('STRING')
  AddTextComponentSubstringPlayerName(text)
  EndTextCommandDisplayText(0.5, 0.45)
end

function ALN.SpawnUI.Pick(options, title)
  local idx = 1
  local done = false

  while not done do
    DisableAllControlActions(0)
    EnableControlAction(0, 172, true) -- up
    EnableControlAction(0, 173, true) -- down
    EnableControlAction(0, 191, true) -- enter
    EnableControlAction(0, 202, true) -- back

    if IsControlJustReleased(0, 172) then idx = idx - 1 end
    if IsControlJustReleased(0, 173) then idx = idx + 1 end
    if idx < 1 then idx = #options end
    if idx > #options then idx = 1 end

    local o = options[idx]
    drawCenter(('%s\n\n~y~%s~s~\n\n~c~Up/Down to change • Enter to select~s~'):format(title, o.label))

    if IsControlJustReleased(0, 191) then
      done = true
      return o
    end

    Wait(0)
  end
end
