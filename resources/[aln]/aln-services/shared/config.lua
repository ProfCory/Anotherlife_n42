Config = Config or {}

Config.Services = {
  Debug = true,

  Cooldowns = {
    police = 90,
    ems    = 90,
    fire   = 120,
    taxi   = 30,
  },

  Enabled = {
    police = true,
    ems    = true,
    fire   = true,
    taxi   = true,
  },

  -- Use nearest station from aln-locations tags
  Tags = {
    police = 'service.police',
    ems    = 'service.medical',
    fire   = 'service.fire',
  },

  -- Taxi pricing
  Taxi = {
    BaseFee = 40,
    PerKm = 18,          -- charged on dropoff based on route distance estimate (client computed)
    MaxFee = 2500,
    PayAccount = 'cash', -- cash preferred
    AllowBankFallback = true,
  },

  -- Spawn behavior
  Spawn = {
    -- distance from player to try to spawn service unit (client safe-spawn checks)
    MinFromPlayer = 80.0,
    MaxFromPlayer = 160.0,

    -- how long units remain after arriving
    DwellSeconds = 45,
  },
}
