select to_date(sysdate) dt from dual;

SELECT 
  a.*
  , count(distinct year_fiscal) over (partition by id_rel) number_fy_given  
  , rank()over(partition by id_rel order by (case when year_fiscal <= 2017  
                                                      then date_tran
                                                   else to_date('01-jul-1900') 
                                              end) desc,rownum) as rank --numb_gift_pre_fy18 
FROM(
      SELECT DISTINCT  
           p.id_rel
         , p.nbr_fund
         , p.id_gift
         , p.code_pmt_form
         , p.code_exp_type
         , p.amt_fund
         , p.year_fiscal
         , p.date_tran
     FROM q_production_id p
     WHERE p.code_clg = 'LAW'
     AND p.code_recipient != 'S'
     AND p.code_anon in ('0','1')
     AND p.id_rel = 140612427 --100228428
     --AND p.year_fiscal <= 2017
  )a