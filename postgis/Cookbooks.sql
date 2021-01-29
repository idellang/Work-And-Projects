--compute for distance
SELECT
	c.name,
	SUM(ST_LENGTH(geography(t.the_geom)))/1000 AS dist_km
FROM
	chp03.tracks AS t
JOIN
	chp01.countries AS c
ON
	ST_INTERSECTS(t.the_geom, c.the_geom)
GROUP BY
	c.name
	
--make valid
UPDATE
	chp03.countries
SET 
	the_geom = ST_MAKEVALID(the_geom)
WHERE
	ST_ISVALID(the_geom)= false;	
	
	
-- distance between two cities
SELECT
	c1.name,
	c2.name,
	ST_DISTANCE(ST_TRANSFORM(c1.the_geom, 900913), ST_TRANSFORM(c2.the_geom, 900913))/1000 AS distance_900913
FROM
	chp03.cities AS c1
CROSS JOIN
	chp03.cities AS c2
WHERE 
	c1.pop_2000 >1000000
AND
	c2.pop_2000 >1000000
AND
	c1.name < c2.name
ORDER BY
	distance_900913 ASC	

--cities distance	
WITH cities AS(
	SELECT 
		name,
		the_geom
	FROM
		chp03.cities
	WHERE 
		pop_2000 > 100000
)
SELECT
	c1.name,
	c2.name,
	ST_DISTANCE(ST_TRANSFORM(c1.the_geom, 900913), ST_TRANSFORM(c2.the_geom, 900913))/1000 AS distance_900913
FROM
	cities c1 CROSS JOIN cities c2
WHERE 
	c1.name < c2.name
ORDER BY
	distance_900913 ASC	
	
--using geography
WITH cities AS(
	SELECT
		name,
		the_geom
	FROM
		chp03.cities
	WHERE pop_2000 > 1000000
)
SELECT
	c1.name,
	c2.name,
	ST_DISTANCE(ST_TRANSFORM(c1.the_geom, 900913),ST_TRANSFORM(c2.the_geom, 900913))/1000
		AS d_900913,
	ST_DISTANCE(geography(c1.the_geom), geography(c2.the_geom))/1000 AS d_4326_geography
FROM
	cities c1
CROSS JOIN
	cities c2
WHERE 
	c1.name < c2.name

--intersection of  two rivers
SELECT
	r1.gid AS gid1,
	r2.gid AS gid2,
	ST_INTERSECTION(r1.the_geom, r2.the_geom) AS the_geom,
	r1.the_geom AS geom_r1,
	r2.the_geom AS geom_r2,
	ST_GEOMETRYTYPE(ST_INTERSECTION(r1.the_geom, r2.the_geom)) AS geometry_type
FROM
	chp03.rivers r1
JOIN
	chp03.rivers r2
ON
	ST_INTERSECTS(r1.the_geom, r2.the_geom)
WHERE
	r1.gid != r2.gid

--extract only points
SELECT 
	gid1,
	gid2,
	the_geom::geometry(Multipoint, 4326),
	ST_GEOMETRYTYPE(the_geom)
FROM(
	SELECT
		r1.gid AS gid1,
		r2.gid AS gid2,
		CASE
			WHEN 
				ST_GEOMETRYTYPE(ST_INTERSECTION(r1.the_geom, r2.the_geom)) != 'ST_GeometryCollection'
			THEN 
				ST_MULTI(ST_INTERSECTION(r1.the_geom, r2.the_geom))
			ELSE 
				ST_COLLECTIONEXTRACT(ST_INTERSECTION(r1.the_geom, r2.the_geom), 1)
			END AS the_geom
	FROM
		chp03.rivers r1
	JOIN
		chp03.rivers r2
	ON
		ST_INTERSECTS(r1.the_geom,r2.the_geom)
	WHERE
		r1.gid != r2.gid
) AS only_points_geometry

--10 closest distance to search points
SELECT 
	ST_Distance(searchpoint.the_geom, addr.the_geom) AS dist, 
	* 
FROM
chp04.knn_addresses addr,
(SELECT ST_Transform(ST_SetSRID(ST_MakePoint(-81.738624, 41.396679),
4326), 3734) AS the_geom) searchpoint
ORDER BY ST_Distance(searchpoint.the_geom, addr.the_geom)
LIMIT 10;

SELECT
	ST_DISTANCE(searchpoint.the_geom, addr.the_geom) AS dist,
	*
FROM
	chp04.knn_addresses AS addr,
	(SELECT ST_TRANSFORM(ST_SETSRID(ST_MAKEPOINT(-81.738624, 41.396679), 4326), 3734) AS the_geom) AS searchpoint
WHERE
	ST_DWITHIN(searchpoint.the_geom, addr.the_geom, 200)
ORDER BY
	ST_Distance(searchpoint.the_geom, addr.the_geom)
LIMIT
	10

--using index
SELECT
	ST_DISTANCE(searchpoint.the_geom, addr.the_geom) AS dist,
	*
FROM
	chp04.knn_addresses AS addr,
	(SELECT ST_Transform(ST_SetSRID(ST_MakePoint(-81.738624, 41.396679),
	4326), 3734) AS the_geom) searchpoint
ORDER BY
	addr.the_geom <-> searchpoint.the_geom
LIMIT 10


-- angle
CREATE OR REPLACE FUNCTION chp04.angle_to_street (geometry) RETURNS double
precision AS $$
WITH index_query as (SELECT ST_Distance($1,road.the_geom) as dist,
degrees(ST_Azimuth($1, ST_ClosestPoint(road.the_geom, $1))) as azimuth FROM
chp04.knn_streets As road ORDER BY $1 <#> road.the_geom limit 5)
SELECT azimuth FROM index_query ORDER BY dist
LIMIT 1;
$$ LANGUAGE SQL;	

-- angle query
CREATE TABLE chp04.knn_address_points_rot AS SELECT addr.*,
chp04.angle_to_street(addr.the_geom) FROM chp04.knn_addresses addr;