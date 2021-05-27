SELECT DISTINCT 
             p.id_demo_receipt AS id_demo
           , p.nbr_fund
           , p.id_gift
           , p.code_pmt_form
           , p.code_exp_type
           , p.amt_fund 
           , p.year_fiscal
           , SUM (CASE WHEN p.code_pmt_form = 'IK' 
                       THEN p.amt_fund
                       ELSE 0 
                 END) over (PARTITION BY p.year_fiscal) AS total_ik
            , SUM (CASE WHEN p.code_pmt_form != 'IK' 
                       THEN p.amt_fund
                       ELSE 0 
                 END) over (PARTITION BY p.year_fiscal) AS total_gifts    
            , SUM ( p.amt_fund ) over (PARTITION BY p.year_fiscal) AS total_gifts        
   FROM q_production p
   WHERE p.code_clg = 'ART'
   AND p.year_fiscal BETWEEN 2012 AND 2017
   AND p.code_recipient IN ('U','F','M')
