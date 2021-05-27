
PROMPT *******************************************************************************
--consecutively giving 10 fiscal years:  
PROMPT *******************************************************************************

WITH temp_consec_fy_giving AS 
(
	SELECT z.*
	FROM(
	SELECT id_demo
				, MAX(cnt) AS consec_fy_10
	FROM 
	(
			SELECT id_demo
							, COUNT(DISTINCT year_fiscal) cnt
			FROM 
			(
				SELECT  id_demo
								, DENSE_RANK() OVER(PARTITION BY id_demo ORDER BY year_fiscal desc) dense_rank
								, year_fiscal
								, year_fiscal 
								+ DENSE_RANK() OVER(PARTITION BY id_demo ORDER BY year_fiscal desc) n 
				FROM q_receipted_id 
				WHERE code_anon <= 1
				AND code_unit = 'ART'
				AND code_recipient != 'S'
				AND id_demo = 700545433
				
			)
			 GROUP BY id_demo, n
			 )
	GROUP BY id_demo
	)z 
--	WHERE z.consec_fy_10 >= 10
)
SELECT DISTINCT a.id_demo
			, bb.id_rel 
			, bb.consec_fy_10
from
  (
   SELECT p.id_demo, p.id_rel 
   FROM q_production_id P
  	WHERE p.code_clg = 'SOM'
		AND p.code_anon < 2 
		AND p.code_recipient != 'S'
   ) a
JOIN temp_consec_fy_giving bb ON bb.id_rel = a.id_rel 
;