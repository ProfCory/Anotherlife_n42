-- bridge-gabz: Ped model and scenario pools
-- Keep this file standalone; no framework dependencies.

BG_MODELS = {
  staff = {
    -- Medical
    's_m_m_doctor_01',
    's_f_y_scrubs_01',
    's_m_m_paramedic_01',

    -- Shops / service
    's_m_m_autoshop_01',
    's_f_m_shop_high',
    's_f_y_shop_low',

    -- Security / public
    's_m_m_highsec_01',
    's_m_y_cop_01', -- used rarely; only for ambience unless you remove it

    -- Hospitality
    's_m_m_linecook',
    's_f_y_waitress_01',
    's_m_y_valet_01'
  },

  visitors = {
    'a_m_y_business_01',
    'a_f_y_business_01',
    'a_m_m_business_01',
    'a_m_y_bevhills_01',
    'a_f_y_bevhills_01',
    'a_m_y_hipster_01',
    'a_f_y_hipster_01',
    'a_m_y_tourist_01',
    'a_f_y_tourist_01',
    'a_m_m_skidrow_01',
    'a_f_m_skidrow_01'
  }
}

BG_SCENARIOS = {
  staff = {
    'WORLD_HUMAN_CLIPBOARD',
    'WORLD_HUMAN_STAND_IMPATIENT',
    'WORLD_HUMAN_SMOKING',
    'WORLD_HUMAN_AA_COFFEE',
    'WORLD_HUMAN_GUARD_STAND',
    'WORLD_HUMAN_DRUG_DEALER_HARD' -- can be removed; used for "idle" posture
  },

  visitors = {
    'WORLD_HUMAN_STAND_IMPATIENT',
    'WORLD_HUMAN_AA_COFFEE',
    'WORLD_HUMAN_SMOKING',
    'WORLD_HUMAN_TOURIST_MAP',
    'WORLD_HUMAN_STAND_MOBILE',
    'WORLD_HUMAN_WINDOW_SHOP_BROWSE'
  },

  cower = {
    'CODE_HUMAN_COWER',
    'WORLD_HUMAN_BUM_SLUMPED'
  }
}
