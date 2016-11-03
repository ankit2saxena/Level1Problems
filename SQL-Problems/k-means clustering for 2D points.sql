create table Points(
PId integer,
x float,
y float,
PRIMARY KEY(Pid)
);

create table km_centroid(
CId integer,
x float,
y float,
PRIMARY KEY(CId)
);

create table Clusters(
PId integer REFERENCES Points(PId),
CId integer REFERENCES km_centroid(CId)
);

-----------------Used to generate random points that have to be clustered.
create or replace function GenRandomPoints(lowerL float, upperL float, count INTEGER)
RETURNS void AS $$
BEGIN

FOR i in 1..count LOOP
INSERT INTO Points
SELECT i, random()*(upperL-lowerL)+lowerL, random()*(upperL-lowerL)+lowerL;
END LOOP;

END
$$ LANGUAGE plpgsql;

-----------------Used to initialize centroids that represent the clusters.
create or replace function InitiateCentroids(lowerL float, upperL float, k INTEGER)
RETURNS void AS $$
BEGIN

FOR i in 1..k LOOP
INSERT INTO km_centroid
SELECT i, random()*(upperL-lowerL)+lowerL, random()*(upperL-lowerL)+lowerL;
END LOOP;

END
$$ LANGUAGE plpgsql;

-----------------Used to assign all the points to the first cluster, initially.
create or replace function AssignClusters(count INTEGER)
RETURNS void AS $$
BEGIN

FOR i in 1..count LOOP
INSERT INTO Clusters
SELECT i, 1;
END LOOP;

END
$$ LANGUAGE plpgsql;

-----------------Code for k-means clustering.
create or replace function kmeans(lowerL float, upperL float, n INTEGER, iterations INTEGER, k INTEGER)
RETURNS void AS $$
BEGIN
--PERFORM GenRandomPoints(lowerL, upperL, n);
--PERFORM InitiateCentroids(lowerL, upperL, k);
--PERFORM AssignClusters(n);

FOR i in 1..iterations LOOP
	FOR j in 1..n LOOP
		UPDATE Clusters
		SET CId = (select KC1.CId from km_centroid KC1 
				order by power(KC1.x-(select x from Points P1 where P1.PId = j),2)+power(KC1.y-(select y from Points P1 where P1.PId = j),2) ASC LIMIT 1)
		where PId = j;
	END LOOP;
	
	UPDATE km_centroid AS KC1
	SET x = Q.newX, y = Q.newY
		FROM (select CLUS1.CId, avg(P1.x) as newX, avg(P1.y) as newY 
			FROM Points P1, Clusters CLUS1
			where P1.PId = CLUS1.PId
			GROUP BY (CLUS1.CId)) Q
	where KC1.CId = Q.CId;
END LOOP;	
END
$$ LANGUAGE plpgsql;

--Generate 100 random points with lower bound of 0.00 and upper bound of 100.00
select GenRandomPoints(0.00,100.00,100);

--Initialize centroids with k = 4
select InitiateCentroids(0.00,100.00,4);

--Assign the 100 points to the first cluster.
select AssignClusters(100);

--Execute the k-means code for k = 4 and 100 points.
select kmeans(0.00,100.00,100,10,4);

select * from km_centroid;