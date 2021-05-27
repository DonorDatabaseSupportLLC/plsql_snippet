
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
      --AND p.id_rel = 140258497 
      --AND p.id_gift = 112014100800201
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
        , mean - (3  * std_dev) as lower_threshold_3
        , mean + (3 * std_dev)  as upper_threshold_3 
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
select p.*
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
, temp_mad 
as(select 
     z.*
     , (medians + mad) * 2  as upper_threshold 
     , (medians - mad) * 2 as lower_threshold 
   from(
        SELECT 
             w.*
              , round(1.4826* (median(abs(amt_fund - medians)) over (partition by id_rel))) as mad 
        FROM(SELECT 
                a.id_rel 
                , a.id_gift
                , amt_fund 
                , year_fiscal
                , round(median(amt_fund)over(partition by id_rel)) as medians 
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
and id_rel = 140258497 --930324278 