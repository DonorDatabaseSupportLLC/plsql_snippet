--******************* cse_dp_202000332_v2.SQL ***********************************
--purpose:  CSE Deans Club Solicitation Review List Fall FY19
--author: Abdi Jibril
--date: 05-Jan-2018
--original Query: 201802622 
--*********************************************************************************
select * from cse_gift_range;
 

-- ***********************************************************************
--B. Build formula BASED on AVG giving of all Fiscal Years for following: 
--1. Ask Ladder 1-3: see sheets
--2. amt_ask (start): avg_amt if >= $1K. Else $1k
--3. monthy ask (what is it)? 12 months --  divide ask amt by 12 months. 
-- ***********************************************************************
 

DROP TABLE t202000332_dt;
CREATE TABLE t202000332_dt AS 
SELECT
      to_number(to_char(add_months(day,6),'yyyy'))- 5     as prev_fy_3 
      , to_number(to_char(add_months(day,6),'yyyy'))- 4   as prev_fy_2
      , to_number(to_char(add_months(day,6),'yyyy'))- 3   as prev_fy_1  
      , to_number(to_char(add_months(day,6),'yyyy'))- 2   as prev_fy
      , to_number(to_char(add_months(day,6),'yyyy'))- 1	  as last_fy
      , to_number(to_char(add_months(day,6),'yyyy'))- 0   as curr_fy
      , trunc(sysdate)-30                                 as last_30_days
      , TRUNC(DAY)                                        as day
FROM(SELECT SYSDATE AS DAY FROM dual)
;
SELECT * FROM t202000332_dt; 



