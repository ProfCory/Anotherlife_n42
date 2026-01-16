CREATE TABLE IF NOT EXISTS `aln3_migrations_persistent` (
  `id` INT NOT NULL PRIMARY KEY,
  `name` VARCHAR(128) NOT NULL,
  `applied_at` VARCHAR(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `aln3_players` (
  `owner_key` VARCHAR(96) NOT NULL PRIMARY KEY,
  `active_slot` TINYINT NOT NULL DEFAULT 1,
  `active_char_id` BIGINT NULL,
  `updated_at` VARCHAR(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `aln3_characters` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `owner_key` VARCHAR(96) NOT NULL,
  `slot` TINYINT NOT NULL,

  `name` VARCHAR(64) NULL,
  `model` VARCHAR(64) NOT NULL,

  -- JSON blobs for v0 (split later additively)
  `appearance_json` LONGTEXT NULL,
  `clothing_json` LONGTEXT NULL,
  `outfits_json` LONGTEXT NULL,
  `licenses_json` LONGTEXT NULL,
  `housing_json` LONGTEXT NULL,

  -- Favorites
  `fav_vehicle_plate` VARCHAR(16) NULL,
  `fav_outfit_key` VARCHAR(64) NULL,

  -- Money (authoritative storage target)
  `money_cash` INT NOT NULL DEFAULT 0,
  `money_bank` INT NOT NULL DEFAULT 0,
  `money_dirty` INT NOT NULL DEFAULT 0,

  -- Last known position
  `last_x` DOUBLE NOT NULL DEFAULT 0,
  `last_y` DOUBLE NOT NULL DEFAULT 0,
  `last_z` DOUBLE NOT NULL DEFAULT 0,
  `last_h` DOUBLE NOT NULL DEFAULT 0,

  -- Session lifecycle
  `session_id` VARCHAR(64) NULL,
  `last_login_at` VARCHAR(32) NULL,
  `last_logout_at` VARCHAR(32) NULL,
  `created_at` VARCHAR(32) NOT NULL,
  `updated_at` VARCHAR(32) NOT NULL,

  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_owner_slot` (`owner_key`, `slot`),
  KEY `idx_owner` (`owner_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
