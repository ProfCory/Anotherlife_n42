ALN = ALN or {}

function ALN_WorldPop_ApplyScenarioToggles()
  local s = Config.WorldPop.Scenarios or {}

  -- Scenario groups
  for _, group in ipairs(s.DisableGroups or {}) do
    -- false disables the group
    SetScenarioGroupEnabled(group, false)
  end

  -- Scenario types
  for _, typ in ipairs(s.DisableTypes or {}) do
    SetScenarioTypeEnabled(typ, false)
  end

  if Config.WorldPop.Debug then
    ALN.Log.Info('worldpop.scenarios_applied', {
      disabledGroups = #(s.DisableGroups or {}),
      disabledTypes  = #(s.DisableTypes or {}),
    })
  end
end
