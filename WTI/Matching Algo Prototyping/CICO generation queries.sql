-- CICO generation queries


-- create table GPS data whwich contains datestamp, geometry data, and plateno
CREATE TABLE gps_data
(
    datestamp text,
   	geom geometry(point,4326),
	plateno text
);


-- convert longitude and latitude to geometric data
-- the staging talbe is automatically created using Rscript
INSERT INTO gps_data
SELECT 
	datestamp,
	ST_TRANSFORM(ST_SETSRID(ST_POINT(longitude, latitude), 4326), 4326) AS geom,
	plateno
FROM staging_table


-- Query to get points inside geofence 

SELECT
	t.datestamp,
	t.plateno,
	g.name AS geofence_name
FROM 
	gps_data AS t
JOIN
	nestle_geofences_april29 AS g
ON 
      ST_INTERSECTS(g.geom, t.geom);
	  
-- Sample query to track an activity 
-- This checks the activity of Jm0314 vehicle from April 1 9:07:33 to April 1 12:07:33
-- also creates a column of geom of PH cagayan grocery

SELECT 
	to_timestamp(datestamp, 'YYYY-MM-DD hh24:mi:ss')::timestamp without time zone AS datestamp,
	plateno,
	t.geom AS geom_t,
	g.geom AS geom_g,
	name
FROM 
	JM0314 AS t,
	nestle_geofences_march23 AS g
WHERE 
	name = 'PH Cagayan Grocery - Source'
AND
	datestamp > '2021-04-01 09:07:33'
AND
	datestamp < '2021-04-01 12:07:33'
ORDER BY datestamp ASC