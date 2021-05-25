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


Inside geofence 1
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
	datestamp > '2021-04-01 11:07:33'
AND
	datestamp < '2021-04-01 17:48:54'
ORDER BY datestamp ASC

Outside geofence 1
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
me
ORDER BY datestamp ASC
 


Inside geofence 2
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
	name = 'FDC - General Santos'
AND
	datestamp > '2021-04-05 05:42:55'
AND
	datestamp < '2021-04-05 10:21:56'
ORDER BY datestamp ASC


SELECT name, geom 
FROM nestle_geofences_april29
WHERE
	name LIKE '%PH Batino%'
OR 
	name LIKE '%Pure Logistics%'