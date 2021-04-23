--travel time matrix
SELECT
	dev.devicealias AS vehicle_name,
	ha.startstamp,
    ha.stopstamp,
    ha.duration AS travel_duration,
    ha.distancetraveled AS traveled_distance,
    dest1.name AS origin_name,
    dest1.category AS origin_category,
    dest2.name AS destination_name,
    dest2.category AS destination_category
FROM
	ngp.hist_activity AS ha
INNER JOIN
	ngp.destinations AS dest2
ON
	ha.end_destination_id = dest2.id
AND
	ha.activity = 'TRAVEL TIME'
INNER JOIN
	ngp.destinations AS dest1
ON
	ha.start_destination_id = dest1.id
INNER JOIN
	ngp.devices AS dev
ON
	ha.device_id = dev.id
INNER JOIN
	ngp.destinationgroups AS destgroups
ON
	destgroups.destination_id = dest2.id
AND
	destgroups.lib_grouping_id = 1059
INNER JOIN
	ngp.lib_groupings AS lg
ON
	lg.id = destgroups.lib_grouping_id
WHERE
	ha.startstamp BETWEEN '2020-01-01 00:00:00' AND '2020-09-30 00:00:00'
	
--activity summary	
SELECT
	act.datestamp,
    act.event_count,
    act.activity,
    dev.devicealias AS vehicle_plateno,
    dev_group.lib_grouping_id,
    lg.name AS lg_name
FROM
	ngp.activity_summary AS act
LEFT JOIN
	ngp.devices AS dev
ON
	dev.id = act.device_id
LEFT JOIN
	ngp.devicegroups AS dev_group
ON
	dev_group.device_id = dev.id
LEFT JOIN
	ngp.lib_groupings AS lg
ON
	lg.id = dev_group.lib_grouping_id
WHERE
	act.device_id IN(
    SELECT 
		device_id
	FROM
		ngp.devicegroups
	WHERE
		lib_grouping_id IN (2484, 2485, 2486, 2487, 2488, 2489, 2490, 2495, 2534, 2541)
    )
AND
	act.activity IN ('IDLE','DISTANCE TRAVELLED','SPEEDING','HARSH ACCELERATION','HARSH BREAK')
AND 
	act.datestamp BETWEEN '2019-09-01' AND '2020-09-30'
	
	
-- geofence activity
SELECT
	ha.startstamp,
    ha.stopstamp,
    ha.duration,
    ds.category,
    ds.name AS geofence_name,
    lb.name AS lb_name
FROM
	ngp.hist_activity AS ha
JOIN
	ngp.destinations AS ds
ON
	ha.start_destination_id = ds.id
LEFT JOIN
	ngp.destinationgroups dg
ON
	dg.destination_id = ha.start_destination_id
LEFT JOIN
	ngp.lib_groupings lb
ON
	lb.id = dg.lib_grouping_id
WHERE
	ha.activity = 'ZONING'
AND
	ha.duration >= 5
AND
	ha.startstamp BETWEEN '2020-01-01' AND '2020-09-30'
AND
	ha.start_destination_id IN (
		SELECT
			ds.id
		FROM
			ngp.destinations AS ds
		WHERE
			id IN(
				SELECT 
				destination_id
				FROM
					ngp.destinationgroups dg
				WHERE
					dg.lib_grouping_id IN (2484, 2485, 2486, 2487, 2488, 2489, 2490, 2534, 2541)
			)
	)
    


	