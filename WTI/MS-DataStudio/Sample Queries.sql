Select 
	dev.devicealias as 'Plate Number', 
	lg.name as 'hauler',
	dest.name as 'Homebase', 
	ha.startstamp as 'Start Datetime',
	ha.stopstamp as 'End Datetime',
	ha.duration as'Stay Duration in Mins'
from 
	hist_activity as ha
join 
	devices as dev on dev.id=ha.device_id
join 
	destinations as dest on dest.id=ha.start_destination_id
join 
	destinationgroups as destg on destg.destination_id=dest.id
join 
	devicegroups as devg on devg.device_id=dev.id
join 
	lib_groupings as lg on lg.id=destg.lib_grouping_id
join 
	lib_groupings as lg1 on lg1.id=devg.lib_grouping_id
where 
	ha.startstamp between '2020-01-01' and '2020-01-31'
and 
	lg.parent_id=94 
and 
	lg1.parent_id=94 
and 
	ha.activity ='ZONING' 
and 
	dest.category ='Home Base' 
and 
	ha.duration >=1
group by 
	ha.id;
	
	
	
 -- ACTIVITY SUMMARY WITH GROUP NAMES 
SELECT
	d.devicealias, 
	dg.lib_grouping_id, 
	lb.name, 
	a.datestamp,
	a.event_count, 
	a.activity 
FROM 
	ngp.activity_summary a 
LEFT JOIN 
	ngp.devices d 
ON 
	d.id=a.device_id 
LEFT JOIN 
	ngp.devicegroups dg 
ON 
	dg.device_id = d.id 
LEFT JOIN 
	lib_groupings lb 
ON 
	lb.id = dg.lib_grouping_id 
WHERE 
	a.device_id IN 
		(SELECT 
			device_id 
		FROM 
			ngp.devicegroups 
		WHERE 
			lib_grouping_id=2484
		OR 
			lib_grouping_id=2485
		OR 
			lib_grouping_id=2486 
		OR 
			lib_grouping_id=2487 
		OR 
			lib_grouping_id=2488 
		OR 
			lib_grouping_id=2489 
		OR 
			lib_grouping_id=2490 
		OR 
			lib_grouping_id=2495 
		OR 
			lib_grouping_id=2534 
		OR 
			lib_grouping_id=2541) 
AND 
	(activity = 'IDLE' 
OR 
	activity = 'DISTANCE TRAVELLED' 
OR 
	activity = 'SPEEDING' 
OR 
	activity = 'HARSH ACCELERATION' 
OR 
	activity = 'HARSH BREAK' ) 
AND 
	datestamp BETWEEN '2019-09-01' AND '2020-09-30';	
	
--dwell time
-- SMILSI geofence activity / hist activity
SELECT 
	dg.lib_grouping_id,
	lb.name, 
	REPLACE(ds.name,',',' ') AS geofence_name, 
	ds.category, 
	a.startstamp, 
	a.stopstamp,
	a.duration 
FROM 
	ngp.hist_activity AS a --id, startttime and end time, duration, distance traveled, start destination, end destination, 
JOIN 
	ngp.destinations AS ds --id, client id, name, category, 
ON 
	ds.id = a.start_destination_id 
LEFT JOIN 
	ngp.destinationgroups dg 
ON 
	dg.destination_id = a.start_destination_id 
LEFT JOIN 
	lib_groupings lb 
ON 
	lb.id = dg.lib_grouping_id 
WHERE 
	a.activity = 'ZONING' 
AND 
	a.duration>=5 
AND 
	a.startstamp BETWEEN '2020-01-01' AND '2020-09-30' 
AND 
	a.start_destination_id IN (
		SELECT 
			id 
		FROM 
			ngp.destinations 
		WHERE id IN (
			SELECT 
				destination_id 
			FROM 
				ngp.destinationgroups dg 
			WHERE 
				lib_grouping_id=2484 
			OR 
				lib_grouping_id=2485 
			OR 
				lib_grouping_id=2486 
			OR 
				lib_grouping_id=2487 
			OR 
				lib_grouping_id=2488 
			OR 
				lib_grouping_id=2489 
			OR 
				lib_grouping_id=2490 
			OR 
				lib_grouping_id=2534 
			OR 
				lib_grouping_id=2541 ));
				
				
 -- query travel time for distance matrix 
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
	destg.lib_grouping_id= 1059 
AND 
	histact.startstamp BETWEEN '2020-01-01 00:00:00' AND '2020-09-30 00:00:00';