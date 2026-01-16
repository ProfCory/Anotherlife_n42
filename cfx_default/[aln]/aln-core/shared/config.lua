Config = Config or {}

-- Core debug toggles (do NOT spam by default)
Config.Core = {
  Debug = true,

  -- How long other resources should wait for core readiness before giving up (ms).
  ReadyWaitTimeoutMs = 15000,

  -- Preferred identifier order for "player key"
  -- license is most stable for FiveM server identity
  IdentifierPriority = { 'license', 'fivem', 'discord', 'steam', 'ip' },
}
