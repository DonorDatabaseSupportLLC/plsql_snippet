with temp_prospects 
as(
   select distinct id.id_rel
   from prospect_vq p 
   join q_id id 
        on id.id_demo = p.id_prospect_master 
   where p.id_demo_mgr = 140231160  --Change DO ID
   union
   select distinct id.id_rel
   from prospect_former_team p 
   join q_id id 
        on id.id_demo = p.id_prospect_master 
   where p.id_demo_mgr = 140231160  --Change DO ID
   and p.date_removed >= '01-JUL-2014'
   )
 , temp_prod AS 
 (  
   select distinct 
    p.id_rel 
   , p.date_tran
   , p.nbr_fund
   , p.id_gift
   , p.code_pmt_form
   , p.code_exp_type
   , p.amt_gift
from q_production_id p 
where 1=1 
and p.code_unit = 'CH'  --Change unit appropriately
and p.code_anon < 2 
and p.code_recipient != 'S'
and p.year_fiscal = 2015
and exists (select 'x' from temp_prospects i 
            where i.id_rel = p.id_rel 
            )
)
SELECT sum(t.amt_gift) AS total$, count(t.amt_gift) AS total#
FROM temp_prod  t
;
