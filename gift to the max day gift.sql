--gift to the max day gift 
WITH 
		temp_gtm_appeal AS(
                      SELECT code_appeal, desc_appeal, code_camp, code_drive, code_audience 
                      FROM appeal_code_v 
                      WHERE UPPER(code_appeal) IN ('CTXXUMGCROWD','OE18UMGGTMDP') --(campaign, drive, audience)
                      )--,
  -- temp_gtm_prod AS (
                    --production 
                    SELECT p.id_demo_receipt AS id_demo, p.id_gift  
                    FROM q_production p 
                          JOIN temp_gtm_appeal tp ON tp.code_appeal = p.code_camp||p.code_drive||p.code_audience
                    WHERE p.date_tran = '16-Nov-2017'
                    AND p.code_anon IN ('0','1')
                    AND p.code_recipient != 'S'
--                    )
--money-in-the door
--SELECT p.id_demo_receipt, p.id_gift, p.amt_fund, p.date_tran, p.id_expectancy, tp.code_appeal   
--FROM q_receipted p 
-- 			JOIN temp_gtm_appeal tp ON tp.code_appeal = p.code_camp||p.code_drive||p.code_audience
--WHERE p.date_tran = '16-Nov-2017'
--AND p.code_anon IN ('0','1')
--AND p.code_recipient != 'S'
--online gifts not in Production (but is expectancy/plege payment 
--AND NOT EXISTS(SELECT 'x' FROM temp_gtm_prod td WHERE td.id_gift = p.id_gift) 
; 
     