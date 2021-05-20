with temp_pool as
(
  select distinct
         r.id_rel
         , r.nbr_fund
         , r.id_gift
         , r.code_pmt_form
         , r.code_anon 
         , r.code_exp_type
         , r.amt_fund
         , r.year_fiscal
         , r.date_tran
         , r.id_expectancy  
  from q_receipted_id r 
  			cross join law_reunion_class_giving_dt dt1 
  where r.year_fiscal >= dt1.previous_fy
  and r.code_unit = 'LAW'
  and r.code_recipient != 'S'
  and r.code_anon in ('0','1','2')
  and exists(select 'x' 
             from q_expectancy e 
                   left join decode_exp_type et on et.code_exp_type = e.code_exp_type
                   cross join law_reunion_class_giving_dt dt2
             where e.id_expectancy = r.id_expectancy 
             --and e.year_fiscal < dt2.current_fy  
             and e.year_fiscal < r.year_fiscal  
             and e.code_unit = 'LAW'
             and e.code_recipient != 'S'
             and e.code_anon in ('0','1','2') 
             and (e.code_exp_type = 'PL' 
                  OR 
                  et.flag_deferred = 'Y' 
                 ))
  union 
  select distinct 
         r.id_rel
         , r.nbr_fund
         , r.id_gift
         , r.code_pmt_form
         , r.code_anon 
         , r.code_exp_type
         , r.amt_fund
         , r.year_fiscal
         , r.date_tran
         , NULL as id_expectancy 
  from q_production_id r 
       cross join law_reunion_class_giving_dt dt 
  where r.year_fiscal >= dt.previous_fy
  and r.code_unit = 'LAW'
  and r.code_recipient != 'S'
  and r.code_anon in ('0','1','2')
),
temp_remove_dupe_pmt as --Remove payment with expectancy in same year. 
(
  select distinct pmt.*
  from temp_pool pmt 
       join temp_pool plg on plg.id_gift = pmt.id_expectancy 
  where plg.year_fiscal >= pmt.year_fiscal
  and plg.nbr_fund = pmt.nbr_fund 
)
select tp.* 
from temp_pool tp  
where not exists(select 'x'
                 from temp_remove_dupe_pmt td 
                 where td.id_gift = tp.id_gift 
                 and td.id_expectancy = tp.id_expectancy
                )
; 