--******************* fnd_kt_201801972_v1.SQL ***********************************
--purpose: determine how many donors crossed $25K milestone in CY2018
--author: Abdi Jibril
--date: 12-Jul-2018
--original Query: 201801972 
--*********************************************************************************


--a
--drop table t201801972a;
--create table t201801972a as
with temp_a as 
(
    SELECT a.*
           , CASE WHEN SUM(amt_fund) OVER (PARTITION BY id_rel ORDER BY date_tran)>= 25000  
                        THEN 'Y'
                   ELSE 'N'
            END AS chckpoint 
    from(
         select distinct 
             p.id_rel
           , p.nbr_fund
           , p.id_gift
           , p.code_pmt_form
           , p.code_exp_type
           , p.amt_fund
           , p.date_tran
        from q_production_id p
             join decode_exp_type et on et.code_exp_type = p.code_exp_type
        where 1=1 
        and p.code_recipient != 'S'
        and p.code_anon in ('0','1')
        and et.flag_deferred = 'N' 
        and et.code_exp_type not in ('DR','DI')
        --and p.id_rel = 200098555
     )a 
 )
SELECT id.id_demo
       , namer.label(id.id_demo) donor_name
       , w.*
FROM( 
        SELECT 
            ta.id_rel
            , SUM(ta.amt_fund)                                  AS total_amt
            , MAX(ta.chckpoint)                                 AS chkpoint  
            , MIN(CASE WHEN ta.chckpoint = 'Y' THEN date_tran END) AS milestone_date
        FROM temp_a ta 
        GROUP BY ta.id_rel
      )w
      join q_id id on id.id_rel = w.id_rel 
WHERE 1=1 
AND w.chkpoint = 'Y' 
AND extract(year from w.milestone_date) = 2017
; 

select * from t201801972a; --1077  

-- stacker  
exec qstackerrel('t201801972a','t201801972b','N','N');
select count(*) from t201801972b;--701
select * from t201801972b;


--$$$
drop table t201801972c;
create table t201801972c as 
select distinct 
       s.*
       , t.total_amt
       , t.milestone_date
       --, t.chkpoint
from t201801972b s 
     join t201801972a t on  s.id_rel = t.id_rel
;
select * from t201801972c;--701  
PROMPT ******************* END TWO PRONG ***************************************


--insert_inbox
exec batchman.ri_tapi.delete_report('t201801972c');
COMMIT;
exec batchman.ri_tapi.add_report('t201801972c','$25K+ donors ltd milestone First time in 2017 calendar Year','KROTH,AIJIBRIL');
COMMIT;

SELECT * FROM ri_report_user WHERE id_report = 't201801972c';
SELECT * FROM batchman.ri_scheduled_report WHERE id_report = 't201801972c';

exec batchman.ri_main.send_to_remote_inbox('t201801972c');
COMMIT;
exec batchman.ri_tapi.delete_report('t201801972c');
COMMIT; 


---helper

 --select * from decode_exp_type et where et.code_exp_type in ('DR','DI');
