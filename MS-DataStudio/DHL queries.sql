-- travel distance
SELECT
	dev.devicealias AS vehicle_plateno,
	ha.activity,
    ha.startstamp,
    ha.stopstamp,
    ha.duration AS travel_duration,
    ha.distancetraveled AS traveled_distance,
    lg.name AS hauler,
    ds1.name AS origin_name,
    ds1.category AS origin_category,
    ds2.name AS destination_name,
    ds2.category AS destination_category
FROM
	hist_activity AS ha
JOIN
	devicegroups AS dg
ON
	dg.device_id = ha.device_id
AND
	dg.lib_grouping_id = 2739
AND
	ha.activity = 'TRAVEL TIME'
JOIN
	lib_groupings AS lg
ON
	lg.id = dg.lib_grouping_id
JOIN
	destinations AS ds1
ON
	ds1.id = ha.start_destination_id
JOIN
	destinations AS ds2
ON
	ds2.id = ha.end_destination_id
AND
	ha.startstamp BETWEEN '2021-01-01 00:00:00' AND '2021-1-31 00:00:00'
LEFT JOIN
	devices AS dev
ON
	ha.device_id = dev.id
	
	
-- Dwell time
SELECT 
	dev.devicealias AS vehicle_plateno,
	ha.activity,
    ha.startstamp,
    ha.stopstamp,
    ha.duration,
    ds.name AS geofence_name,
    ds.category AS geofence_category,
    lg.name AS hauler
FROM 
	hist_activity AS ha
JOIN
	destinations AS ds
ON
	ds.id = ha.start_destination_id
AND
	ha.activity = 'ZONING'
JOIN
	destinationgroups AS dg
ON
	dg.destination_id = ds.id
AND
	dg.lib_grouping_id = 2739
LEFT JOIN
	lib_groupings AS lg
ON
	lg.id = dg.lib_grouping_id
LEFT JOIN
	devices AS dev
ON
	dev.id = ha.device_id
WHERE 
	ha.startstamp BETWEEN '2021-01-01' AND '2021-01-05'
AND
	ha.duration > 5
ORDER BY
	ha.startstamp ASC
	
	
-- activities
SELECT 
	dev.devicealias AS vehicle_plateno,
	act.datestamp,
    act.device_id,
    act.activity,
    act.event_count,
    lg.name AS hauler,
    lg.id AS hauler_id
FROM 
	activity_summary AS act
JOIN
	devices AS dev
ON
	dev.id = act.device_id
LEFT JOIN
	devicegroups AS dg
ON
	dg.device_id = dev.id
AND
	dg.lib_grouping_id = 2739
JOIN
	lib_groupings AS lg
ON
	lg.id = dg.lib_grouping_id
AND
	act.activity IN ('IDLE','DISTANCE TRAVELLED','SPEEDING','HARSH ACCELERATION','HARSH BREAK')
AND
	act.datestamp BETWEEN '2021-01-01 00:00:00' AND '2021-03-01 00:00:00'
ORDER BY 
	act.datestamp ASC
	
	
-- rover status
SELECT 
	dev.devicealias AS vehicle_plateno,
	rs.lastlocation,
    rs.distancetraveled AS odometer,
    rs.gpsSpeed AS current_speed,
    rs.reportstamp AS last_report_date,
    ls.name AS status,
    ar.alertmessage AS alert_message,
FROM 
	roversstatus AS rs
JOIN
	lib_statuscodes AS ls
ON
	rs.lib_statuscode_id = ls.id
JOIN
	alertreferences AS ar
ON
	ar.id = rs.alertreference_ids
JOIN
	devices AS dev
ON
	dev.id = rs.device_id
JOIN
	devicegroups AS dg
ON
	dg.device_id = dev.id
AND
	dg.lib_grouping_id = 2739
JOIN
	lib_groupings AS lg
ON
	dg.lib_grouping_id = lg.id

