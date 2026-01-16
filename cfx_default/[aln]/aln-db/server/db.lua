ALN = ALN or {}
ALN.DB = ALN.DB or {}

-- oxmysql exports (async/await style)
local MySQL = exports.oxmysql

-- Simple wrappers that always return values and log errors.
-- Prefer these wrappers everywhere to keep error format consistent.

local function _err(where, err, meta)
  ALN.Log.Error('db.error', {
    where = where,
    err = tostring(err),
    meta = meta or {}
  })
end

function ALN.DB.Scalar(query, params)
  local ok, res = pcall(function()
    return MySQL:scalar_async(query, params or {})
  end)
  if not ok then _err('scalar', res, { query = query }); return nil end
  return res
end

function ALN.DB.Single(query, params)
  local ok, res = pcall(function()
    return MySQL:single_async(query, params or {})
  end)
  if not ok then _err('single', res, { query = query }); return nil end
  return res
end

function ALN.DB.Query(query, params)
  local ok, res = pcall(function()
    return MySQL:query_async(query, params or {})
  end)
  if not ok then _err('query', res, { query = query }); return nil end
  return res
end

function ALN.DB.Insert(query, params)
  local ok, res = pcall(function()
    return MySQL:insert_async(query, params or {})
  end)
  if not ok then _err('insert', res, { query = query }); return nil end
  return res
end

function ALN.DB.Update(query, params)
  local ok, res = pcall(function()
    return MySQL:update_async(query, params or {})
  end)
  if not ok then _err('update', res, { query = query }); return nil end
  return res
end

-- Transaction helper
-- stmts: { {query="...", params={}}, ... }
function ALN.DB.Transaction(stmts)
  local ok, res = pcall(function()
    return MySQL:transaction_async(stmts or {})
  end)
  if not ok then _err('transaction', res, { count = #(stmts or {}) }); return false end
  return res == true
end

exports('Scalar', function(q, p) return ALN.DB.Scalar(q, p) end)
exports('Single', function(q, p) return ALN.DB.Single(q, p) end)
exports('Query',  function(q, p) return ALN.DB.Query(q, p)  end)
exports('Insert', function(q, p) return ALN.DB.Insert(q, p) end)
exports('Update', function(q, p) return ALN.DB.Update(q, p) end)
exports('Transaction', function(stmts) return ALN.DB.Transaction(stmts) end)
