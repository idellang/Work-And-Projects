SELECT
	t.datestamp,
	t.plateno,
	g.name AS geofence_name,
	t.geom AS geom_t,
	g.geom AS geom_g
FROM 
	transpecial_gps_data AS t
JOIN
	nestle_geofence AS g
ON 
      ST_INTERSECTS(g.geom, t.geom)
WHERE
	g.name = 'PH Cofipack - Source'
AND
	t.plateno = 'ADC4769'
	
SELECT
	t.datestamp,
	t.plateno,
	t.geom AS geom_t,
FROM 
	transpecial_gps_data AS t
WHERE
	t.plateno = 'ADC4769'

	
SELECT
	t.datestamp,
	t.plateno,
	t.geom AS geom_t,
	g.name,
	g.geom AS geom_g
FROM 
	transpecial_gps_data AS t,
	nestle_geofence AS g
WHERE
	t.plateno = 'ADC4769'
AND
	g.name = 'PH Cofipack - Source'
	
	
SELECT
	TO_TIMESTAMP(
    t.datestamp,
    'YYYY-MM-DD HH24:MI:SS') AS datestamp,
	t.plateno,
	t.geom AS geom_t,
	g.name,
	g.geom AS geom_g
FROM 
	transpecial_gps_data AS t,
	nestle_geofence AS g
WHERE
	t.plateno = 'ADC4769'
AND
	g.name = 'PH Cofipack - Source'
ORDER BY
	datestamp ASC	
	
	
-- between datestamp
SELECT
	TO_TIMESTAMP(
    t.datestamp,
    'YYYY-MM-DD HH24:MI:SS') AS datestamp,
	t.plateno,
	t.geom AS geom_t,
	g.name,
FROM 
	transpecial_gps_data AS t,
	nestle_geofence AS g
WHERE
	t.plateno = 'ADC4769'
AND
	g.name = 'PH Cofipack - Source'
AND
	t.datestamp > '2021-01-05 07:25:25-08'
AND
	t.datestamp < '2021-01-05 09:20:14-08'
ORDER BY
	datestamp ASC
	

-- geofence
SELECT geom
FROM nestle_geofence
WHERE name = 'PH Cofipack - Source'	


-- case example 1
SELECT
	TO_TIMESTAMP(
    t.datestamp,
    'YYYY-MM-DD HH24:MI:SS') AS datestamp,
	t.plateno,
	t.geom AS geom_t,
	g.name,
	g.geom AS geom_g
FROM 
	transpecial_gps_data AS t,
	nestle_geofence AS g
WHERE
	t.plateno = 'KVU104'
AND
	g.name = 'PSACC - Dadiangas CY 1'
AND
	t.datestamp >= '2021-01-09 07:09:22'
ORDER BY
	datestamp ASC	
	
	
--case 2	
SELECT
	TO_TIMESTAMP(
    t.datestamp,
    'YYYY-MM-DD HH24:MI:SS') AS datestamp,
	t.plateno,
	t.geom AS geom_t,
	g.name,
	g.geom AS geom_g
FROM 
	transpecial_gps_data AS t,
	nestle_geofence AS g
WHERE
	t.plateno = 'JM0535'
AND
	g.name = 'PH Bacolod - Mansilingan DC - Destination'
AND
	t.datestamp >= '2021-01-04 16:46:05'
ORDER BY
	datestamp ASC	
		