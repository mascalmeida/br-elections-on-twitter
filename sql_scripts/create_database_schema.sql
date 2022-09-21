/* 
Twitter & BR-Elections project
Tool: MySQL
Authors: @mascalmeida & @jorgel-mendes
*/

-- CREATE DATABASE
CREATE DATABASE IF NOT EXISTS br_elections;
USE br_elections;

-- CREATE PROFILE MENTIONS TABLE
DROP TABLE IF EXISTS profile_mentions;
CREATE TABLE IF NOT EXISTS profile_mentions (
	`start` TIMESTAMP NOT NULL,
	start_date DATE NOT NULL,
	start_time TIME NOT NULL,
	`end` TIMESTAMP NOT NULL,
	end_date DATE NOT NULL,
	end_time TIME NOT NULL,
    `@LulaOficial_mentions` INT,
    `@LulaOficial_mentions_without_retweet` INT,
    `@jairbolsonaro_mentions` INT,
    `@jairbolsonaro_mentions_without_retweet` INT,
    `@cirogomes_mentions` INT,
    `@cirogomes_mentions_without_retweet` INT,
    `@simonetebetbr_mentions` INT,
    `@simonetebetbr_mentions_without_retweet` INT,
    CONSTRAINT PK_end PRIMARY KEY (`end`)
);

-- CREATE PROFILE INFO TABLE
DROP TABLE IF EXISTS profile_info;
CREATE TABLE IF NOT EXISTS profile_info (
	`date` DATE NOT NULL,
    screen_name VARCHAR(32) NOT NULL,
    followers INT,
    `following` INT,
    posts INT,
    lists INT,
    likes INT,
    CONSTRAINT PK_date_person PRIMARY KEY (`date`, screen_name)
);