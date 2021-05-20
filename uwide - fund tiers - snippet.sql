SELECT DISTINCT
            rf.id_demo
            , dfi.desc_fund_id_rel
            , rf.desc_rel 
            , f.nbr_fund||' - '||f.desc_fund AS  funds 
            , CASE WHEN SUBSTR(dfi.desc_fund_id_rel,-1,1) = '1' THEN '1'
                         WHEN SUBSTR(dfi.desc_fund_id_rel,-1,1) = '2' THEN '2'
                         WHEN SUBSTR(dfi.desc_fund_id_rel,-1,1) = '3' THEN '3'
                         WHEN SUBSTR(dfi.desc_fund_id_rel,-1,1) = '4' THEN '4' 
                         WHEN SUBSTR(dfi.desc_fund_id_rel,-1,1) = '5' THEN '5'
                         ELSE 'unknown'
                END AS tiers
FROM fund_id_xref@prod rf 
            JOIN fund f ON f.nbr_fund = rf.nbr_fund  
            JOIN decode_eis_use de ON de.code_eis_use  = f.code_use 
            JOIN decode_fund_id_rel dfi ON dfi.code_fund_id_rel = rf.code_fund_id_rel  
WHERE f.code_clg IN ('CSA','SPC','GRD','FND')
AND de.eis_use_rollup = 'N'  
AND f.code_fund_stat = 'O' 
AND rf.code_fund_id_rel IN ('W', 'X', 'Y', 'Z','5')
; 

--version II
ITH temp_fund_rel AS
(
SELECT DISTINCT
            rf.id_demo
            , id.id_house_hold as id_house 
            , dfi.desc_fund_id_rel
            --, rf.desc_rel 
            , f.nbr_fund||' - '||f.desc_fund AS  funds 
FROM fund_id_xref@prod rf 
            JOIN fund f ON f.nbr_fund = rf.nbr_fund  
            JOIN decode_eis_use de ON de.code_eis_use  = f.code_use 
            JOIN decode_fund_id_rel dfi ON dfi.code_fund_id_rel = rf.code_fund_id_rel  
            JOIN q_id id on id.id_demo = rf.id_demo 
WHERE f.code_clg IN ('CSA','SPC','GRD','FND')
AND de.eis_use_rollup = 'N'  
AND f.code_fund_stat = 'O' 
AND rf.code_fund_id_rel IN ('W', 'X', 'Y', 'Z','5')