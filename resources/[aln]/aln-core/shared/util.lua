ALN = ALN or {}

ALN.Util = ALN.Util or {}

function ALN.Util.Clamp(n, a, b)
  if n < a then return a end
  if n > b then return b end
  return n
end

function ALN.Util.NowUnix()
  -- seconds since epoch
  return os.time(os.date("!*t"))
end

function ALN.Util.SafeJsonEncode(obj)
  local ok, json = pcall(function()
    return json.encode(obj)
  end)
  if ok then return json end
  return '{"_encode_error":true}'
end

function ALN.Util.TableShallowCopy(t)
  local out = {}
  for k, v in pairs(t or {}) do out[k] = v end
  return out
end
