Shared = {}

Shared.RandomName = function()
  local first = { "Alex", "Riley", "Morgan", "Casey", "Jordan", "Sam", "Taylor", "Cameron", "Quinn", "Devin" }
  local last  = { "Hayes", "Cole", "Bishop", "Reed", "Cruz", "Brooks", "Santos", "Price", "Grant", "Miller" }
  return ("%s %s"):format(first[math.random(#first)], last[math.random(#last)])
end

Shared.RandomHangout = function()
  return Config.Hangouts[math.random(#Config.Hangouts)]
end

Shared.ScaleForCrewCount = function(count)
  if count >= 5 then return Config.ScaleAt5 end
  if count >= 3 then return Config.ScaleAt3 end
  return 1.0
end
