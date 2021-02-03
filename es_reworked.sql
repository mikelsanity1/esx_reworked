CREATE DATABASE IF NOT EXISTS `esx_reworked`;
USE `esx_reworked`;

CREATE TABLE `jobs` (
	`id` INT AUTO_INCREMENT PRIMARY KEY,
	`name` VARCHAR(50) NOT NULL,
	`label` VARCHAR(50) NOT NULL DEFAULT '',
	`whitelisted` INT NOT NULL DEFAULT 0,

	CONSTRAINT `jobs_name` UNIQUE (`name`)
);

CREATE TABLE `job_grades` (
	`job_id` INT NOT NULL,
	`grade` INT NOT NULL DEFAULT 0,
	`name` VARCHAR(50) NOT NULL DEFAULT '',
	`label` VARCHAR(50) NOT NULL DEFAULT '',
	`salary` INT NOT NULL DEFAULT 0,

	PRIMARY KEY (`job_id`, `grade`),

	CONSTRAINT `job_grades_name` UNIQUE (`job_id`, `name`),
	CONSTRAINT `fk_job_grades_job_id` FOREIGN KEY (`job_id`) REFERENCES `jobs`(`id`)
);

CREATE TABLE `players` (
	`id` INT AUTO_INCREMENT PRIMARY KEY,
	`identifier` VARCHAR(50) NOT NULL,
	`name` VARCHAR(100) NOT NULL DEFAULT 'Unknown',
	`group` VARCHAR(50) NOT NULL DEFAULT 'user',
	`job` INT NOT NULL,
	`grade` INT NOT NULL,
	`job2` INT NOT NULL,
	`grade2` INT NOT NULL,
	`position` VARCHAR(100) NULL DEFAULT '[-206.79,-1015.12,29.14]',

	CONSTRAINT `players_identifier` UNIQUE (`identifier`),
    CONSTRAINT `fk_players_job` FOREIGN KEY (`job`,`grade`) REFERENCES `job_grades`(`job_id`,`grade`),
	CONSTRAINT `fk_players_job2` FOREIGN KEY (`job2`,`grade2`) REFERENCES `job_grades`(`job_id`,`grade`)
);

CREATE TABLE `items` (
	`id` INT AUTO_INCREMENT PRIMARY KEY,
	`name` VARCHAR(50) NOT NULL,
	`label` VARCHAR(50) NOT NULL DEFAULT '',
	`weight` DECIMAL(5,2) NOT NULL DEFAULT 1,

	CONSTRAINT `items_name` UNIQUE (`name`)
);

CREATE TABLE `inventory` (
	`player_id` INT NOT NULL,
	`item_id` INT NOT NULL,
	`amount` INT NOT NULL DEFAULT  0,

	PRIMARY KEY (`player_id`, `item_id`),

	CONSTRAINT `fk_inventory_player_id` FOREIGN KEY (`player_id`) REFERENCES `players`(`id`),
	CONSTRAINT `fk_inventory_item_id` FOREIGN KEY (`item_id`) REFERENCES `items`(`id`)
);

CREATE TABLE `storages` (
	`id` INT AUTO_INCREMENT PRIMARY KEY,
	`name` VARCHAR(50) NOT NULL DEFAULT 'unknown',
	`label` VARCHAR(50) NOT NULL DEFAULT '',

	CONSTRAINT `storages_name` UNIQUE (`name`)
);

CREATE TABLE `weapons` (
	`id` INT AUTO_INCREMENT PRIMARY KEY,
	`uuid` BINARY(16) NOT NULL,
	`player_id` INT DEFAULT NULL,
	`job_id` INT DEFAULT NULL,
	`model` VARCHAR(50) NOT NULL DEFAULT 'unknown',
	`bullets` INT NOT NULL DEFAULT 120,
	`storage_id` INT NOT NULL,
	`components` LONGTEXT NOT NULL,

	CONSTRAINT `weapons_uuid` UNIQUE (`uuid`),
	CONSTRAINT `fk_weapons_player_id` FOREIGN KEY (`player_id`) REFERENCES `players`(`id`),
	CONSTRAINT `fk_weapons_job_id` FOREIGN KEY (`job_id`) REFERENCES `jobs`(`id`),
	CONSTRAINT `fk_weapons_storage_id` FOREIGN KEY (`storage_id`) REFERENCES `storages`(`id`)
);

CREATE TABLE `wallets` (
	`id` INT AUTO_INCREMENT PRIMARY KEY,
	`name` VARCHAR(50) NOT NULL DEFAULT 'unknown',
	`label` VARCHAR(50) NOT NULL DEFAULT '',

	CONSTRAINT `wallets_name` UNIQUE (`name`)
);

CREATE TABLE `player_wallets` (
	`wallet_id` INT NOT NULL,
	`player_id` INT NOT NULL,
	`saldo` INT NOT NULL DEFAULT 0,

	PRIMARY KEY (`wallet_id`, `player_id`),
	CONSTRAINT `fk_player_wallets_wallet_id` FOREIGN KEY (`wallet_id`) REFERENCES `wallets`(`id`),
	CONSTRAINT `fk_player_wallets_player_id` FOREIGN KEY (`player_id`) REFERENCES `players`(`id`)
);

CREATE TABLE `job_wallets` (
	`wallet_id` INT NOT NULL,
	`job_id` INT NOT NULL,
	`saldo` INT NOT NULL DEFAULT 0,

	PRIMARY KEY (`wallet_id`, `job_id`),
	CONSTRAINT `fk_job_wallets_wallet_id` FOREIGN KEY (`wallet_id`) REFERENCES `wallets`(`id`),
	CONSTRAINT `fk_job_wallets_job_id` FOREIGN KEY (`job_id`) REFERENCES `jobs`(`id`)
);

CREATE TABLE `player_identifiers` (
	`id` INT AUTO_INCREMENT PRIMARY KEY,
	`name` VARCHAR(50) NOT NULL DEFAULT 'Unknown',
	`steam` VARCHAR(50) NULL DEFAULT NULL,
	`license` VARCHAR(50) NULL DEFAULT NULL,
	`license2` VARCHAR(50) NULL DEFAULT NULL,
	`xbl` VARCHAR(50) NULL DEFAULT NULL,
	`live` VARCHAR(50) NULL DEFAULT NULL,
	`discord` VARCHAR(50) NULL DEFAULT NULL,
	`fivem` VARCHAR(50) NULL DEFAULT NULL,
	`ip` VARCHAR(50) NULL DEFAULT NULL,
	`date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE `player_tokens` (
	`id` INT AUTO_INCREMENT PRIMARY KEY,
	`identifier_id` INT NOT NULL,
	`prefix` INT NOT NULL DEFAULT 0,
	`value` VARCHAR(100) NULL DEFAULT NULL,

	CONSTRAINT `fk_player_tokens_identifier_id` FOREIGN KEY (`identifier_id`) REFERENCES `player_identifiers`(`id`)
);

INSERT INTO `jobs` (`name`, `label`, `whitelisted`) VALUES ('unemployed', 'Unemployed', 0);
INSERT INTO `job_grades` SELECT `id` AS `job_id`, 0 AS `grade`, 'unemployed' AS `name`, 'Unemployed' AS `label`, 250 AS `salary` FROM `jobs` WHERE `name` = 'unemployed' LIMIT 1;