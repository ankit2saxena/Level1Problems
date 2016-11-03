create table Book(
BookNo INTEGER,
Title VARCHAR(30),
Price INTEGER,
primary key(BookNo));

create table Cites(
BookNo INTEGER references Book(BookNo),
CitedBookNo INTEGER references Book(BookNo),
primary key(BookNo,CitedBookNo));

create or replace function get_Jaccard_Count (bno1 integer, bno2 integer)
returns FLOAT AS $JC$
declare 
JCI FLOAT; 
JCU FLOAT;
JC FLOAT;
BEGIN
select count(P.CitedBookNo) from 
(SELECT C1.CitedBookNo from Cites C1 where C1.BookNo = bno1
INTERSECT
SELECT C2.CitedBookNo from Cites C2 where C2.BookNo = bno2) P INTO JCI;

select count(Q.CitedBookNo) from 
(SELECT C1.CitedBookNo from Cites C1 where C1.BookNo = bno1
UNION
SELECT C2.CitedBookNo from Cites C2 where C2.BookNo = bno2) Q INTO JCU;

JC = JCI/JCU;

return JC;
END;
$JC$ LANGUAGE plpgsql;


create or replace function Jaccard(l float, u float)
returns table (book1 integer, book2 integer) AS $$
BEGIN
RETURN QUERY
select C1.BookNo as book1, C2.BookNo as book2
from Cites C1, Cites C2
where C1.BookNo <> C2.BookNo
AND get_Jaccard_Count(C1.BookNo, C2.BookNo) >= l
AND get_Jaccard_Count(C1.BookNo, C2.BookNo) <= u
GROUP BY C1.BookNo, C2.BookNo
order by C1.BookNo, C2.BookNo;
END;
$$ LANGUAGE plpgsql;

select book1, book2 from Jaccard(0,1);
select book1, book2 from Jaccard(0,0);
select book1, book2 from Jaccard(1,1);