local Persist = {}

local resourceName = GetCurrentResourceName()
local fileName = "pals.json"

local function readAll()
  local raw = LoadResourceFile(resourceName, fileName)
  if not raw or raw == "" then return {} end
  local ok, data = pcall(json.decode, raw)
  if not ok or type(data) ~= "table" then return {} end
  return data
end

local function writeAll(data)
  SaveResourceFile(resourceName, fileName, json.encode(data, { indent = true }), -1)
end

function Persist.LoadPlayer(key)
  local data = readAll()
  return data[key] or { pals = {}, meta = { lastUpdated = os.time() } }
end

function Persist.SavePlayer(key, payload)
  local data = readAll()
  payload.meta = payload.meta or {}
  payload.meta.lastUpdated = os.time()
  data[key] = payload
  writeAll(data)
end

return Persist
