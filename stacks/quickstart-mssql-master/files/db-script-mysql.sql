
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

DROP DATABASE IF EXISTS `quickstart`;

CREATE DATABASE `quickstart` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `quickstart`;

-- -----------------------------------------------------
-- Schema quickstart
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `quickstart`;

-- -----------------------------------------------------
-- Schema quickstart
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `quickstart` DEFAULT CHARACTER SET utf8;
USE `quickstart`;

-- -----------------------------------------------------
-- Table `quickstart`.`Accounts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `quickstart`.`Accounts`;

CREATE TABLE IF NOT EXISTS `quickstart`.`Accounts` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(66) NOT NULL,
  `email` VARCHAR(66) NOT NULL,
  `emailRecovery` VARCHAR(66) NOT NULL,
  `password` VARCHAR(80) NOT NULL,
  `active` TINYINT(1) NOT NULL,
  `registered` DATETIME NOT NULL,
  `logged` TINYINT(1) NOT NULL,
  `photo` BLOB NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `email_unique` ON `quickstart`.`Accounts` (`email` ASC) INVISIBLE;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
