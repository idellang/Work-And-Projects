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
		