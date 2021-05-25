-- dwell time
SELECT 
	lg.name AS hauler,
	dev.devicealias AS device_alias,
    ha.activity,
    ha.startstamp,
    ha.stopstamp,
    ha.duration,
    des.name AS geofence_name,
    des.category AS geofence_category
FROM
	ngp.devices AS dev
JOIN
	ngp.devicegroups AS dg
ON
	dg.device_id = dev.id
JOIN
	ngp.hist_activity AS ha
ON
	ha.device_id = dev.id
JOIN
	lib_groupings AS lg
ON
	lg.id = dg.lib_grouping_id
JOIN
	destinations AS des
ON
	des.id = ha.start_destination_id
WHERE 
	lib_grouping_id = 2287
AND
	ha.activity = 'ZONING'
AND
	ha.startstamp >= '2021-01-01 00:00:00'
AND
	ha.startstamp <= '2021-03-31 23:59:59'
AND
	ha.duration > 5
AND
	des.category IN ('Uncategorized','Home Base','Drop Off Point','Stop Points','Pick-up Point')
ORDER BY
	ha.startstamp DESC
	
	
SELECT 	
	lg.name AS hauler,
	dev.devicealias AS device_alias,
    act.datestamp,
    act.activity,
    act.event_count
FROM
	ngp.devices AS dev
JOIN
	ngp.devicegroups AS dg
ON
	dg.device_id = dev.id
JOIN
	activity_summary as act
ON
	act.device_id = dev.id
JOIN
	lib_groupings AS lg
ON
	lg.id = dg.lib_grouping_id
WHERE 
	lib_grouping_id = 2287
AND
	act.activity IN ('DISTANCE TRAVELLED', 'IDLE')
AND
	act.event_count > 0
AND
	act.datestamp >= '2021-01-01'
AND
	act.datestamp < '2021-04-01'
AND
	act.event_count < 1000000
ORDER BY act.event_count DESC	
	
	
SELECT 
	lg.name AS hauler,
	dev.devicealias AS device_alias,
    ha.activity,
    ha.startstamp,
    ha.stopstamp,
    ha.duration AS travel_duration,
    ha.distancetraveled AS distance_travelled,
    des1.name AS origin_name,
    des1.category AS origin_category,
    des2.name AS destination_name,
    des2.category AS destination_category
FROM
	hist_activity AS ha
JOIN
	destinations AS des2
ON
	ha.end_destination_id = des2.id
JOIN
	destinations AS des1
ON
	ha.start_destination_id = des1.id
JOIN
	devices AS dev
ON
	ha.device_id = dev.id
JOIN
	destinationgroups AS dg
ON
	dg.destination_id = des2.id
JOIN
	lib_groupings AS lg
ON
	lg.id = dg.lib_grouping_id
WHERE 
	dg.lib_grouping_id = 2287
AND
	ha.activity = 'TRAVEL TIME'
AND
	ha.startstamp >= '2021-01-01 00:00:00'
AND
	ha.duration > 5
AND
	des1.category IN ('Uncategorized', 'Stop Points', 'Drop Off Point', 'Home Base', 'Pick-up/Delivery Point','Hotspot')
AND
	des2.category IN ('Uncategorized', 'Stop Points', 'Drop Off Point', 'Home Base', 'Pick-up/Delivery Point','Hotspot')
ORDER BY ha.distancetraveled DESC