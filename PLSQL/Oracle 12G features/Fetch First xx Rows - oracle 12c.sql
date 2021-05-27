
PROMPT ********* a ****************
drop table ttop_a;
create table ttop_a as
select a.id_rel
       , sum(amt_fund) total
from 
  (
   select distinct 
     p.id_rel
   , p.nbr_fund
   , p.id_gift
   , p.code_pmt_form
   , p.code_exp_type
   , p.amt_fund
   from q_production_id p
   where p.code_unit = 'CSE'
   AND p.year_fiscal = 2015
   and p.code_recipient in ('U','F','M')
   and p.code_anon in ('0','1')
   ) a 
group by a.id_rel
--having sum(amt_fund) >= 100.00
;
select count (*) from ttop_a;--4109
select * from ttop_a;



PROMPT *********** b *************
drop table ttop_b;
create table ttop_b as 
select a.id_demo
from 
  (
   select distinct p.id_demo
   from q_production_id p 
   JOIN q_individual i ON i.id_demo = p.id_demo
   where p.code_clg = 'CSE'
   AND p.year_fiscal = 2015
   and p.code_recipient in ('U','F','M')
   and p.code_anon in ('0','1') 
   AND i.year_death IS NULL 
   AND i.code_anon < 2
   ) a
/

select count(*) from ttop_b;--4507
select * from ttop_b;



PROMPT ********** stacker *************
EXEC qstackerrel('ttop_b','ttop_c') ;
select count(*) from ttop_c;--3713
select * from ttop_c;



PROMPT *********** d. FETCH FIRST XX ROWS ONLY *************
drop table ttop_d;
create table ttop_d as 
select s.*
       , t.total
from ttop_c s 
join ttop_a t on  s.id_rel = t.id_rel
ORDER BY t.total DESC 
FETCH  first 20 rows only;


select * from ttop_d;--20

PROMPT *********** e FETCH FIRST xxx ROWS  WITH TIES **************************
drop table ttop_e;
create table ttop_e as 
select s.*
       , t.total
       , ROWNUM
from ttop_c s 
join ttop_a t on  s.id_rel = t.id_rel
ORDER BY t.total DESC 
FETCH  first 20 rows WITH TIES;

select * from ttop_e;--



PROMPT *********** f. fetch next/first   xx percent rows only; **************************
drop table ttop_f;
create table ttop_f as 
select s.*
       , t.total
from ttop_c s 
join ttop_a t on  s.id_rel = t.id_rel
ORDER BY t.total DESC 
FETCH  first 15 percent rows only;


select * from ttop_f;--186




