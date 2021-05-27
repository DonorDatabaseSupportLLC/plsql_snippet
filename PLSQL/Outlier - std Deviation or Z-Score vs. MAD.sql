
--base table 
DROP TABLE temp_giving;
CREATE TABLE temp_giving AS
SELECT id_rel 
  , id_gift
  , year_fiscal 
  , sum(amt_fund) as amt_fund 
FROM(
      SELECT DISTINCT 
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
      AND p.id_rel = 140258497 
      AND p.id_expectancy = 122013092600549
  )
WHERE 1=1 
GROUP BY id_rel, year_fiscal, id_gift    
;

select * from temp_giving where id_rel = 140258497; 
                                              

--********************************************
--Outlier ver 1:  stddev +/- avg
--********************************************
with temp_std_dev  
AS(
   SELECT 
        w.*
        , mean - (3 * std_dev) as lower_threshold_3
        , mean + (3 * std_dev) as upper_threshold_3 
        , CASE WHEN amt_fund BETWEEN (mean - 3) * std_dev AND (mean + 3) * std_dev 
               THEN 'N'
               ELSE 'Y'
               END AS outlier 
   FROM(
        SELECT 
            a.id_rel 
            , amt_fund 
            , year_fiscal
            , round(avg(amt_fund)over(partition by id_rel))     as mean 
            , round(stddev(amt_fund)over(partition by id_rel))  as std_dev          
         FROM temp_giving a
         WHERE a.id_rel = 140258497
      )w 
)
select 
   p.*
   , case 
        when p.amt_fund between lower_threshold_3 
                            and upper_threshold_3
        then 'N'
        else 'Y'
        end as flag_outlier    
from temp_std_dev p 
where 1=1
; 
 --140258497: 1 outlier.
 --930324278: 2 outliers --$6,000/$5,000


--********************************************
--Outlier - v2: Median absolute deviation(MAD)
--********************************************
with temp_mad 
as(select 
       z.*
       , medians + (mad * 3.5) as upper_threshold 
       , medians - (mad * 3.5) as lower_threshold 
   from(
        select 
            w.*
            , round(1.4826 * (median(abs(amt_fund - medians)) over (partition by id_rel))) as mad 
        from(
             select 
                a.id_rel 
                , a.id_gift
                , round(amt_fund) as amt_fund
                , year_fiscal
                , round(median(amt_fund)over(partition by id_rel)) as medians 
             from temp_giving a 
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
 and id_rel = 140258497;  
 -- 140258497:  1 outlier. $25
 -- 930324278: 10 oulierss. >= $750 
 
 --**************************************
 --Test paper v3 
 --source: www.elsevier.com/locate/jesp
 --Detecting outliers: Do not use standard deviation around the mean, use absolute deviation around the median
  --**************************************
 select * from test_mad;
 
with temp_mad 
as(select 
       z.*
       , abs(medians - amt_fund)  as median_minus_observed_amt
       , medians + (mad * 3)      as upper_threshold 
       , medians - (mad * 3)      as lower_threshold 
   from(
        select 
            w.*
            , round(1.4826 * (median(abs(amt_fund - medians)) over (partition by null)),3) as mad  
            --formuala: MAD = b *  Mi (Xi - Mj (Xj)) --b = 1.4826. Xj = amt_fund (original observation). --Mi= Median of series. -- 
        from(
             select 
                 round(amt_fund) as amt_fund
                , round(median(amt_fund)over (partition by null),1) as medians 
             from test_mad a 
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
;

--**************************************
-- test paper - Standard Deviation 
-- source: www.elsevier.com/locate/jesp
-- Detecting outliers: Do not use standard deviation around the mean, use absolute deviation around the median
--**************************************
with temp_std_dev  
AS(
   SELECT 
        w.*
        , mean - (3 * std_dev) as lower_threshold_3
        , mean + (3 * std_dev) as upper_threshold_3 
        , CASE WHEN amt_fund BETWEEN mean - (3  * std_dev) AND mean + (3 * std_dev)
               THEN 'N'
               ELSE 'Y'
               END AS outlier 
   FROM(
        SELECT 
            a.amt_fund
            , round(avg(amt_fund)over(partition by null),2)     as mean 
            , round(stddev_pop(amt_fund)over(partition by null),2)  as std_dev          
         FROM test_mad a
      )w 
)
select 
   p.*
   , case 
        when p.amt_fund between lower_threshold_3 
                            and upper_threshold_3
        then 'N'
        else 'Y'
        end as flag_outlier    
from temp_std_dev p 
where 1=1
; 