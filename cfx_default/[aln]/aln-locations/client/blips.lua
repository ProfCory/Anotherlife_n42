ALN = ALN or {}

local created = {}
local createdClusters = {}

local function addBlipAt(coords, sprite, color, scale, shortRange, name)
  local b = AddBlipForCoord(coords.x, coords.y, coords.z)
  SetBlipSprite(b, sprite or 1)
  SetBlipColour(b, color or 0)
  SetBlipScale(b, scale or 0.75)
  SetBlipAsShortRange(b, shortRange == true)
  BeginTextCommandSetBlipName('STRING')
  AddTextComponentString(name or 'Location')
  EndTextCommandSetBlipName(b)
  return b
end

local function destroyAll()
  for _, b in pairs(created) do
    if DoesBlipExist(b) then RemoveBlip(b) end
  end
  for _, b in pairs(createdClusters) do
    if DoesBlipExist(b) then RemoveBlip(b) end
  end
  created, createdClusters = {}, {}
end

local function buildClusters(registry)
  -- clusterKey -> { ids..., centroid, representative blip config }
  local clusters = {}

  for id, loc in pairs(registry) do
    if loc.blip and loc.clusterKey and loc.clusterKey ~= '' then
      local c = clusters[loc.clusterKey]
      if not c then
        c = { ids = {}, sumX=0, sumY=0, sumZ=0, rep = loc }
        clusters[loc.clusterKey] = c
      end
      c.ids[#c.ids+1] = id
      c.sumX = c.sumX + loc.coords.x
      c.sumY = c.sumY + loc.coords.y
      c.sumZ = c.sumZ + loc.coords.z
    end
  end

  for key, c in pairs(clusters) do
    local n = #c.ids
    c.centroid = vector3(c.sumX/n, c.sumY/n, c.sumZ/n)
  end

  return clusters
end

function ALN_Locations_SpawnBlips()
  destroyAll()

  if not (Config and Config.Locations and Config.Locations.EnableBlips) then return end
  local registry = exports['aln-locations']:GetAll()
  if not registry then return end

  local clusters = {}
  if Config.Locations.Cluster and Config.Locations.Cluster.Enabled then
    clusters = buildClusters(registry)
  end

  -- Spawn cluster blips first
  for key, c in pairs(clusters) do
    local rep = c.rep
    local b = addBlipAt(
      c.centroid,
      rep.blip.sprite,
      rep.blip.color,
      rep.blip.scale,
      rep.blip.shortRange,
      (rep.blip.name or rep.label) .. (' (%d)'):format(#c.ids)
    )
    createdClusters[key] = b
  end

  -- Spawn non-cluster blips
  for id, loc in pairs(registry) do
    if loc.blip and (not loc.clusterKey or loc.clusterKey == '' or not createdClusters[loc.clusterKey]) then
      local b = addBlipAt(
        loc.coords,
        loc.blip.sprite,
        loc.blip.color,
        loc.blip.scale,
        loc.blip.shortRange,
        loc.blip.name or loc.label
      )
      created[id] = b
    end
  end
end
