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



-- Updated Geofence
CREATE TABLE nestle_geofence_updated_march
(
    name text,
	wkt text,
	category text,
	location text,
	municipality text,
	province text,
	type text,
   	geom geometry(multipolygon,4326)
	
);

INSERT INTO nestle_geofence_updated_march
SELECT
	name,
	wkt,
	category,
	location,
	municipality,
	province,
	type,
	ST_TRANSFORM(ST_SETSRID(ST_GEOMFROMTEXT(wkt), 4326), 4326)
FROM nestle_geofence_march


SELECT 
	t.datestamp,
	t.plateno,
	t.geom AS geom_t
	g.name AS geofence_name,
	g.geom AS geom_g
FROM 
	nestle_geofence_updated_march AS g
INNER JOIN
	ehd_gps_data AS t
ON ST_INTERSECTS(g.geom , t.geom)

-- Create index
CREATE INDEX ehd_gps_data_geom
  ON ehd_gps_data
  USING GIST (geom);