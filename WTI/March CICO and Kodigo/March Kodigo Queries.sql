SELECT 
	TO_TIMESTAMP(t.datestamp,'YYYY-MM-DD HH24:MI:SS') 
			 AS datestamp,
	geom,
	plateno
FROM 
	gps_data AS t
WHERE 
	plateno = 'KAD4602'
ORDER BY 
	TO_TIMESTAMP(t.datestamp,'YYYY-MM-DD HH24:MI:SS') ASC

SELECT 
	TO_TIMESTAMP(t.datestamp,'YYYY-MM-DD HH24:MI:SS') 
			 AS datestamp,
	t.plateno,
	t.geom AS geom_t,
	g.geom AS geom_g,
	g.name AS geofence_name
FROM 
	gps_data AS t, 
	nestle_geofences_march23 AS g
WHERE 
	plateno = 'KVW909'
AND
	name = 'PH Cagayan Grocery - Source'
ORDER BY
	TO_TIMESTAMP(t.datestamp,'YYYY-MM-DD HH24:MI:SS') ASC
	
	
--
High GPS interval
SELECT 
	TO_TIMESTAMP(t.datestamp,'YYYY-MM-DD HH24:MI:SS') 
			 AS datestamp,
	geom,
	plateno
FROM 
	gps_data AS t
WHERE 
	plateno = 'KVW909'
AND
	TO_TIMESTAMP(t.datestamp,'YYYY-MM-DD HH24:MI:SS') > '2021-03-15 14:58:00'
ORDER BY 
	TO_TIMESTAMP(t.datestamp,'YYYY-MM-DD HH24:MI:SS') ASC;
	
	
	
-- CICO in tanauan
SELECT 
	TO_TIMESTAMP(t.datestamp,'YYYY-MM-DD HH24:MI:SS') 
			 AS datestamp,
	geom,
	plateno
FROM 
	gps_data AS t
WHERE 
	plateno = 'NBG1170'
AND
	TO_TIMESTAMP(t.datestamp,'YYYY-MM-DD HH24:MI:SS') > '2021-03-15 20:30:00'
ORDER BY 
	TO_TIMESTAMP(t.datestamp,'YYYY-MM-DD HH24:MI:SS') ASC;
	
	
--RLK 700
SELECT 
	TO_TIMESTAMP(t.datestamp,'YYYY-MM-DD HH24:MI:SS') 
			 AS datestamp,
	geom,
	plateno
FROM 
	gps_data AS t
WHERE 
	plateno = 'RLK700'
AND
	TO_TIMESTAMP(t.datestamp,'YYYY-MM-DD HH24:MI:SS') > '2021-03-18 00:00:00'
ORDER BY 
	TO_TIMESTAMP(t.datestamp,'YYYY-MM-DD HH24:MI:SS') ASC;