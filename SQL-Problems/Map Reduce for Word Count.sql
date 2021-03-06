﻿create table if not exists Documents(
Doc_Id TEXT,
Words TEXT[]
);

insert into Documents values('d1', ARRAY['A','B','C']);
insert into Documents values('d2', ARRAY['B','C','D']);
insert into Documents values('d3', ARRAY['A','E']);
insert into Documents values('d4', ARRAY['B','B','A','D']);
insert into Documents values('d5', ARRAY['E','F','D']);
insert into Documents values('d6', ARRAY['E','F']);

select * from Documents;

------------------------------------------------------------------------
create or replace function mapWC(document_Id TEXT, bag_of_words TEXT[])
RETURNS TABLE(word TEXT, one INTEGER) AS $$
select D1.wd, 1 FROM (select UNNEST(bag_of_words) AS wd) D1;
$$ LANGUAGE SQL;

------------------------------------------------------------------------
create or replace function reduceWC(key_word TEXT, bag_of_ones INTEGER[])
RETURNS TABLE(word TEXT, value INTEGER) AS $$
select key_word, CARDINALITY(bag_of_ones);
$$ LANGUAGE SQL;

------------------------------------------------------------------------
create or replace function Distribution_MapWC() 
RETURNS VOID AS $$
BEGIN	
create table if not exists key_value_WC
(W Text,
one_value INTEGER);

delete from key_value_WC;

insert into key_value_WC
select W1.word, W1.one 
from Documents D1, LATERAL(select M1.word, M1.one from mapWC(D1.doc_Id, D1.Words) M1) W1;
END
$$ LANGUAGE plpgsql;

------------------------------------------------------------------------
select Distribution_MapWC();
select * from key_value_WC;

------------------------------------------------------------------------
create or replace function GroupWC()
RETURNS VOID AS $$
BEGIN
CREATE TABLE IF NOT EXISTS input_reduce(word TEXT, occurrences INTEGER[]);

DELETE FROM input_reduce;

INSERT INTO input_reduce
select distinct W1.W, (SELECT array(select W2.one_value FROM key_value_WC W2 where W2.W = W1.W))
from key_value_WC W1;

END
$$ LANGUAGE plpgsql;
------------------------------------------------------------------------
select GroupWC();
select * from input_reduce;

------------------------------------------------------------------------
select Q.word, Q.value as WORD_COUNT
FROM input_reduce IR, LATERAL(select * from reduceWC(IR.word, IR.occurrences))Q
order by word;