--DROP TABLE t202000332_outlier;
--CREATE TABLE t202000332_outlier AS
--Find Speicific gift that is an outlier (outside of 2 stddev of the mean (-2/+2)
WITH temp_giving 
AS(
    SELECT id_rel 
      , id_gift
      , year_fiscal 
      , sum(amt_fund) as amt_fund 
    FROM(SELECT DISTINCT 
             p.id_rel
              , p.nbr_fund
              , p.id_gift
              , p.code_pmt_form
              , p.code_exp_type
              , p.amt_fund
              , p.year_fiscal
              , p.id_expectancy     
         FROM q_receipted_id p
         WHERE p.code_clg = 'CSE'
         AND p.year_fiscal >= (SELECT dt.prev_fy_3 FROM t202000332_dt dt) --2015
         AND p.code_recipient != 'S'
         AND p.code_anon IN ('0', '1')
         --AND p.id_rel = 930324278 
         --AND p.id_gift = 112014100800201
      )
  WHERE 1=1 
  GROUP BY id_rel, year_fiscal, id_gift    
)                                              --select id_rel, count(*) from temp_giving group by id_Rel having count(*) > 5;
--******************************************** 
--ver 1: MAD - median absolute deviation (MAD)
--******************************************** 
, temp_mad 
as(select 
     z.*
     , medians + mad * 3 as upper_threshold 
     , medians - mad * 3 as lower_threshold 
   from(
        SELECT 
             w.*
              , round(1.4826* (median(abs(amt_fund - medians)) over (partition by id_rel))) as mad 
              --, round(1.4826 *3* (median(abs(amt_fund - medians)) over (partition by id_rel))) as mad_3 --select 95 * 1.4826 * 3 total from dual; --422.541
        FROM(SELECT 
                a.id_rel 
                , a.id_gift
                , amt_fund 
                , year_fiscal
                , round(median(amt_fund)over(partition by id_rel))           as medians 
             FROM temp_giving a 
            )w
    )z
)
 select p.*
         , case 
            when p.amt_fund between lower_threshold
                                and upper_threshold
            then 'N'
            else 'Y'
            end as flag_outlier     
 from temp_mad p 
 where 1=1 
 and id_rel = 930324278 
 --and amt_fund between lower_threshold and upper_threshold
 ;

--***************************************
--ver 2:  stddev +/- avg
--***************************************

/*, temp_std_deviation  
AS(
   SELECT 
        w.*
        , mean - 3 * std_dev  as lower_threshold_3
        , mean + 3 * std_dev  as upper_threshold_3 
   FROM(
        SELECT 
            a.id_rel 
            , amt_fund 
            , year_fiscal
            , round(avg(amt_fund)over(partition by id_rel))         as mean 
            , round(stddev_pop(amt_fund)over(partition by id_rel))  as std_dev          
         FROM temp_giving a
      )w 
)
select p.*
       , case 
            when p.amt_fund between lower_threshold_3 
                                and upper_threshold_3
            then 'N'
            else 'Y'
            end as flag_outlier    
from temp_std_deviation p 
where  p.id_rel = 930324278 
--and amt_fund between lower_threshold_3  and upper_threshold_3;
;*/


--ver 3:  Z Score method
, temp_std_deviation  
AS(
   SELECT 
        w.*
        ,  round((amt_fund - mean)/ std_dev,2)   as z_score
   FROM(
        SELECT 
            a.id_rel 
            , amt_fund 
            , year_fiscal
            , round(avg(amt_fund)over(partition by id_rel))     as mean 
            , round(stddev_pop(amt_fund)over(partition by id_rel))  as std_dev  --select 5000-208/473 from dual;        
         FROM temp_giving a
      )w 
)
select p.*
       , case 
            when z_score > 3 
              or z_score < -3
            then 'Y'
            else 'N'
            end as flag_outlier    
from temp_std_deviation p 
where  p.id_rel = 930324278 
order by amt_fund desc 
--and amt_fund between lower_threshold_3  and upper_threshold_3;
;


 --*************************************************************************
      PROMPT - END 
  --*************************************************************************

select * from t202000332_outlier a where a.outlier = 'Y';
select distinct id_rel from t202000332_outlier a where a.outlier = 'Y';--344
select * from t202000332_outlier a where a.id_rel =  100038583; --100038583 --930330095;


--A.  get total per fy, combined total FY, count FY & code/desc per FY  
DROP TABLE t202000332a;
CREATE TABLE t202000332a AS
WITH temp_a 
AS(SELECT id_rel 
            , year_fiscal 
            , SUM(amt_fund) AS ltd_rel_fy
   FROM (SELECT DISTINCT 
                 p.id_rel
                , p.nbr_fund
                , p.id_gift
                , p.code_pmt_form
                , p.code_exp_type
                , p.amt_fund
                , p.year_fiscal
                , p.id_expectancy 
          FROM q_receipted_id p
          WHERE p.code_clg = 'CSE'
          AND p.year_fiscal >= (SELECT dt.prev_fy_3 FROM t202000332_dt dt) --2015
          AND p.code_recipient != 'S'
          AND p.code_anon IN ('0', '1')
        ) a
   GROUP BY id_rel, year_fiscal
 )
select 
    w.*
    , ta.year_fiscal 
    , ta.ltd_rel_fy 
    , cs.code_giving_range as fy_code_range   
    , cs.desc_giving_range as fy_desc_range      
from(select 
        id_rel 
        , count(distinct year_fiscal) as cnt_fy_given 
        , sum(ltd_rel_fy)             as total_all_fy 
     from temp_a 
     group by id_rel 
    )w 
    join temp_a ta 
         on ta.id_rel = w.id_rel 
    cross join cse_gift_range cs
where ta.ltd_rel_fy between cs.amt_range_min   --select * from cse_gift_range;
                       and cs.amt_range_max
;

SELECT COUNT(*), COUNT(distinct id_rel) FROM t202000332a; --21190/8625  --21223/8634
SELECT * FROM t202000332a;


--a
DROP TABLE t202000332b;
CREATE TABLE t202000332b AS
SELECT DISTINCT p.id_demo
FROM q_receipted_id p
    JOIN q_individual i ON i.id_demo = p.id_demo 
WHERE p.code_clg = 'CSE'
AND p.year_fiscal >= (select dt.prev_fy_3 from t202000332_dt dt)  --2015
AND p.code_recipient != 'S'
AND p.code_anon IN ('0', '1')
AND i.code_anon IN ('0', '1')
AND i.year_death IS NULL 
;

SELECT COUNT (*) FROM t202000332b;--7919 --8199 --7725 --8839 --8860 --9323 --9330
SELECT * FROM t202000332b;


-- stacker 
EXEC qstackerrel('t202000332b','t202000332c','N','N');
SELECT COUNT (*) FROM t202000332c;--6649 --6870 --7241 --7256 --7654
SELECT * FROM t202000332c;


--d
DROP TABLE t202000332d;
CREATE TABLE t202000332d AS
SELECT s.*
       , t.year_fiscal 
       , t.ltd_rel_fy
FROM t202000332c s 
    JOIN t202000332a t ON s.id_rel = t.id_rel 
;

SELECT COUNT(*) FROM t202000332d;--16627 --18458 --18804 --17177 --17274  --19171 --19200
SELECT * FROM t202000332d d where d.id_demo = 300089521 ;   


--pool 
DROP TABLE t202000332_pool;
CREATE TABLE t202000332_pool AS
WITH temp_exclude 
AS(SELECT f.id_rel  
   FROM t202000332d f
        CROSS JOIN t202000332_dt dt
   WHERE 1=1 
   AND((f.year_fiscal = dt.curr_fy AND f.ltd_rel_fy >= 1000)          --already given Current FY $1k+ & qualified for CSE Deans' Club
        OR 
       (f.ltd_rel_fy >= 50000))                                        --major gift donor: $50K+ any fiscal year
   UNION 
   SELECT pp.id_rel  
   FROM q_receipted_id pp 
   WHERE pp.code_clg = 'CSE'
   AND pp.code_recipient != 'S'
   AND pp.code_anon IN ('1','0')
   AND pp.date_tran >= (SELECT dt.last_30_days FROM t202000332_dt dt)   --gave MITD last 30 days
   UNION 
   SELECT id.id_rel 
   FROM group_part gp 
       JOIN q_id id ON id.id_demo = gp.id_demo  
   WHERE gp.nbr_group IN (175,176,177,188,190,197,198,232,8306,7581)  --Board members  
   UNION 
   SELECT p.id_rel                                                    --tribute only donors             
   FROM q_production_id p
        JOIN in_honor h ON h.id_gift = p.id_gift 
   WHERE p.code_recipient != 'S'
   AND p.code_unit = 'CSE'
   AND NOT EXISTS(SELECT 1                          
                  FROM q_production_id pp
                      LEFT JOIN in_honor hh ON hh.id_gift = pp.id_gift 
                  WHERE pp.code_recipient != 'S'
                  AND pp.code_unit = 'CSE'
                  AND hh.id_gift IS NULL 
                  AND pp.id_rel = p.id_rel
                  )
)
, temp_pool
AS(SELECT id_demo, id_rel  
   FROM t202000332d t
   WHERE 1=1 
   AND((t.year_fiscal in (2015,2016)         -- 5th & 6th year - hard corded
        AND 
        t.ltd_rel_fy >= 1000)
        OR 
       (t.ltd_rel_fy >= 500 
        AND 
        t.year_fiscal >= (SELECT dt.prev_fy_1 FROM t202000332_dt dt) /*2017*/))   
   UNION 
   SELECT id_spouse, id_rel  
   FROM t202000332d t
   WHERE id_spouse != 0  
   AND((t.year_fiscal in (2015,2016)          -- 5th & 6th year - hard corded
        AND 
        t.ltd_rel_fy >= 1000)
        OR 
       (t.ltd_rel_fy >= 500 
        AND 
        t.year_fiscal >= (SELECT dt.prev_fy_1 FROM t202000332_dt dt) /*2017*/))   
)
SELECT w.id_demo, i.id_rel 
FROM( 
     SELECT tp.id_demo 
     FROM temp_pool tp
     WHERE 1=1 
     AND NOT EXISTS(SELECT 1 
                    FROM temp_exclude te 
                    WHERE te.id_rel = tp.id_rel)
     UNION 
     SELECT id.id_demo 
     FROM  q_prospect p 
           JOIN q_id id ON id.id_demo_master = p.id_prospect_master 
     WHERE 1=1 
     --AND p.flag_actively_managed = 'Y'
     AND p.code_team_member in ('M','T')
     AND p.code_unit = 'CSE'
     AND p.code_team_member_status = 'A'
  )w
   join q_individual i ON i.id_demo = w.id_demo  
where i.year_death IS NULL 
and i.code_anon IN ('0','1')
and not exists (select 1 
                from all_subscription_v asv
                where 1=1
                and asv.id_demo = i.id_demo 
                and asv.code_unit = 'CSE' 
                and asv.code_channel = 'M'             --M = Mail  --E = Email  --P = Phone
                and asv.code_subscript_type = 'S'      --E = Event  --P = Publication  --S = Solicitation  --V = Survey
                and asv.code_subscription is null      --Use for general subscription level
                and asv.code_subscript_opt_type = 'OUT'
                and not exists (select 1 
                                from all_subscription_v asv2
                                where 1=1
                                  and asv.id_demo = asv2.id_demo
                                  and asv.code_unit = asv2.code_unit
                                  and asv.code_channel = asv2.code_channel
                                  and asv.code_subscript_type = asv2.code_subscript_type
                                  and nvl(asv.code_subscription,'$') = nvl(asv2.code_subscription,'$')
                                  and asv2.code_subscript_opt_type = 'IN'
                                 ))
;


SELECT COUNT(*),COUNT(DISTINCT id_demo) FROM t202000332_pool; --1909 --2709 --2282 --2376 --2376  --2251
SELECT * FROM t202000332_pool; 
 
 
--pool stacker  
EXEC qstackerrel('t202000332_pool','t202000332_qstk','N','N'); 
SELECT COUNT(*) FROM t202000332_qstk;  --1185 --1834 --1446 --1552 --1548 --1459   
SELECT * FROM t202000332_qstk;



--$$$  
--DROP TABLE t202000332_final;
--CREATE TABLE t202000332_final AS
with temp_ask_formula_pool 
as(select
        z.*
        , cs.code_giving_range  as code_avg_all_fy 
        , cs.desc_giving_range  as desc_avg_all_fy 
        , case
              when z.avg_all_fy >= 20000 then 0
              when z.avg_all_fy >=  1000 then z.avg_all_fy  
              else 1000 
              end as amt_ask  
        , case 
             when z.avg_all_fy >= 20000 then 'Y'
             else 'N'
             end as exclude_solicit 
   from(select 
           w.*
           , round(w.total_all_fy/w.cnt_fy_given) as avg_all_fy 
        from(select 
               id_rel 
               , count(distinct year_fiscal) as cnt_fy_given 
               , sum(ltd_rel_fy)             as total_all_fy 
           from t202000332a  
           group by id_rel 
         )w 
      )z 
      cross join cse_gift_range cs 
  where z.avg_all_fy between cs.amt_range_min   --select * from cse_gift_range;
                         and cs.amt_range_max   
)
, temp_ask_formula 
as(select distinct 
         ta.id_rel 
         , ta.avg_all_fy
         , ta.amt_ask        
         , case 
               when ta.code_avg_all_fy <= 13 then 0
               when ta.code_avg_all_fy <= 23 then ta.amt_ask + 1000      
               when ta.code_avg_all_fy <= 37 then ta.amt_ask +  500      --38 then ta.amt_ask + 500.00  fix: should be <= 37 
               when ta.code_avg_all_fy <= 44 then ta.amt_ask +  250 
               else 0.69                                     
               end as ask_ladder_1   
         , case
               when ta.code_avg_all_fy <= 13 then 0
               when ta.code_avg_all_fy <= 23 then ta.amt_ask + 2000 
               when ta.code_avg_all_fy <= 37 then ta.amt_ask + 1000 
               when ta.code_avg_all_fy <= 44 then ta.amt_ask +  500 
               else 0.69                                     
               end as ask_ladder_2 
         , 0 ask_ladder_3 
         , case when ta.avg_all_fy >= 20000 then 0
                when ta.avg_all_fy  >  1000 then round(ta.avg_all_fy/12) 
                else 100.00 
                end as month_ask_amt
         , ta.total_all_fy
         , ta.code_avg_all_fy
         , ta.desc_avg_all_fy  
         , ta.exclude_solicit
  from temp_ask_formula_pool ta 
) --select * from temp_ask_formula where   id_rel in (800567832);
, temp_open_pl 
AS(SELECT id.id_rel 
   FROM q_expectancy_id p
       JOIN q_id id ON id.id_demo = p.id_demo 
   WHERE p.code_recipient != 'S'
   AND p.code_anon IN ('0','1')
   AND p.flag_closed = 'N'
   AND p.code_exp_type = 'PL'
)
, temp_recuring 
AS(SELECT id.id_rel 
   FROM recur_fund rf 
        JOIN recur_gift rg ON rf.id_recur_gift = rg.id_recur_gift
        JOIN q_id id ON id.id_demo = rg.id_demo_receipt 
   WHERE rf.code_clg = 'CSE'
   AND rg.code_recur_status = 'O'
)
, temp_last_fund 
AS(SELECT w.*
         , rank()over(partition by id_rel order by rnk_last_v1 asc, date_tran desc,rownum) as rnk_last_v2 
   FROM(SELECT p.id_rel 
         , p.nbr_fund 
         , p.date_tran 
         , p.amt_fund 
         , f.desc_fund 
         , f.code_fund_stat 
         , rank()over(partition by p.id_rel, p.nbr_fund order by date_tran desc, amt_fund desc, rownum) as rnk_last_v1
         , rank()over(partition by p.id_rel order by amt_fund desc, date_tran desc, rownum)             as rnk_largest 
       FROM q_receipted_id p
            JOIN fund f on f.nbr_fund = p.nbr_fund --AND f.code_fund_stat = 'O'
            JOIN t202000332_qstk s on s.id_rel = p.id_rel 
       WHERE p.code_clg = 'CSE'
       AND p.code_recipient != 'S'
       AND p.code_anon IN ('0', '1')
       AND f.code_fund_stat = 'O'
       AND p.year_fiscal >= 2015
  )w 
)
, temp_largest 
AS(select distinct 
       ta.id_rel 
       , ta.date_tran         as largest_date 
       , ta.amt_fund          as largest_amt
       , cs.code_giving_range as range_code_largest
       , cs.desc_giving_range as range_desc_largest 
   from temp_last_fund ta 
         , cse_gift_range cs 
   where ta.amt_fund between cs.amt_range_min    
                        and cs.amt_range_max 
   and ta.rnk_largest = 1   
 )  
, temp_pool 
AS(
   SELECT *
   FROM(
        SELECT DISTINCT    
            d.id_household
             , d.id_rel  
             , DECODE(pl.id_rel,NULL,'N','Y')                    AS open_pledge 
             , DECODE(tr.id_rel,NULL,'N','Y')                    AS has_cse_recurring  
             , group_fun.gexists_hh(d.id_demo,9165)              AS flag_student 
             , DECODE(d.code_addr_stat,'C','Y','N')              AS has_valid_addr 
             , acad.last_clg_degree_comb(d.id_demo,'CSE')        AS last_cse_degree
             , prospect.name_mgr(d.id_demo,'CSE')                AS name_mgr 
             , prospect.team_member_list(d.id_demo,'CSE')        AS team_members
             , prospect.capacity_code(d.id_demo)                 AS Code_capacity
             , prospect.flag_pgw(d.id_demo)                      AS flag_pgw 
             , l1.range_code_largest 
             , l1.range_desc_largest 
             , f1.desc_fund                                      AS last_fund_1 
             , f1.nbr_fund                                       AS last_fund_no_1
             , f2.desc_fund                                      AS last_fund_2 
             , f2.nbr_fund                                       AS last_fund_no_2
             , f3.desc_fund                                      AS last_fund_3 
             , f3.nbr_fund                                       AS last_fund_no_3
             , fa.total_all_fy                                                        --REMOVE AFTER TEST 
             , fa.code_avg_all_fy 
             , fa.desc_avg_all_fy 
             , round(fa.avg_all_fy/50,0)* 50                     AS avg_all_fy        --REMOVE AFTER TEST 
             , round(fa.amt_ask/50,0)* 50                        AS amt_ask           -- nearest multiple of $50 for these: ask/monthly ask/ladder1,2,3   
             , round(fa.ask_ladder_1/50,0)* 50                   AS ask_ladder_1
             , round(fa.ask_ladder_2/50,0)* 50                   AS ask_ladder_2
             , round(fa.ask_ladder_3/50,0)* 50                   AS ask_ladder_3
             , round(fa.month_ask_amt/50,0)* 50                  AS month_ask_amt                             
             , s.year_fiscal
             , s.fy_code_range
             , s.fy_desc_range
             , nvl(fa.exclude_solicit,'N')                       AS exclude_solicit
       FROM t202000332_qstk d 
             LEFT JOIN t202000332a s        ON s.id_rel  = d.id_rel  
             LEFT JOIN temp_open_pl pl      ON pl.id_rel = d.id_rel    
             LEFT JOIN temp_recuring tr     ON tr.id_rel = d.id_rel  
             LEFT JOIN temp_last_fund f1    ON f1.id_rel = d.id_rel AND f1.rnk_last_v2 = 1 AND f1.rnk_last_v1 = 1
             LEFT JOIN temp_last_fund f2    ON f2.id_rel = d.id_rel AND f2.rnk_last_v2 = 2 AND f2.rnk_last_v1 = 1 
             LEFT JOIN temp_last_fund f3    ON f3.id_rel = d.id_rel AND f3.rnk_last_v2 = 3 AND f3.rnk_last_v1 = 1
             LEFT JOIN temp_largest l1      ON l1.id_rel = d.id_rel   
             LEFT JOIN temp_ask_formula fa  ON fa.id_rel = d.id_rel 
       )
    pivot(MAX(fy_code_range)                   AS code_range
          , MAX(fy_desc_range)                 AS desc_range
                 FOR year_fiscal IN ('2020'    AS fy20
                                     , '2019'  AS fy19
                                     , '2018'  AS fy18
                                     , '2017'  AS fy17
                                     , '2016'  AS fy16
                                     , '2015'  AS fy15
                                   ))
)--select * from temp_pool a where a.id_rel in (200317710);
select distinct 
       s.*
       , p.open_pledge 
       , p.has_cse_recurring  
       , p.flag_student 
       , p.has_valid_addr 
       , p.last_cse_degree
       , p.name_mgr 
       , p.team_members
       , p.Code_capacity
       , p.flag_pgw 
       , p.last_fund_1 
       , p.last_fund_no_1
       , p.last_fund_2 
       , p.last_fund_no_2
       , p.last_fund_3 
       , p.last_fund_no_3
       , p.range_code_largest 
       , p.range_desc_largest  
       , p.amt_ask 
       , p.ask_ladder_1
       , p.ask_ladder_2
       , p.ask_ladder_3
       , p.month_ask_amt 
       --, p.total_all_fy  --remove after test
       --, p.avg_all_fy    --remove after test
       , p.code_avg_all_fy 
       , p.desc_avg_all_fy
       , p.fy20_code_range
       , p.fy20_desc_range 
       , p.fy19_code_range
       , p.fy19_desc_range 
       , p.fy18_code_range
       , p.fy18_desc_range 
       , p.fy17_code_range
       , p.fy17_desc_range 
       , p.fy16_code_range
       , p.fy16_desc_range 
       , p.fy15_code_range
       , p.fy15_desc_range 
       , p.exclude_solicit
from t202000332_qstk s 
     join temp_pool p on p.id_household = s.id_household   
where 1=1
; 
--log runtime: 33 sec. --29 sec.  --xx --xx

--$$$ 
SELECT count(*) FROM t202000332_final;--1185 --1834 --1446  --1548 --1459  
SELECT * FROM t202000332_final; 





--test 
SELECT * FROM t202000332_final a where a.id_rel = 800567832; --managed 

SELECT * 
FROM t202000332_final a 
where a.fy20_code_range <= 41 
and (a.name_mgr is not null 
     or 
     a.team_members is not null 
   )
;

SELECT id_demo, count(*) FROM t202000332_final group by id_demo having count(*) > 1;--0
SELECT * FROM t202000332_final f where f.name_mgr is null and f.team_members is null;

SELECT * FROM t202000332_final where amt_ask is not null order by AMT_ASK desc;
 

--Include Solicit list  under $20k 
SELECT * FROM t202000332_final_test a where a.exclude_solicit = 'N';  --1471 --1378 
--Exclude Solicit list  under $20k 
SELECT * FROM t202000332_final  a where a.exclude_solicit = 'Y'; --77 --81 


--insert_inbox
EXEC batchman.ri_tapi.delete_report('t202000332_final');
COMMIT;
EXEC batchman.ri_tapi.add_report('t202000332_final','FY20 Fall Dean''s Club Appeal','PELT0055,AIJIBRIL');
COMMIT;
SELECT * FROM ri_report_user WHERE id_report = 't202000332_final';
SELECT * FROM batchman.ri_scheduled_report WHERE id_report = 't202000332_final';
EXEC batchman.ri_main.send_to_remote_inbox('t202000332_final');
COMMIT;
EXEC batchman.ri_tapi.delete_report('t202000332_final');
COMMIT;


--helpers
select * from cse_gift_range;

select id_rel 
       , round(max(a.ltd_rel_fy))    as ltd_rel_fy_max 
       , round(min(a.ltd_rel_fy))    as ltd_rel_fy_min
       , round(avg(a.ltd_rel_fy))    as ltd_rel_fy_avg
       , round(median(a.ltd_rel_fy)) as ltd_rel_fy_median
       , round(stddev(a.ltd_rel_fy))   as ltd_rel_fy_stdv
       , a.percentile
from( 
      select id_rel 
            , ltd_rel_fy
            , ntile(100) over(order by ltd_rel_fy)  as percentile
      from t202000332a  
      where 1=1 
      and cnt_fy_given >= 5
      --and a.id_rel = 930336808
    )a    
group by a.id_rel 
;

select * from t202000332a where id_rel = 930336808;

select * from t202000332_final where id_rel = 930336808;