local QBCore = exports['qb-core']:GetCoreObject()

local AllowedKeys = {}
for _, k in pairs(Config.StatusKeys) do AllowedKeys[k] = true end

local function clamp(n)
  n = tonumber(n) or 0
  if n < Config.MinValue then return Config.MinValue end
  if n > Config.MaxValue then return Config.MaxValue end
  return n
end

-- Initialize metadata keys if missing (on player load)
AddEventHandler('QBCore:Server:OnPlayerLoaded', function(src)
  local Player = QBCore.Functions.GetPlayer(src)
  if not Player then return end

  local md = Player.PlayerData.metadata or {}
  local changed = false

  for _, key in pairs(Config.StatusKeys) do
    if md[key] == nil then
      md[key] = Config.DefaultValue
      changed = true
    end
  end

  if md['aln_status_ui'] == nil then
    md['aln_status_ui'] = { x = Config.UI.DefaultPos.x, y = Config.UI.DefaultPos.y }
    changed = true
  end

  if changed then
    for k, v in pairs(md) do
      Player.Functions.SetMetaData(k, v)
    end
  end
end)

-- Client requests current status + ui pos (single round trip)
QBCore.Functions.CreateCallback('aln_status:server:GetAll', function(source, cb)
  local Player = QBCore.Functions.GetPlayer(source)
  if not Player then cb(nil) return end

  local md = Player.PlayerData.metadata or {}
  cb({
    fatigue = clamp(md[Config.StatusKeys.fatigue] or 0),
    drunk   = clamp(md[Config.StatusKeys.drunk] or 0),
    stoned  = clamp(md[Config.StatusKeys.stoned] or 0),
    ui      = md['aln_status_ui'] or { x = Config.UI.DefaultPos.x, y = Config.UI.DefaultPos.y }
  })
end)

-- Server-side setter (authoritative persistence)
RegisterNetEvent('aln_status:server:SetStatus', function(key, value)
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  if not Player then return end

  if not AllowedKeys[key] then return end
  value = clamp(value)

  Player.Functions.SetMetaData(key, value)
end)

RegisterNetEvent('aln_status:server:SaveUI', function(pos)
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  if not Player then return end

  if type(pos) ~= 'table' then return end
  local x = tonumber(pos.x)
  local y = tonumber(pos.y)
  if not x or not y then return end

  -- keep normalized 0..1
  if x < 0 then x = 0 end
  if x > 1 then x = 1 end
  if y < 0 then y = 0 end
  if y > 1 then y = 1 end

  Player.Functions.SetMetaData('aln_status_ui', { x = x, y = y })
end)
