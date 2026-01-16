Config = Config or {}
Config.Minigame = Config.Minigame or {}

Config.Minigame.Debug = true

Config.Minigame.SuccessXpPerDC = 10
Config.Minigame.FailXpPerDC = 0

Config.Minigame.ToolBreak = {
  Enabled = true,
  Base = 10,
  PerDc = 2,
  Min = 10,
  Max = 40,
  Nat1BreakChance = 100
}

Config.Minigame.CritFailWantedStars = 2
Config.Minigame.SpawnCopsOnNat1 = true -- (v0: just returns “wantedAdd”; cops spawning will be in aln-services later)

Config.Minigame.WantedDisThreshold = 1

Config.Minigame.Actions = {
  ['vehicle.entry.lockpick'] = { label='Lockpick Vehicle Door', baseDC=12, requiresTool=false, toolGivesAdv=true },
  ['vehicle.entry.smash']    = { label='Smash Vehicle Window',  baseDC=11, requiresTool=false, toolGivesAdv=false },
  ['vehicle.hotwire']        = { label='Hotwire Vehicle',       baseDC=14, requiresTool=false, toolGivesAdv=true },
  ['hack.panel']             = { label='Hack Panel',            baseDC=15, requiresTool=true,  toolGivesAdv=true },
}

Config.Minigame.VehicleClassDC = {
  [0]=12,[1]=12,[2]=13,[3]=12,[4]=13,[5]=14,[6]=15,[7]=18,[8]=13,[9]=13,[10]=12,[11]=12,[12]=12,[13]=10,[14]=13,[15]=15,[16]=15,[17]=12,[18]=18,[19]=18,[20]=16,[21]=15,[22]=12,
}

Config.Minigame.ValueBumps = {
  { min = 20000,  add = 1 },
  { min = 60000,  add = 2 },
  { min = 150000, add = 3 },
}
