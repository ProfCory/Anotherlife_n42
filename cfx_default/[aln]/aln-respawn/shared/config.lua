Config = Config or {}

Config.Respawn = {
  Debug = true,

  -- base respawn timer in seconds
  TimerSeconds = 25,

  -- additional timer per wanted star (minor stress later; here just time)
  ExtraSecondsPerStar = 8,

  -- if true, clear wanted on respawn
  ClearWantedOnRespawn = true,

  -- endpoint selection tags
  Tags = {
    police = 'service.police',
    hospital = 'service.medical',
    fire = 'service.fire',
  },

  -- Rules (v0):
  -- - wanted >= 1 => police
  -- - otherwise => hospital
  -- Later: suicide => fire, killed by peds => hospital, etc.
}
