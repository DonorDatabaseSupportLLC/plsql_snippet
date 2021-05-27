with temp_uniq_id 
as(select distinct id_rel 
   from umd_hh_relation_fix_pool p 
)
, temp_a 
as(select a.*
           , case when sum(amt_fund) over (partition by id_rel order by date_tran)>= 25000  
                  then 'Y'
                  else 'N'
                   end as checkpoint_1
           , case when sum(amt_fund) over (partition by id_rel order by date_tran)>= 50000  
                  then 'Y'
                  else 'N'
                   end as checkpoint_2 
    from(select distinct 
                p.id_rel
               , p.nbr_fund
               , p.id_gift
               , p.code_pmt_form
               , p.code_exp_type
               , p.amt_fund
               , p.date_tran
        from q_production_id p
        join temp_uniq_id id on id.id_rel = p.id_rel 
       where p.code_unit = 'UMD'
         and p.code_recipient != 'S'
         and p.code_anon in ('0','1')
    )a 
 ) 
 --find date donor first reached the milestone
, temp_milestone_dt 
AS(SELECT ta.id_rel
         , MIN(CASE WHEN ta.checkpoint_1 = 'Y' THEN date_tran END) AS milestone_dt_1  
         , MIN(CASE WHEN ta.checkpoint_2 = 'Y' THEN date_tran END) AS milestone_dt_2 
    FROM temp_a ta
    GROUP BY id_rel 
)
--Calculate ltd up-to-the first date donor reach milestone $25K+
, temp_25K_milestone 
AS(
    SELECT w.*
    FROM(SELECT ta.id_rel
             , SUM(ta.amt_fund)                                        AS total_amt
             , MAX(ta.checkpoint_1)                                    AS milestone  
             , MIN(CASE WHEN ta.checkpoint_1 = 'Y' THEN date_tran END) AS milestone_date 
         FROM temp_a ta 
         JOIN temp_milestone_dt tmd ON tmd.id_rel = ta.id_rel 
         WHERE ta.date_tran <= tmd.milestone_dt_1
        GROUP BY ta.id_rel
       )w
    WHERE w.milestone = 'Y' 
    AND EXTRACT(YEAR FROM w.milestone_date) = (SELECT dt.milestone_1 from umd_hh_relation_fix_dt dt)
)
--Calculate ltd up-to-the first date donor reach milestone $50K+
, temp_50k_milestone 
AS(
    SELECT w.*
    FROM(SELECT 
             ta.id_rel
             , SUM(ta.amt_fund)                                        AS total_amt
             , MAX(ta.checkpoint_2)                                    AS milestone 
             , MIN(CASE WHEN ta.checkpoint_2 = 'Y' THEN date_tran END) AS milestone_date
         FROM temp_a ta 
         JOIN temp_milestone_dt tmd ON tmd.id_rel = ta.id_rel 
         WHERE ta.date_tran <= tmd.milestone_dt_2
        GROUP BY ta.id_rel
       )w
    WHERE w.milestone = 'Y' 
    AND EXTRACT(YEAR FROM w.milestone_date) >= (SELECT dt.milestone_2 from umd_hh_relation_fix_dt dt)
)
, temp_last_5fy_donors 
as(select distinct p.id_rel
     from q_production_id p
    cross join umd_hh_relation_fix_dt dt 
     join temp_uniq_id id on id.id_rel = p.id_rel 
    where p.code_unit = 'UMD'
      and p.code_recipient != 'S'
      and p.code_anon in ('0','1')
      and p.year_fiscal >= dt.last_5_fy
)
select w.*
from(select distinct 
           a.id_rel
          , decode(tl5.id_rel,null,'N','Y') as umd_donor_last_5_fy 
          , decode(ms1.id_rel,null,'N','Y') as umd_milestone_25K_2017
          , ms1.total_amt                   as umd_ltd_upto_2017
          , decode(ms2.id_rel,null,'N','Y') as umd_milestone_50K_2018
          , ms2.total_amt                   as umd_ltd_from_2018
     from temp_uniq_id a 
     left join temp_last_5fy_donors tl5 on tl5.id_rel = a.id_rel
     left join temp_25k_milestone   ms1 on ms1.id_rel = a.id_rel
     left join temp_50k_milestone   ms2 on ms2.id_rel = a.id_rel
    where 1=1  
  )w   
where umd_donor_last_5_fy = 'Y' 
  or umd_milestone_25K_2017 = 'Y' 
  or umd_milestone_50K_2018 = 'Y' 
; 
