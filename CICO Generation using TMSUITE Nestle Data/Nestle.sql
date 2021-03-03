CREATE TABLE gps_data
(
    datestamp text,
   	geom geometry(point,4326),
	plateno text
);


INSERT INTO gps_data
SELECT 
	datestamp,
	ST_TRANSFORM(ST_SETSRID(ST_POINT(longitude, latitude), 4326), 4326) AS geom,
	plateno
FROM staging_table


SELECT 
	datestamp,
	ST_TRANSFORM(ST_SETSRID(ST_POINT(longitude, latitude), 4326), 4326) AS geom,
	plateno
FROM staging_table

SELECT * FROM gps_data


INSERT INTO gps_data
SELECT 
	datestamp,
	ST_TRANSFORM(ST_SETSRID(ST_POINT(longitude, latitude), 4326), 4326) AS geom,
	plateno
FROM staging_table
