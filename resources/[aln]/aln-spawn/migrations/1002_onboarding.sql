ALTER TABLE `aln3_characters`
  ADD COLUMN IF NOT EXISTS `onboarding_done` TINYINT NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `starter_vehicle_model` VARCHAR(32) NULL,
  ADD COLUMN IF NOT EXISTS `starter_vehicle_plate` VARCHAR(16) NULL,
  ADD COLUMN IF NOT EXISTS `base_model` VARCHAR(64) NULL;
