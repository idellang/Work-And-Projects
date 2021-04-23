LOAD CSV WITH HEADERS
FROM 'file:///nestle_bookings_4_neo4j.csv'
AS line
MERGE(l1:Location{name:line.pickup_name})
MERGE(l2:Location{name:line.dropoff_name})
ON CREATE SET
	l1:Pickup,
    l2:Dropoff


LOAD CSV WITH HEADERS
FROM 'file:///nestle_bookings_4_neo4j.csv'
AS line
MATCH(l1:Location{name:line.pickup_name})
MATCH(l2:Location{name:line.dropoff_name})
MERGE(l1)-[t:TRIP{trip_number:line.trip_number}]->(l2)
ON CREATE SET
	t.so_number = line.so_number,
    t.pickup_arrival = datetime({ epochMillis: apoc.date.parse(line.pickup_arrival, 'ms', 'yyyy-MM-dd HH:mm:ss')})
	

-- pickup locations as dropoff_name
MATCH (p1:Pickup)-[t:TRIP]->(p2:Pickup)
RETURN p1.name AS pickup_location, t.trip_number, p2.name AS dropoff_location

-- distinct routes from PH meycauayan
MATCH path = (l1:Location)-[:TRIP]->(l2:Location)
WHERE l1.name = 'PH Meycauayan Grocery - Source'
RETURN distinct l1.name, l2.name


-- unique locations from meycauayan grocery source
MATCH (l1:Location)-[t:TRIP]->(l2:Location)
WHERE l1.name = 'PH Meycauayan Grocery - Source'
WITH  l1.name AS l1_name, l2.name AS l2_name, max(t.trip_number) AS trip_number
WITH collect(trip_number) AS trip_number_collect //make as list
MATCH path = ((:Location)-[t:TRIP]->(:Location))
WHERE t.trip_number IN trip_number_collect
RETURN path


-- unique locations for dropoff
MATCH (l1:Location)-[t:TRIP]->(l2:Location)
WHERE l2.name CONTAINS 'Calbayog'
WITH  l1.name AS l1_name, l2.name AS l2_name, max(t.trip_number) AS trip_number
WITH collect(trip_number) AS trip_number_collect //make as list
MATCH path = ((:Location)-[t:TRIP]->(:Location))
WHERE t.trip_number IN trip_number_collect
RETURN path


-- pickups that are also dropoffs 
MATCH(p:Location)-[:TRIP]->(d:Pickup)
WITH p.name AS pickup_name, collect(DISTINCT d.name) AS pickup_dropoffs
RETURN pickup_name, pickup_dropoffs

MATCH(p:Location)-[:TRIP]->(d:Location)
WITH p.name AS pickup_name, COUNT(DISTINCT d.name) AS num_dropoffs
RETURN pickup_name, num_dropoffs
ORDER BY num_dropoffs DESC

--list of dropoffs per pickup location 
MATCH(p:Location)-[:TRIP]->(d:Location)
WITH p.name AS pickup_name, COLLECT(DISTINCT d.name) AS list_dropoffs, COUNT(DISTINCT d.name) AS num_dropoffs
RETURN pickup_name, list_dropoffs
ORDER BY num_dropoffs DESC

--by pickup location, and date
MATCH(p:Pickup)-[t:TRIP]->(d:Location)
WITH
	p.name AS pickup_name,
    t.pickup_arrival.day AS day,
    t.pickup_arrival.month AS month,
    COUNT(DISTINCT d.name) AS num_trips
RETURN
	pickup_name, day, month, num_trips
ORDER BY
	num_trips DESC
	
-- pickups that are also dropoffs