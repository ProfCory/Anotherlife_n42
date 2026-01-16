-- bridge-gabz: optional DB persistence (oxmysql)
--
-- Schema (optional):
-- CREATE TABLE IF NOT EXISTS bridge_gabz_state (
--   id VARCHAR(64) NOT NULL PRIMARY KEY,
--   closed_until BIGINT NOT NULL DEFAULT 0
-- );

BG_DB = {}

local function oxmysqlReady()
  return BG_CFG.Integrations.UseOxMySQL
    and GetResourceState(BG_CFG.Integrations.OxMySQLResource) == 'started'
end

function BG_DB.init()
  -- No-op: create table manually if you enable DB persistence.
end

function BG_DB.loadAll(cb)
  if not oxmysqlReady() then
    cb({})
    return
  end

  exports.oxmysql:query('SELECT id, closed_until FROM bridge_gabz_state', {}, function(rows)
    local out = {}
    for _, r in ipairs(rows or {}) do
      out[r.id] = tonumber(r.closed_until) or 0
    end
    cb(out)
  end)
end

function BG_DB.saveClosedUntil(id, closedUntil)
  if not oxmysqlReady() then return end

  exports.oxmysql:insert(
    'INSERT INTO bridge_gabz_state (id, closed_until) VALUES (?, ?) ON DUPLICATE KEY UPDATE closed_until = VALUES(closed_until)',
    { id, math.floor(closedUntil or 0) }
  )
end
