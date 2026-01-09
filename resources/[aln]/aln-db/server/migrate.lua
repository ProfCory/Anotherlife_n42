ALN = ALN or {}
ALN.DB = ALN.DB or {}

local migrationTable = (Config and Config.DB and Config.DB.MigrationTable) or 'aln3_schema_migrations'

local function readFile(path)
  local content = LoadResourceFile(GetCurrentResourceName(), path)
  return content
end

local function listMigrations()
  -- We cannot reliably list directory contents at runtime in FiveM.
  -- So we maintain an explicit ordered list here. Additive only.
  return {
    { id = 1, name = '0001_init.sql', path = 'migrations/0001_init.sql' },
    -- Add next migrations here, e.g.:
    -- { id = 2, name = '0002_characters.sql', path = 'migrations/0002_characters.sql' },
  }
end

local function ensureMigrationTable()
  local q = ([[
    CREATE TABLE IF NOT EXISTS `%s` (
      `id` INT NOT NULL PRIMARY KEY,
      `name` VARCHAR(128) NOT NULL,
      `applied_at` VARCHAR(32) NOT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]]):format(migrationTable)

  ALN.DB.Query(q, {})
end

local function getApplied()
  local rows = ALN.DB.Query(('SELECT id, name, applied_at FROM `%s` ORDER BY id ASC'):format(migrationTable), {})
  local applied = {}
  for _, r in ipairs(rows or {}) do
    applied[tonumber(r.id)] = r
  end
  return applied
end

local function markApplied(id, name)
  ALN.DB.Insert(
    ('INSERT INTO `%s` (id, name, applied_at) VALUES (?, ?, ?)'):format(migrationTable),
    { id, name, ALN.DB._nowIso() }
  )
end

local function runSql(sqlText, name)
  -- oxmysql can run multi-statement if enabled in your connection string.
  -- We keep migrations compatible by allowing multiple statements separated by semicolons.
  -- If your server disallows multi statements, keep each migration to a single statement per file.
  local ok, err = pcall(function()
    exports.oxmysql:execute(sqlText, {})
  end)
  if not ok then
    ALN.Log.Error('db.migration_failed', { name = name, err = tostring(err) })
    return false
  end
  return true
end

function ALN.DB.RunMigrations()
  ensureMigrationTable()

  local applied = getApplied()
  local migrations = listMigrations()

  local appliedCount = 0

  for _, m in ipairs(migrations) do
    if not applied[m.id] then
      local sql = readFile(m.path)
      if not sql or sql == '' then
        ALN.Log.Error('db.migration_missing_file', { id = m.id, name = m.name, path = m.path })
        if Config.DB.FailOnMigrationError then error('Migration file missing: ' .. m.path) end
        return false
      end

      if Config.DB.LogMigrations then
        ALN.Log.Info('db.migration_apply', { id = m.id, name = m.name })
      end

      local ok = runSql(sql, m.name)
      if not ok then
        if Config.DB.FailOnMigrationError then
          error('Migration failed: ' .. m.name)
        end
        return false
      end

      markApplied(m.id, m.name)
      appliedCount = appliedCount + 1
    end
  end

  ALN.Log.Info('db.migrations_done', { appliedNow = appliedCount, totalKnown = #migrations })
  TriggerEvent(ALN.DB.Events.Ready)
  return true
end

exports('RunMigrations', function() return ALN.DB.RunMigrations() end)
