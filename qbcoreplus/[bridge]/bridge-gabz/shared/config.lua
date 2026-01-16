-- bridge-gabz: Configuration
--
-- Design goals:
-- 1) Standalone: runs without QBCore.
-- 2) Optional integrations: qb-target, oxmysql.
-- 3) "Drop in" friendly: auto-enables location packs if matching resources are started.
-- 4) Config-first: locations are presets + an editable JSON file.

BG_CFG = {
  Debug = false,

  -- If true, enables /bg_* builder commands to create/edit locations and write to data/locations.json
  EnableBuilderCommands = true,

  -- Core tuning
  TickRateMs = 750,          -- main loop check interval when inside any active zone
  SpawnGraceSeconds = 15,    -- wait before despawning after leaving a zone
  MaxPedsPerLocation = 10,   -- hard cap (staff + visitors)

  Staff = {
    DefaultCount = 2,
    RespawnSeconds = 60
  },

  Visitors = {
    Enabled = true,
    DefaultCount = 3,
    WaveEverySeconds = 180,
    MinStaySeconds = 45,
    MaxStaySeconds = 140
  },

  -- Violence/heat detection
  Cleanup = {
    Enabled = true,
    -- If shots/explosions/ped damage are detected inside a location zone, mark it "closed" for a while
    CloseForSeconds = 600,
    -- While closed: remove visitors, keep minimal staff (optional), and disable interactions
    KeepStaffWhenClosed = true,
    StaffWhenClosedCount = 1
  },

  -- Integrations (optional). The script checks if these resources are running.
  Integrations = {
    UseQbTarget = true,
    QbTargetResource = 'qb-target',

    UseOxMySQL = false, -- set true only if you want persistence across restarts
    OxMySQLResource = 'oxmysql'
  },

  -- Interaction tuning (qb-target only)
  Interactions = {
    Enabled = true,
    TalkLabel = 'Talk',
    RobLabel = 'Rob',

    -- If true, rob action triggers ped flee + location cooldown.
    RobTriggersCooldown = true
  }
}

-- Default location presets.
-- NOTE: GABZ interiors are not standardized on spawn points, so presets are intentionally minimal.
-- Use builder commands to calibrate exact points for YOUR map pack.

BG_DEFAULT_LOCATIONS = {
  -- Examples (disabled by default). Enable them via the builder or by setting enabled=true.
  -- These are placed at vanilla-ish landmark coords and may need adjusting for your exact gabz pack.

  {
    id = 'pillbox',
    label = 'Pillbox Hospital',
    enabled = false,
    enable_if_resource = { 'gabz-pillbox_hospital_v2', 'cfx-gabz-pillbox_hospital_v2' },
    zone = { type = 'sphere', center = vec3(307.7, -1433.4, 29.9), radius = 80.0 },
    staff = {
      { pos = vec4(307.7, -1433.4, 29.9, 50.0), model = 's_f_y_scrubs_01', scenario = 'WORLD_HUMAN_CLIPBOARD' },
      { pos = vec4(312.0, -1437.0, 29.9, 230.0), model = 's_m_m_doctor_01', scenario = 'WORLD_HUMAN_STAND_IMPATIENT' }
    },
    visitors = {
      entry = vec4(298.0, -1440.0, 29.9, 0.0),
      exit  = vec4(298.0, -1440.0, 29.9, 0.0),
      roam = {
        { pos = vec4(309.0, -1436.0, 29.9, 0.0), scenario = 'WORLD_HUMAN_AA_COFFEE' },
        { pos = vec4(316.0, -1435.0, 29.9, 0.0), scenario = 'WORLD_HUMAN_STAND_MOBILE' }
      }
    }
  },

  {
    id = 'mrpd',
    label = 'MRPD',
    enabled = false,
    enable_if_resource = { 'cfx-gabz-mrpd', 'gabz-mrpd', 'cfx-gabz-pd' },
    zone = { type = 'sphere', center = vec3(441.2, -981.9, 30.7), radius = 90.0 },
    staff = {
      { pos = vec4(441.2, -981.9, 30.7, 90.0), model = 's_m_m_highsec_01', scenario = 'WORLD_HUMAN_GUARD_STAND' }
    },
    visitors = {
      entry = vec4(441.0, -982.0, 30.7, 0.0),
      exit  = vec4(441.0, -982.0, 30.7, 0.0),
      roam = {
        { pos = vec4(444.5, -989.5, 30.7, 0.0), scenario = 'WORLD_HUMAN_STAND_IMPATIENT' }
      }
    }
  },

  {
    id = 'bennys',
    label = "Benny's", 
    enabled = false,
    enable_if_resource = { 'cfx-gabz-bennys', 'gabz-bennys' },
    zone = { type = 'sphere', center = vec3(-205.7, -1311.0, 31.3), radius = 70.0 },
    staff = {
      { pos = vec4(-205.7, -1311.0, 31.3, 180.0), model = 's_m_m_autoshop_01', scenario = 'WORLD_HUMAN_CLIPBOARD' }
    },
    visitors = {
      entry = vec4(-191.0, -1322.0, 31.3, 0.0),
      exit  = vec4(-191.0, -1322.0, 31.3, 0.0),
      roam = {
        { pos = vec4(-205.0, -1315.0, 31.3, 0.0), scenario = 'WORLD_HUMAN_WINDOW_SHOP_BROWSE' }
      }
    }
  }
}
