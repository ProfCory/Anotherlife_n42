ALN = ALN or {}
ALN.DB = ALN.DB or {}

local ready = false

local function setReady()
  if ready then return end
  ready = true
  ALN.Log.Info('db.ready', {})
end

exports('IsReady', function() return ready end)

AddEventHandler('onResourceStart', function(resName)
  if resName ~= GetCurrentResourceName() then return end

  exports['aln-core']:OnReady(function()
    ALN.Log.Info('db.start', { adapter = 'oxmysql' })

    -- Run migrations at startup
    local ok = ALN.DB.RunMigrations()
    if ok then
      setReady()
    end
  end)
end)

-- Simple dev commands (ACE gating will be done in aln-admin; keep these harmless)
RegisterCommand('aln_db_ping', function(src)
  if src ~= 0 then
    TriggerClientEvent('chat:addMessage', src, { args = { '^1ALN', 'db ping only from server console for now' } })
    return
  end

  local v = ALN.DB.Scalar('SELECT 1', {})
  print('[ALN3] db ping => ' .. tostring(v))
end, true)

RegisterCommand('aln_db_migrations', function(src)
  if src ~= 0 then return end
  local t = (Config and Config.DB and Config.DB.MigrationTable) or 'aln3_schema_migrations'
  local rows = ALN.DB.Query(('SELECT * FROM `%s` ORDER BY id ASC'):format(t), {})
  print('[ALN3] Applied migrations:')
  for _, r in ipairs(rows or {}) do
    print(('  %d  %s  %s'):format(tonumber(r.id), r.name, r.applied_at))
  end
end, true)
