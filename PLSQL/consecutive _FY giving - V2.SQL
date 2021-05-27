WITH temp_consec_pool 
AS(
    SELECT p.id_household AS id_demo, p.year_fiscal 
     FROM q_receipted_id p
    WHERE p.code_clg = 'CLA'
      AND p.code_recipient != 'S'
      AND p.code_anon in ('0','1')
    UNION   
   SELECT p.id_household AS id_demo, p.year_fiscal 
     FROM q_production_id p
    WHERE p.code_clg = 'CLA'
      AND p.code_recipient != 'S'
      AND p.code_anon in ('0','1')
)--select * from temp_consec_pool where id_demo = 100000311;
, temp_consec 
AS(SELECT *   
     FROM temp_consec_pool  
   match_recognize(  
                   PARTITION BY id_demo 
                       ORDER BY year_fiscal DESC  
                   measures 
                          first(year_fiscal)    as from_fy   --starting from this FY & counting backwards to first FY where donor gave consecutively      
                         , last(year_fiscal)    as to_fy          
                          , match_number()      as match_number
                          , classifier()        as classifier  
                          , count(*)            as count_conseq
                    pattern
           -- *: indicates 0:M - 0 to many matches (Consec. FY may or may not exists)--If Consec. FY exists or not, it displays that FY
           -- +: indicates 1:M - 1 to many matches (Consec. FY Much exists)--Display FY Only if Consecutive FY exists  
                          --(starts consecutive+)
                            (starts consecutive*)   
                    define   
                         consecutive AS year_fiscal = (prev(year_fiscal)- 1)
        )
)  
, temp_consec_final 
AS(
    SELECT z.id_demo 
           , z.from_fy
           , z.to_fy
           , z.count_conseq
           , z.classifier
           , z.rnk_recent_conseq
    FROM(SELECT w.*
                , rank()over(PARTITION BY id_demo
                                 ORDER BY count_conseq desc
                                          , rownum) rnk_recent_conseq                               
        FROM temp_consec w
       WHERE classifier = 'CONSECUTIVE' 
      )z 
  WHERE z.rnk_recent_conseq = 1   --Conseq FY. Starting from most recent FY giving and working your way back 2020 --to-- 2000 (20FY)
)   
SELECT fc.*
 FROM temp_consec_final fc  
WHERE fc.id_demo = 100000311 
;