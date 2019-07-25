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
    last_update timestamp NOT NULL,
    last_entry_id int(10)
);