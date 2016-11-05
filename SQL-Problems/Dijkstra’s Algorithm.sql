create table Graph5(
source INTEGER,
target INTEGER,
weight INTEGER
);

create table if not exists DistanceToSource(
TARGET INTEGER,
DISTANCE INTEGER);

insert into Graph5 values(0,1,2);
insert into Graph5 values(0,4,10);
insert into Graph5 values(1,2,3);
insert into Graph5 values(1,4,7);
insert into Graph5 values(2,3,4);
insert into Graph5 values(3,4,5);
insert into Graph5 values(4,2,6);

--select * from Graph5;

-----------------
create or replace function calcDistanceToSource(n INTEGER, dist INTEGER)
RETURNS void AS $$ 
DECLARE i INTEGER;
BEGIN

insert into DistanceToSource
select G.target, (G.weight+dist) FROM Graph5 G where G.source = n;

for i in (select G.target FROM Graph5 G where G.source = n) LOOP
	
	IF (EXISTS (select G.target FROM Graph5 G where G.source = i AND G.target NOT IN (select TARGET from DistanceToSource) )) THEN
		select min(D.distance) from DistanceToSource D where D.target = i INTO dist;
		PERFORM calcDistanceToSource(i,dist);
	END IF;
	
END LOOP;

END
$$ LANGUAGE plpgsql;

-----------------
create or replace function Dijkstra(n INTEGER)
RETURNS TABLE(TARGET INTEGER, DISTANCE INTEGER) AS $$

insert into DistanceToSource values(n,0);

select calcDistanceToSource(n,0);

select DTS.target, min(DTS.distance) from DistanceToSource DTS
GROUP BY DTS.target
order by DTS.target;

$$ LANGUAGE SQL;

select Dijkstra(0);