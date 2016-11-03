--Parent_Child
create table Parent_Child(
PId INTEGER,
CPId INTEGER
);

insert into Parent_Child values(1,2);
insert into Parent_Child values(1,3);
insert into Parent_Child values(2,4);
insert into Parent_Child values(2,5);
insert into Parent_Child values(3,6);
insert into Parent_Child values(3,7);
insert into Parent_Child values(4,8);
insert into Parent_Child values(4,9);
insert into Parent_Child values(4,10);
insert into Parent_Child values(6,11);
insert into Parent_Child values(7,12);
insert into Parent_Child values(7,13);
insert into Parent_Child values(8,14);
insert into Parent_Child values(9,15);
insert into Parent_Child values(10,16);
insert into Parent_Child values(10,17);
insert into Parent_Child values(12,18);
insert into Parent_Child values(12,19);
insert into Parent_Child values(13,20);

select * from Parent_Child;

-----------------
create or replace function calcDistanceToRoot(root INTEGER, distance INTEGER)
RETURNS void AS $$
DECLARE i INTEGER;
BEGIN

create table if not exists distanceToRoot(
PId INTEGER,
distance INTEGER);

insert into distanceToRoot
select CPId, distance from Parent_Child where PId = root;

select (distance+1) into distance;

for i in (select CPId FROM Parent_Child where PId = root) LOOP
	PERFORM calcDistanceToRoot(i,distance);
END LOOP;

END
$$ LANGUAGE plpgsql;

-----------------
create or replace function findSameGen()
RETURNS void AS $$ 
DECLARE root INTEGER;
BEGIN

select PId from Parent_Child EXCEPT select CPId from Parent_Child INTO root;
PERFORM calcDistanceToRoot(root,1);


create table if not exists SameGenPairs(
CPId1 INTEGER,
CPId2 INTEGER);

insert into SameGenPairs
SELECT D1.pid, D2.pid 
FROM distanceToRoot D1, distanceToRoot D2 
where D1.PId <> D2.PId AND D1.distance = D2.distance
order by D1.distance, D1.pid, D2.pid;

END
$$ LANGUAGE plpgsql;

select findSameGen();
select CPId1, CPId2 from SameGenPairs;

--delete from distancetoRoot;
--delete from SameGenPairs;