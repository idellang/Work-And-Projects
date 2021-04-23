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