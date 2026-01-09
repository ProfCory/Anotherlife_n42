-- ALN3 base migration table is created via code, but this file is the place
-- to put initial schema bootstrap that all ALN3 resources can rely on later.
-- Keep migrations ADDITIVE ONLY. Never edit historical migration files.

-- Example: a tiny "meta" table for server/compat info (optional but useful)
CREATE TABLE IF NOT EXISTS `aln3_meta` (
  `k` VARCHAR(64) NOT NULL PRIMARY KEY,
  `v` TEXT NOT NULL,
  `updated_at` VARCHAR(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `aln3_meta` (`k`,`v`,`updated_at`)
VALUES ('schema','aln3','UTC')
ON DUPLICATE KEY UPDATE
  `v`=VALUES(`v`),
  `updated_at`=VALUES(`updated_at`);
