--*****************************************************************************
--FLag any FY total less than 2 std of the mean (2* Stddev): STDDEV_POP - population
-- Purpose: remove any FY total that is less than 2 stdDev (population) of the Mean
--*****************************************************************************
with temp_pool 
as( 
    select 
        id_rel
        , year_fiscal 
        , ltd_rel_fy 
        , round(median(e.ltd_rel_fy)over (partition by id_rel))        as median_amt_fy 
        , round(avg(e.ltd_rel_fy)over (partition by id_rel))           as mean_amt_fy  
        , round(stddev_pop(e.ltd_rel_fy)over(partition by id_rel))     as stddev_amt_fy    -- 68%   - 1 std of the mean
        , round(2*stddev_pop(e.ltd_rel_fy)over (partition by id_rel))  as stddev_2_amt_fy  -- 95%   - 2 std of the mean
        , round(3*stddev_pop(e.ltd_rel_fy)over (partition by id_rel))  as stddev_3_amt_fy  -- 99.7% - 3 sdt of the mean
    from t202000332a e 
    where 1=1 
    and e.id_rel in (930332625, 700504378) 
)
select tp.*
from temp_pool tp 
where tp.ltd_rel_fy < tp.stddev_2_amt_fy 
;--5



--*****************************************************************************
--FLag any FY total less than 2 std of the mean (2* Stddev): STDDEV --sample 
--*****************************************************************************

with temp_pool 
as( 
    select 
        id_rel
        , year_fiscal 
        , ltd_rel_fy 
        , round(median(e.ltd_rel_fy)over (partition by id_rel))        as median_amt_fy 
        , round(avg(e.ltd_rel_fy)over (partition by id_rel))           as mean_amt_fy  
        , round(stddev(e.ltd_rel_fy)over(partition by id_rel))         as stddev_1_amt_fy    -- 68%   - 1 std of the mean
        , round(2*stddev(e.ltd_rel_fy)over (partition by id_rel))      as stddev_2_amt_fy    -- 95%   - 2 std of the mean
        , round(3*stddev(e.ltd_rel_fy)over (partition by id_rel))      as stddev_3_amt_fy    -- 99.7% - 3 sdt of the mean
    from t202000332a e 
    where 1=1 
    and e.id_rel in (930332625, 700504378) 
)
select tp.*
from temp_pool tp 
where tp.ltd_rel_fy < tp.stddev_2_amt_fy 
;--4





select * from t202000332a where id_rel = 930336808;
select * from t202000332_final where id_rel = 930336808;

--HELPERS 
drop table outlier_demo;
create table outlier_demo  as 
select rownum  as a
       , round(dbms_random.value(20,50),1)  as val  
from dual   
connect by level < 50
;

select * from outlier_demo order by val;

--add an outlier
insert into outlier_demo values (0,500); 
commit;

--Calculate averages
select count(*) cnt_all   
  , round(avg(val),1)                                 as avg_with_outlier   -- what's our average? 
  , round(avg(case when val < 500 then val end),1)    as avg_no_outlier     -- what would the average be without the known outlier?  
  , round(stddev(val),1)                              as std_with_outlier   -- Standard Deviation with outlier 
  , round(stddev(case when val < 500 then val end),1) as std_no_outlier     -- STD with no outlier     
  , round(median(val),1)                              as the_median         -- what's the median  
from outlier_demo 
where 1=1 
--and val < 500
;


--Analytical 
 -- what is 2 standard deviations away  
 -- provide result for each row  
select a, val  
   , round(2*stddev(val) over (order by null)) local_std  
from outlier_demo

;



-- Remove Outlier (stddev) 
select count(*) c   
  ,round(avg(val))                                 as the_avg   
  ,round(avg(case when val < 500 then val end))    as avg_no_outlier   
  ,round(stddev(val),1)                            as stddev_yes_outlier 
  ,round(stddev(case when val < 500 then val end)) as stddev_no_outlier 
  ,round(avg(local_std))                           as filter  
from    
  (
  select 
       a
       , val   
       , round(2*stddev(val) over (order by null)) local_std   -- what is 2 standard deviations away?  --provide result for each row    
   from outlier_demo   
  )   
where 1=1    
--and val < local_std  -- only average those values within two standard deviations  
; 


-- Remove Outlier (stddev) 
select count(*) c   
  ,round(avg(val),1)                               as the_avg   
  ,round(avg(case when val < 500 then val end),1)  as no_outlier   
  ,round(stddev(val),1)                            as new_stddev  
  ,round(avg(local_2_std_away),1)                  as filter  
from    
  (
  select a
    , val   
    , round(stddev(val) over (order by null),1) as local_1_std_away_from_means   -- what is 1 standard deviations away?  --provide result for each row  
    , round(2*stddev(val) over (order by null)) as local_2_std_away              -- what is 2 standard deviations away?  --provide result for each row  
   from outlier_demo   
  )   
-- only average those values within two standard deviations   
where val < local_2_std_away
; 

--helpers
select a 
       , round(2*stddev(val) over (order by null)) local_std   -- what is 2 standard deviations away?  --provide result for each row    
from outlier_demo   
;

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
          AND p.id_rel = 
        ) a
   GROUP BY id_rel, year_fiscal
)
select tp.*
       , round(avg(ltd_rel_fy)over(partition by id_rel order by null))    as avg_ltd_rel_fy 
       , round(stddev(ltd_rel_fy)over(partition by id_rel)) as std_ltd_rel_fy 
from temp_a tp 
where tp.id_rel = 700504378
--group by id_rel 
;
   
select a.id_rel 
       , round(avg(ltd_rel_fy))    as avg_ltd_rel_fy 
       , round(stddev(ltd_rel_fy)) as std_ltd_rel_fy 
from t202000332a a 
where a.id_rel = 700504378
group by id_rel 
;

select * 
from t202000332a a 
where a.id_rel = 700504378
;
 



--0. fall outside 1/3 (68%) within standard deviation of population 
--1. fall outside 2/3 (95%) within standard deviation of population 
--2. fall outside x/x (97%) within standard deviation of population 

drop  table outlier_std_pop;
create table outlier_std_pop as 
with temp_pool
as(
    select 
        e.empno 
        , e.ename 
        , e.job 
        , e.mgr 
        , e.comm 
        , e.deptno
        , e.sal
        , round(median(e.sal)over())        as median_sal
        , round(avg(e.sal)over())           as mean_sal 
        , round(stddev_pop(e.sal)over())    as stddev_pop_sal 
        , round(2*stddev_pop(e.sal)over())  as stddev_2_pop_sal 
        , round(3*stddev_pop(e.sal)over())  as stddev_3_pop_sal
        --, round(stddev(e.sal)over())      as stddev_sample_sal
    from scott.emp e 
)
select tp.*
       , case 
            when tp.sal >= stddev_3_pop_sal 
            then 'Y'
            else Null 
            end as flag_outlier
from temp_pool tp 
;

select * from outlier_std_pop;




