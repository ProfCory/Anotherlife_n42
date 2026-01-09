Config = Config or {}

Config.Locations = {
  Debug = true,
  StrictValidation = true,

  -- Blips are optional; registry can be used headlessly.
  EnableBlips = true,

  -- Default blip settings
  DefaultBlipScale = 0.75,
  DefaultShortRange = true,

  -- Clustering: if multiple locations share the same clusterKey,
  -- we will show ONE blip for the cluster, and hide individual blips.
  Cluster = {
    Enabled = true,
    -- If a cluster has >3 points very close, still only one blip.
    -- (Your rule: "no more than 1 blip for 3 or less in the same basic space")
    -- We'll always show one per clusterKey.
  },
}
