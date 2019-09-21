SET SQL_MODE='ALLOW_INVALID_DATES';

CREATE TABLE IF NOT EXISTS sensor_data (
    src_id int(10),
    entry_id int(10),
    entry_time timestamp NOT NULL DEFAULT NOW(),
    pm1 double(6, 2),
    pm2_5 double(6, 2),
    pm10 double(6, 2),
    humidity double(6, 2),
    temperature double(6, 2),
    voc double(6, 2),
    carbon_monoxide double(6, 2)
);

CREATE TABLE IF NOT EXISTS sensor_map (
    src_id int(10) UNIQUE,
    location_name varchar(64),
    latitude double(9, 5),
    longitude double(9, 5),
    creation_time timestamp NOT NULL,
    last_update timestamp NOT NULL
);

CREATE TABLE IF NOT EXISTS action_log (
    id int(10) AUTO_INCREMENT PRIMARY KEY,
    entry_time timestamp NOT NULL DEFAULT NOW(),
    ip varchar(20),
    request varchar(64),
    params varchar(128)
);

CREATE TABLE IF NOT EXISTS ip_map (
    ip varchar(20) PRIMARY KEY,
    city varchar(32),
    country varchar(32),
    isp varchar(64)
);

ALTER TABLE `sensor_data` ADD `rec_id` INT UNSIGNED  NOT NULL  AUTO_INCREMENT  PRIMARY KEY  AFTER `carbon_monoxide`;
ALTER TABLE `sensor_data` MODIFY COLUMN `rec_id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT FIRST;

CREATE TABLE IF NOT EXISTS users (
	id INT(10) AUTO_INCREMENT PRIMARY KEY,
	name TEXT,
	email TEXT NOT NULL,
	password TEXT NOT NULL,
    type TEXT NOT NULL,
	created_at timestamp NOT NULL DEFAULT NOW()
);
ALTER TABLE `sensor_map` ADD `user_id` INT  NULL  DEFAULT NULL  AFTER `last_update`;
ALTER TABLE `sensor_map` ADD `api_key` TEXT  NULL  AFTER `user_id`;
ALTER TABLE `sensor_map` ADD `thingspeak` INT  NULL  DEFAULT NULL;
ALTER TABLE `sensor_map` CHANGE `location_name` `location_name` TEXT  CHARACTER SET utf8  COLLATE utf8_general_ci  NULL;

ALTER TABLE `sensor_map` CHANGE `src_id` `src_id` INT(10)  NOT NULL  AUTO_INCREMENT;
UPDATE `sensor_map` SET `thingspeak` = '810768' WHERE `src_id` = '810768';
UPDATE `sensor_map` SET `thingspeak` = '814173' WHERE `src_id` = '814173';
UPDATE `sensor_map` SET `thingspeak` = '814176' WHERE `src_id` = '814176';
UPDATE `sensor_map` SET `thingspeak` = '814180' WHERE `src_id` = '814180';
UPDATE `sensor_map` SET `thingspeak` = '814241' WHERE `src_id` = '814241';
UPDATE `sensor_map` SET `src_id` = '1' WHERE `src_id` = '810768';
UPDATE `sensor_map` SET `src_id` = '2' WHERE `src_id` = '814173';
UPDATE `sensor_map` SET `src_id` = '3' WHERE `src_id` = '814176';
UPDATE `sensor_map` SET `src_id` = '4' WHERE `src_id` = '814180';
UPDATE `sensor_map` SET `src_id` = '5' WHERE `src_id` = '814241';
UPDATE `sensor_data` SET `src_id` = '1' WHERE `src_id` = '810768';
UPDATE `sensor_data` SET `src_id` = '2' WHERE `src_id` = '814173';
UPDATE `sensor_data` SET `src_id` = '3' WHERE `src_id` = '814176';
UPDATE `sensor_data` SET `src_id` = '4' WHERE `src_id` = '814180';
UPDATE `sensor_data` SET `src_id` = '4' WHERE `src_id` = '814180';
UPDATE `sensor_data` SET `src_id` = '5' WHERE `src_id` = '814241';
ALTER TABLE `sensor_map` AUTO_INCREMENT = 1;


