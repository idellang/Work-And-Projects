
-- activity summary
SELECT 
	dev.devicealias AS vehicle_plateno,
	act.datestamp,
    act.device_id,
    act.activity,
    act.event_count,
    lg.name AS division_name,
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
JOIN
	lib_groupings AS lg
ON
	lg.id = dg.lib_grouping_id
AND
	act.activity IN ('IDLE','DISTANCE TRAVELLED','SPEEDING','HARSH ACCELERATION','HARSH BREAK')
AND
	act.datestamp BETWEEN '2021-02-01 00:00:00' AND '2021-03-15 00:00:00'
AND 
	dg.lib_grouping_id IN (SELECT 
            id
        FROM
            lib_groupings
        WHERE
            parent_id = 2622 OR id = 2622)
ORDER BY 
	act.datestamp ASC

--ginebra dwell time query
SELECT 
	dev.devicealias AS vehicle_plateno,
    ha.activity,
    ha.startstamp,
    ha.stopstamp,
    ha.duration,
    ds.name AS geofence_name,
    ds.category AS geofence_category,
    lg.name AS division_name
FROM
    hist_activity AS ha
        JOIN
    destinations AS ds ON ds.id = ha.start_destination_id
        AND ha.activity = 'ZONING'
        JOIN
    destinationgroups AS dg ON dg.destination_id = ds.id
        LEFT JOIN
    lib_groupings AS lg ON lg.id = dg.lib_grouping_id
        LEFT JOIN
    devices AS dev ON dev.id = ha.device_id
WHERE
    ha.startstamp BETWEEN '2021-02-01 00:00:00' AND '2021-03-15 00:00:00'
        AND ha.duration > 5
        AND dg.lib_grouping_id IN (SELECT 
            id
        FROM
            lib_groupings
        WHERE
            parent_id = 2622 OR id = 2622)
ORDER BY ha.startstamp ASC


--travel distance
SELECT 
	dev.devicealias AS vehicle_plateno,
	ha.activity,
    ha.startstamp,
    ha.stopstamp,
    ha.duration AS travel_duration,
    ha.distancetraveled AS traveled_distance,
    lg.name AS division_name,
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
LEFT JOIN
	devices AS dev
ON
	ha.device_id = dev.id
WHERE
	ha.startstamp BETWEEN '2021-02-01 00:00:00' AND '2021-3-15 00:00:00'
AND 
	dg.lib_grouping_id IN (SELECT 
            id
        FROM
            lib_groupings
        WHERE
            parent_id = 2622 OR id = 2622)

