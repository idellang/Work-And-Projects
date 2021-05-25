-- travel details

SELECT 
	lg.name AS hauler,
	dev.devicealias AS device_alias,
    ha.activity,
    ha.startstamp,
    ha.stopstamp,
    ha.duration AS travel_duration,
    ha.distancetraveled AS distance_travelled,
    ds1.name AS origin_name,
    ds1.category AS origin_category,
    ds2.name AS destination_name,
    ds2.category AS destination_category
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
LEFT JOIN
	destinations AS ds1
ON
	ds1.id = ha.start_destination_id
LEFT JOIN
	destinations AS ds2
ON
	ds2.id = ha.end_destination_id
WHERE 
	lib_grouping_id IN (2778, 2830)
AND
	ha.activity = 'TRAVEL TIME'
AND
	ha.startstamp >= '2021-01-01 00:00:00'
AND
	ha.duration > 5
AND
	ds1.category IN ('Uncategorized', 'Stop Points', 'Drop Off Point', 'Home Base', 'Pick-up/Delivery Point','Hotspot')
AND
	ds2.category IN ('Uncategorized', 'Stop Points', 'Drop Off Point', 'Home Base', 'Pick-up/Delivery Point','Hotspot')
	
	
	
	
 SELECT 
	dev.devicealias AS 'Vehicle', 
	dest1.name AS 'Origin', 
	dest2.name AS 'Destination', 
	histact.startstamp, 
	histact.stopstamp, 
	dest2.category AS 'Dest Category', 
	dest1.category AS 'Orig Category', 
	histact.duration AS 'Travel Duration', 
	histact.distancetraveled AS 'Distance Traveled',
	lg.name AS 'Group Name' 
FROM 
	hist_activity histact 
INNER JOIN 
	destinations dest2 
ON 
	histact.end_destination_id = dest2.id 
INNER JOIN 
	destinations dest1 
ON 
	histact.start_destination_id = dest1.id 
INNER JOIN 
	devices dev 
ON 
	histact.device_id = dev.id 
INNER JOIN 
	destinationgroups AS destg 
ON 
	destg.destination_id=dest2.id 
INNER JOIN 
	lib_groupings AS lg 
ON 
	lg.id = destg.lib_grouping_id 
WHERE 
	histact.activity = 'TRAVEL TIME' 
AND 
	destg.lib_grouping_id IN (2778, 2830) 
AND 
	histact.startstamp >= '2021-01-01 00:00:00'
AND
	histact.duration > 5

-- geofence dwell time
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
	lib_grouping_id IN (2778, 2830)
AND
	ha.activity = 'ZONING'
AND
	ha.startstamp >= '2021-01-01 00:00:00'
AND
	ha.duration > 5
AND
	des.category IN ('Uncategorized','Home Base','Pick-up/Delivery Point','Drop Off Point','Stop Points','Pick-up Point')
ORDER BY
	ha.startstamp ASC
	
	
---travel summary
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
LEFT JOIN
	activity_summary as act
ON
	act.device_id = dev.id
LEFT JOIN
	lib_groupings AS lg
ON
	lg.id = dg.lib_grouping_id
WHERE 
	lib_grouping_id IN (2778, 2830)
AND
	act.activity IN ('DISTANCE TRAVELLED', 'IDLE')
AND
	act.event_count > 0
AND
	act.datestamp >= '2021-01-01'
	
	
	
--Rover statuus
SELECT 
	lg.name AS hauler,
	dev.devicealias AS device_alias,
    dev.id,
	rs.distancetraveled AS odometer,
    rs.gpsSpeed AS current_speed,
    rs.reportstamp AS last_report_date,
    rs.lastlocation AS last_location,
    ls.name AS status,
    ar.alertmessage AS alert_message
FROM
	ngp.devices AS dev
JOIN
	ngp.devicegroups AS dg
ON
	dg.device_id = dev.id
JOIN
	lib_groupings AS lg
ON
	lg.id = dg.lib_grouping_id
JOIN
	roversstatus AS rs
ON
	rs.device_id = dev.id
LEFT JOIN
	lib_statuscodes AS ls
ON
	rs.lib_statuscode_id = ls.id
LEFT JOIN
	alertreferences AS ar
ON
	ar.id = rs.alertreference_ids
WHERE 
	lib_grouping_id IN  (2778, 2830)
AND
	rs.reportstamp != '1111-11-11 00:00:00'	
	
	
-- travel details edited 
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
	dg.lib_grouping_id IN (2778, 2830)
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
	