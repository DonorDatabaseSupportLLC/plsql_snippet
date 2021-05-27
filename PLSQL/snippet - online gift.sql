--oline gift prod
WITH
  temp_online AS(
                 SELECT distinct dc2.id_gift
                 FROM docs_cite@prod dc2
                     JOIN webgift@prod w ON to_char(w.id_transaction) = dc2.cite_key
                 WHERE dc2.code_cite = 'WG' --Authorize.Net Web Gift Data 
               ),
  temp_pool_prod AS (
                      SELECT p.id_demo_receipt  AS id_demo, p.id_gift, p.date_tran  
                      FROM q_production p 
                         JOIN temp_online_prod tp ON tp.id_gift = p.id_gift 
                      WHERE p.date_tran  = '16-Nov-2017'  
                      AND p.code_anon IN ('0','1')
                      AND p.code_recipient != 'S'
                    ) 
--production
SELECT p.id_demo_receipt
			, p.id_gift
      , p.date_tran
      , p.amt_fund
      , p.amt_gift
FROM q_receipted p 
   JOIN temp_online_prod tp ON tp.id_gift = p.id_gift 
WHERE p.date_tran  = '16-Nov-2017'  
AND p.code_anon IN ('0','1')
AND p.code_recipient != 'S'
; --724 

--mitd 
SELECT p.id_demo_receipt
			, p.id_gift
      , p.date_tran
      , p.amt_fund
      , p.amt_gift
FROM q_receipted p 
   JOIN temp_online_prod tp ON tp.id_gift = p.id_gift 
WHERE p.date_tran  = '16-Nov-2017'  
AND p.code_anon IN ('0','1')
AND p.code_recipient != 'S'
--online gifts not in Production (but is expectancy/plege payment 
AND NOT EXISTS(SELECT 'x' FROM temp_pool_prod td WHERE td.id_gift = p.id_gift) 
; --726 

--400506958	112017111700188	 
--700444021	112017111700173	 
--SELECT * FROM q_production p WHERE p.id_gift IN (112017111700173, 112017111700188);
--SELECT * FROM q_receipted p WHERE p.id_gift IN (112017111700173, 112017111700188);