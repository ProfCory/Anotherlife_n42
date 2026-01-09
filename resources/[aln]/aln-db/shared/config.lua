Config = Config or {}

Config.DB = {
  Debug = true,

  -- Table to record migration versions
  MigrationTable = 'aln3_schema_migrations',

  -- If true, resource will fail hard (error) when a migration fails.
  FailOnMigrationError = true,

  -- If true, log each migration applied.
  LogMigrations = true,
}
