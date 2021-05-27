SELECT x.*
FROM (
        SELECT DISTINCT  
             p.id_rel
           , p.nbr_fund
           , p.id_gift
           , p.code_pmt_form
           , p.code_exp_type
           , p.amt_fund
           , et.desc_exp_type
           , sum(amt_fund)over (PARTITION BY id_rel) AS total_planned_gift
       FROM q_production_id p
       JOIN decode_exp_type et ON et.code_exp_type = p.code_exp_type
       WHERE p.code_clg = 'UMD'
         AND p.code_recipient in ('U','F','M')
         AND p.code_anon in ('0','1')
         AND et.flag_deferred = 'Y'
   )x 
WHERE x.total_planned_gift >= 100000.00  --$100k+

;
