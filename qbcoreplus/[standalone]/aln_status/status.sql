-- status.sql (NEW) - schema only, no logic
-- Tracks consumable usage + metrics for later addiction/tolerance systems.

CREATE TABLE IF NOT EXISTS `aln_status_use_log` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  -- QBCore identifiers (store what you have; nullable for flexibility)
  `citizenid` VARCHAR(64) NULL,
  `license`   VARCHAR(64) NULL,

  -- what was used
  `item`      VARCHAR(64) NOT NULL,
  `source`    VARCHAR(32) NULL, -- e.g. "consumable", "sleep", "admin", "script"
  `context`   VARCHAR(64) NULL, -- e.g. "dealer", "shop", "bar", "motel", "vehicle"

  -- deltas applied (signed)
  `delta_hunger`   INT NULL,
  `delta_thirst`   INT NULL,
  `delta_stress`   INT NULL,
  `delta_fatigue`  INT NULL,
  `delta_drunk`    INT NULL,
  `delta_stoned`   INT NULL,
  `delta_tripping` INT NULL,
  `delta_drugged`  INT NULL,

  PRIMARY KEY (`id`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_citizenid` (`citizenid`),
  INDEX `idx_item` (`item`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `aln_status_player_metrics` (
  `citizenid` VARCHAR(64) NOT NULL,

  -- last seen
  `last_seen` TIMESTAMP NULL DEFAULT NULL,

  -- counts
  `uses_total` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `uses_alcohol` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `uses_weed` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `uses_tripping` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `uses_drugged` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `sleeps_total` BIGINT UNSIGNED NOT NULL DEFAULT 0,

  -- last timestamps by category
  `last_use_alcohol` TIMESTAMP NULL DEFAULT NULL,
  `last_use_weed` TIMESTAMP NULL DEFAULT NULL,
  `last_use_tripping` TIMESTAMP NULL DEFAULT NULL,
  `last_use_drugged` TIMESTAMP NULL DEFAULT NULL,
  `last_sleep` TIMESTAMP NULL DEFAULT NULL,

  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
