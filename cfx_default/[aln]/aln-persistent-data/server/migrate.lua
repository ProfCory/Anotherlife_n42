ALN = ALN or {}
ALN.Persistent = ALN.Persistent or {}

local migrationTable = (Config.Persistent and Config.Persistent.MigrationTable) or 'aln3_migrations_persistent'

local function readFile(path)
  return LoadResourceFile(GetCurrentResourceName(), path)
end

local function ensureTable()
  -- included in 1001 file, but safe to ensure table exists
  exports['aln-db']:Query(([[
    CREATE TABLE IF NOT EXISTS `%s` (
      `id` INT NOT NULL PRIMARY KEY,
      `name` VARCHAR(128) NOT NULL,
      `applied_at` VARCHAR(32) NOT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]]):format(migrationTable), {})
end

local function appliedMap()
  local rows = exports['aln-db']:Query(('SELECT id FROM `%s` ORDER BY id ASC'):format(migrationTable), {}) or {}
  local m = {}
  for _, r in ipairs(rows) do m[tonumber(r.id)] = true end
  return m
end

local function mark(id, name)
  exports['aln-db']:Insert(
    ('INSERT INTO `%s` (id, name, applied_at) VALUES (?, ?, ?)'):format(migrationTable),
    { id, name, ALN.Persistent.NowIso() }
  )
end

local function runSql(sqlText, name)
  local ok, err = pcall(function()
    exports.oxmysql:execute(sqlText, {})
  end)
  if not ok then
    ALN.Log.Error('pdata.migration_failed', { name = name, err = tostring(err) })
    return false
  end
  return true
end

local function list()
  return {
    { id = 1001, name = '1001_init.sql', path = 'migrations/1001_init.sql' },
	{ id = 1002, name = '1002_onboarding.sql', path = 'migrations/1002_onboarding.sql' },
  }
end

function ALN.Persistent.RunMigrations()
  ensureTable()
  local applied = appliedMap()
  local migrations = list()
  local appliedNow = 0

  for _, m in ipairs(migrations) do
    if not applied[m.id] then
      local sql = readFile(m.path)
      if not sql or sql == '' then error('[aln-persistent-data] missing migration file ' .. m.path) end
      ALN.Log.Info('pdata.migration_apply', { id = m.id, name = m.name })
      local ok = runSql(sql, m.name)
      if not ok then error('[aln-persistent-data] migration failed ' .. m.name) end
      mark(m.id, m.name)
      appliedNow = appliedNow + 1
    end
  end

  ALN.Log.Info('pdata.migrations_done', { appliedNow = appliedNow, totalKnown = #migrations })
  return true
end
