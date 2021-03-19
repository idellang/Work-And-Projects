SELECT * FROM
(
	SELECT 
		plateno,
		TO_TIMESTAMP(datestamp,'YYYY-MM-DD HH24:MI:SS') 
			 AS current_datestamp,
		geom AS first_geom,
		TO_TIMESTAMP(LEAD(datestamp) OVER (PARTITION BY plateno ORDER BY TO_TIMESTAMP(datestamp,'YYYY-MM-DD HH24:MI:SS') ASC),
			'YYYY-MM-DD HH24:MI:SS') 
			AS next_datestamp,
		LEAD(geom) OVER (PARTITION BY plateno ORDER BY TO_TIMESTAMP(datestamp,'YYYY-MM-DD HH24:MI:SS') ASC) 
			AS next_geom,
		ST_DISTANCE(geom::geography, 
					LEAD(geom) OVER (PARTITION BY plateno ORDER BY TO_TIMESTAMP(datestamp,'YYYY-MM-DD HH24:MI:SS') ASC)::geography) 
			AS distance_covered,
		extract (epoch from (TO_TIMESTAMP(LEAD(datestamp) OVER (PARTITION BY plateno ORDER BY TO_TIMESTAMP(datestamp,'YYYY-MM-DD HH24:MI:SS') ASC),
			'YYYY-MM-DD HH24:MI:SS') - TO_TIMESTAMP(datestamp,'YYYY-MM-DD HH24:MI:SS')))
	FROM 
		transpecial_gps_data
	) AS foo
WHERE 
	distance_covered > 100
ORDER BY
	date_part DESC
	
	

-- text
SELECT * FROM
(
	SELECT 
		plateno,
		TO_TIMESTAMP(datestamp,'YYYY-MM-DD HH24:MI:SS') 
			 AS current_datestamp,
		ST_ASTEXT(geom) AS first_geom,
		TO_TIMESTAMP(LEAD(datestamp) OVER (PARTITION BY plateno ORDER BY TO_TIMESTAMP(datestamp,'YYYY-MM-DD HH24:MI:SS') ASC),
			'YYYY-MM-DD HH24:MI:SS') 
			AS next_datestamp,
		ST_ASTEXT(LEAD(geom) OVER (PARTITION BY plateno ORDER BY TO_TIMESTAMP(datestamp,'YYYY-MM-DD HH24:MI:SS') ASC)) 
			AS next_geom,
		ST_DISTANCE(geom::geography, 
					LEAD(geom) OVER (PARTITION BY plateno ORDER BY TO_TIMESTAMP(datestamp,'YYYY-MM-DD HH24:MI:SS') ASC)::geography) 
			AS distance_covered,
		extract (epoch from (TO_TIMESTAMP(LEAD(datestamp) OVER (PARTITION BY plateno ORDER BY TO_TIMESTAMP(datestamp,'YYYY-MM-DD HH24:MI:SS') ASC),
			'YYYY-MM-DD HH24:MI:SS') - TO_TIMESTAMP(datestamp,'YYYY-MM-DD HH24:MI:SS')))
	FROM 
		transpecial_gps_data
	) AS foo
WHERE 
	distance_covered > 100
ORDER BY 
	distance_covered DESC