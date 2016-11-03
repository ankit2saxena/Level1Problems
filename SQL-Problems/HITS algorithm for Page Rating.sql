create table Nodes(
NId INTEGER,
auth FLOAT,
hub FLOAT,
PRIMARY KEY(NId)
);

create table Graph(
source INTEGER REFERENCES Nodes(NId),
target INTEGER REFERENCES Nodes(NId)
);

insert into Nodes values(1,1,1);
insert into Nodes values(2,1,1);
insert into Nodes values(3,1,1);
insert into Nodes values(4,1,1);
insert into Nodes values(5,1,1);

insert into Graph values(1,2);
insert into Graph values(1,3);
insert into Graph values(1,5);
insert into Graph values(3,2);
insert into Graph values(3,4);
insert into Graph values(4,1);
insert into Graph values(4,2);
insert into Graph values(5,4);


create or replace function HITS(k INTEGER)
returns void AS $$
DECLARE size_nodes INTEGER;
DECLARE norm FLOAT;
BEGIN
select count(1) from Nodes INTO size_nodes;

for i in 1..k LOOP
	UPDATE Nodes AS N1
	SET AUTH = new_Auth
	FROM (SELECT N1.NId, Q1.sum as new_Auth
		FROM Nodes N1, LATERAL(select sum(N3.hub) FROM Nodes N3, Graph G3 where N3.NId = G3.target AND G3.source = N1.NId) Q1) Q2
	WHERE N1.NId = Q2.NId;
	
	select sqrt(sum(power(auth,2))) from Nodes INTO norm;
	UPDATE Nodes AS N1 SET AUTH = AUTH/norm;
	select 0 into norm;

	UPDATE Nodes AS N1
	SET HUB = new_Hub
	FROM (SELECT N1.NId, Q1.sum as new_Hub
		FROM Nodes N1, LATERAL(select sum(N3.auth) FROM Nodes N3, Graph G3 where N3.NId = G3.source AND G3.target = N1.NId) Q1) Q2
	WHERE N1.NId = Q2.NId;
	
	select sqrt(sum(power(hub,2))) from Nodes INTO norm;
	UPDATE Nodes AS N1 SET HUB = HUB/norm;
	select 0 into norm;
END LOOP;
END
$$ LANGUAGE plpgsql;

select HITS(10);
 
select * from Nodes;