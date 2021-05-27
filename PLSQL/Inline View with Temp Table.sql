--Inline View - WITH CLAUSE 
SELECT s.id_demo, s.source
FROM (
      SELECT p.id_demo, 'donor' AS source
      FROM q_production_id p
      WHERE p.code_clg = 'CLA'
        AND p.code_dept = '2008'
        AND p.date_tran BETWEEN '01-Apr-2013' AND SYSDATE
      UNION
      SELECT a.id_demo, 'alumni' AS source
      FROM q_academic_dept a 
        JOIN q_production_id p ON a.id_demo = p.id_demo
      WHERE a.code_clg_query = 'CLA'
        AND a.code_acad_dept = 'GEOG'
        AND p.code_clg = 'CLA'
        AND p.date_tran BETWEEN '01-Apr-2013' AND SYSDATE
      )s
JOIN q_individual i ON s.id_demo = i.id_demo
WHERE i.year_death IS NULL

--Inline View with Temp table
WITH Temp_A AS 
( SELECT 
   s.id_demo, s.source
  FROM (
      SELECT p.id_demo, 'donor' AS source
      FROM q_production_id p
      WHERE p.code_clg = 'CLA'
      AND p.code_dept = '2008'
      AND p.date_tran BETWEEN '01-Apr-2013' AND SYSDATE
      UNION
      SELECT a.id_demo, 'alumni' AS source
      FROM q_academic_dept a 
        JOIN q_production_id p ON a.id_demo = p.id_demo
      WHERE a.code_clg_query = 'CLA'
      AND a.code_acad_dept = 'GEOG'
      AND p.code_clg = 'CLA'
      AND p.date_tran BETWEEN '01-Apr-2013' AND SYSDATE
      )s
JOIN q_individual i ON s.id_demo = i.id_demo
WHERE i.year_death IS NULL
)
SELECT s.* 
FROM Temp_A s
/

--Multiple Temp table WITH CLAUSE 
WITH Temp_AA AS 
(
 SELECT p.id_demo, 'donor' AS source
 FROM q_production_id p
 WHERE p.code_clg = 'CLA'
 AND p.code_dept = '2008'
 AND p.date_tran BETWEEN '01-Apr-2013' AND SYSDATE
)
, Temp_AB AS 
 (
  SELECT a.id_demo, 'alumni' AS source
  FROM q_academic_dept a 
        JOIN q_production_id p ON a.id_demo = p.id_demo
  WHERE a.code_clg_query = 'CLA'
  AND a.code_acad_dept = 'GEOG'
  AND p.code_clg = 'CLA'
  AND p.date_tran BETWEEN '01-Apr-2013' AND SYSDATE
) 

SELECT * FROM Temp_AA aa
UNION 
SELECT * FROM Temp_AB AB
/
)



