Config = Config or {}

Config.ATM = {
  Debug = true,

  -- location tags to pull ATM spots from aln-locations
  LocationTag = 'atm',

  -- interaction distance
  UseDist = 1.8,

  -- requires ATM card item
  CardItem = 'atm_card',
  CardCost = 100,

  -- transfer limits per action (anti-fatfinger)
  MaxDeposit = 50000,
  MaxWithdraw = 50000,
}
