SELECT 
	dev.devicealias AS device_alias,
    COALESCE(vd.vehicle_type,'Unknown') AS vehicle_type,
	act.datestamp,
    act.event_count/ 1000 AS distance_km,
    (CASE
		WHEN vd.vehicle_type = 'AUV' THEN act.event_count / 25000 * 2.68
        WHEN vd.vehicle_type = '6WH' THEN act.event_count / 10000 * 2.68
        WHEN vd.vehicle_type = 'MPV' THEN act.event_count / 13500 * 2.68
        WHEN vd.vehicle_type = '10WH' THEN act.event_count / 5500 * 2.68
        WHEN vd.vehicle_type = '4WH' THEN act.event_count / 12000 * 2.68
        WHEN vd.vehicle_type = 'FWD' THEN act.event_count / 8100 * 2.68
        WHEN vd.vehicle_type = 'THEAD' THEN act.event_count / 10000 * 2.68
        WHEN vd.vehicle_type = '40FT' THEN act.event_count / 8000 * 2.68
		WHEN vd.vehicle_type = 'PORTABLE' THEN act.event_count / 16000 * 2.68
		WHEN vd.vehicle_type = '10W' THEN act.event_count / 5500 * 2.68
		WHEN vd.vehicle_type = '50FT' THEN act.event_count / 7000 * 2.68
        ELSE act.event_count / 12000 * 2.68
	END) AS carbon_kg
FROM 
	ngp.lib_groupings AS lg
JOIN
	devicegroups AS dg
ON
	dg.lib_grouping_id = lg.id
JOIN
	ngp.devices AS dev
ON
	dev.id = dg.device_id
JOIN
	activity_summary AS act
ON
	act.device_id = dev.id
LEFT JOIN
	vehicle_details as vd
ON
	vd.device_id = dev.id
WHERE  
	lg.id = 94
AND
	act.datestamp >= '2021-04-01'
AND
	act.activity = 'DISTANCE TRAVELLED'
AND
	act.event_count > 0
AND
	act.event_count < 1000000
	
	
-- with group names 

SELECT 
	lg.name,
	dev.devicealias AS device_alias,
    COALESCE(vd.vehicle_type,'Unknown') AS vehicle_type,
	act.datestamp,
    act.event_count/ 1000 AS distance_km,
    (CASE
		WHEN vd.vehicle_type = 'AUV' THEN act.event_count / 25000 * 2.68
        WHEN vd.vehicle_type = '6WH' THEN act.event_count / 10000 * 2.68
        WHEN vd.vehicle_type = 'MPV' THEN act.event_count / 13500 * 2.68
        WHEN vd.vehicle_type = '10WH' THEN act.event_count / 5500 * 2.68
        WHEN vd.vehicle_type = '4WH' THEN act.event_count / 12000 * 2.68
        WHEN vd.vehicle_type = 'FWD' THEN act.event_count / 8100 * 2.68
        WHEN vd.vehicle_type = 'THEAD' THEN act.event_count / 10000 * 2.68
        WHEN vd.vehicle_type = '40FT' THEN act.event_count / 8000 * 2.68
		WHEN vd.vehicle_type = 'PORTABLE' THEN act.event_count / 16000 * 2.68
		WHEN vd.vehicle_type = '10W' THEN act.event_count / 5500 * 2.68
		WHEN vd.vehicle_type = '50FT' THEN act.event_count / 7000 * 2.68
        ELSE act.event_count / 12000 * 2.68
	END) AS carbon_kg
FROM 
	ngp.lib_groupings AS lg
JOIN
	devicegroups AS dg
ON
	dg.lib_grouping_id = lg.id
JOIN
	ngp.devices AS dev
ON
	dev.id = dg.device_id
JOIN
	activity_summary AS act
ON
	act.device_id = dev.id
LEFT JOIN
	vehicle_details as vd
ON
	vd.device_id = dev.id
WHERE  
	lg.id IN (94, 1705, 2781)
AND
	act.datestamp >= '2021-05-01'
AND
	act.activity = 'DISTANCE TRAVELLED'
AND
	act.event_count > 0
AND
	act.event_count < 1000000