
--Stanley hubbard  --DONE
SELECT DISTINCT p.id_demo, p.id_rel, p.code_corridor, p.code_clg, p.code_dept, p.amt_fund
 FROM q_production_id p 
WHERE  p.id_demo = 300400907
/
--ICA Giving - DONE 
SELECT * FROM q_production_id p 
WHERE p.code_clg= 'ICA' AND p.id_demo = 300170668 

/

-- Duluth giving
SELECT * FROM q_production_id p 
WHERE p.code_clg= 'UMD' AND p.amt_fund > 5000 AND p.id_demo = 930300891
/

--  Heart --DONE 
SELECT  p.id_demo, p.id_rel, p.code_corridor, p.code_clg, p.code_dept, p.amt_fund
 FROM q_production_id p 
WHERE p.code_clg IN ('MED', 'AHC', 'MMF','SPH', 'VA') 
/* AND  p.code_corridor IN ('H') AND  */  AND p.id_demo = 230242047
/
-- cancer -- DONE
SELECT  p.id_demo, p.id_rel, p.code_corridor, p.code_clg, p.code_dept, p.amt_fund
 FROM q_production_id p 
WHERE p.code_clg IN ('MED', 'AHC', 'MMF','SPH', 'VA') 
AND p.code_corridor IN ('C') AND  p.id_demo = 200249738
/
--  Diabetes --DONE
SELECT  p.id_demo, p.id_rel, p.code_corridor, p.code_clg, p.code_dept, p.amt_fund
FROM q_production_id p 
WHERE p.code_clg IN ('MED', 'AHC', 'MMF','SPH', 'VA') 
AND p.code_corridor IN ('D') AND  p.id_demo = 430310875
/
