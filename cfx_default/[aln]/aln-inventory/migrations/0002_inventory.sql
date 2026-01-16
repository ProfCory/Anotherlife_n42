CREATE TABLE IF NOT EXISTS `aln3_inventory` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `owner_key` VARCHAR(96) NOT NULL,
  `bag` VARCHAR(32) NOT NULL,         -- pockets | wearables | stash
  `container_id` VARCHAR(128) NOT NULL, -- pockets | wearables | stash:<id>
  `slot` INT NOT NULL,
  `item_key` VARCHAR(64) NOT NULL,
  `count` INT NOT NULL,
  `meta_json` LONGTEXT NULL,
  `updated_at` VARCHAR(32) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_owner_container_slot` (`owner_key`, `container_id`, `slot`),
  KEY `idx_owner` (`owner_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
