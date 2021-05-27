with temp_prod AS 
  (  
   select distinct 
    p.id_rel
   , p.date_tran
   , p.nbr_fund
   , p.id_gift
   , p.code_pmt_form
   , p.code_exp_type
   , p.amt_fund
from q_production_id p 
where p.code_unit = 'CH'  --Change unit appropriately
and p.code_anon < 2
and p.code_recipient != 'S'
and p.year_fiscal = 2015

)
SELECT to_char(sum(t.amt_fund), '999,999,999')AS total$, to_char(count(DISTINCT t.id_gift), '999,999,999')AS total#
FROM temp_prod  t
;


