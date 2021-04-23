-- convert to timestamp
SELECT
	DATE_TRUNC('minute', datestamp)-
	CAST(MOD(CAST(DATE_PART('minute', datestamp) AS integer), 30) || 'minutes' AS interval) AS track_period,
FROM
	nestle_gps_data
ORDER BY
	datestamp ASC
	
--group by time and vehicle
SELECT
	plateno,
	DATE_TRUNC('minute', datestamp)-
	CAST(MOD(CAST(DATE_PART('minute', datestamp) AS integer), 30) || 'minutes' AS interval) AS track_period,
	MIN(datestamp) AS time_start,
	MAX(datestamp) AS time_end,
	COUNT(datestamp) AS num_points
FROM
	nestle_gps_data
GROUP BY
	plateno, track_period
ORDER BY
	plateno, track_period

--combined all data
SELECT 
	name AS geofence_name,
	datestamp,
	plateno,
	speed
FROM
	nestle_geofence AS g
JOIN
	nestle_gps_data AS t
ON
	ST_INTERSECTS(g.geom, t.geom)	
	
--combined gps data with filter
SELECT 
	t.plateno AS plate_number,
	g.name AS geofence_name,
	DATE_TRUNC('minute', datestamp)-
	CAST(MOD(CAST(DATE_PART('minute', datestamp) AS integer), 30) || 'minutes' AS interval) AS track_period,
	MIN(datestamp) AS time_start,
	MAX(datestamp) AS time_end,
	COUNT(datestamp) AS num_points
FROM
	nestle_gps_data AS t
JOIN
	nestle_geofence AS g
ON
	ST_INTERSECTS(g.geom, t.geom)
GROUP BY
	plateno, g.name, track_period
HAVING 
	COUNT(datestamp) > 5
ORDER BY
	track_period ASC, g.name, plateno

-- 1937 combination of points, timestamp, and location
SELECT COUNT(*)
FROM(
	SELECT 
		t.plateno AS plate_number,
		g.name AS geofence_name,
		DATE_TRUNC('minute', datestamp)-
		CAST(MOD(CAST(DATE_PART('minute', datestamp) AS integer), 30) || 'minutes' AS interval) AS track_period,
		MIN(datestamp) AS time_start,
		MAX(datestamp) AS time_end,
		COUNT(datestamp) AS num_points
	FROM
		nestle_gps_data AS t
	JOIN
		nestle_geofence AS g
	ON
		ST_INTERSECTS(g.geom, t.geom)
	GROUP BY
		plateno, g.name, track_period
	HAVING 
		COUNT(datestamp) > 5
	ORDER BY
		track_period ASC, g.name, plateno
) AS foo	

--

CREATE TABLE transpecial_gps_data
(
    datestamp timestamp with time zone NOT NULL,
   	geom geometry(point,4326),
	plateno text
);



SELECT
	t.datestamp,
	t.geom geom_t,
	t.plateno,
	g.name AS geofence_name,
	g.geom AS geom_g
FROM 
	transpecial_gps_data AS t
JOIN
	nestle_geofence AS g
ON ST_INTERSECTS(g.geom, t.geom)