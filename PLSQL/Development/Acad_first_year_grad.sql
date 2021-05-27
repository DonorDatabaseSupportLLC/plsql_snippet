FUNCTION first_year
    (id_demo_in             IN          academic.id_demo%TYPE)
RETURN academic.year_grad%TYPE RESULT_CACHE
IS
--VARIABLES
    fyear                   academic.year_grad%TYPE;
--CURSORS
CURSOR first_year_cur
 IS
 SELECT  min(acad.year_grad) AS min_year
 FROM   academic acad
 WHERE  acad.id_demo = id_demo_in;
--RECORD TYPES
--PL/SQL TABLE TYPES
--RECORDS
--PL/SQL TABLES
BEGIN
 fyear := 0;
 FOR rec IN first_year_cur LOOP
  fyear := rec.min_year;
 END LOOP;
RETURN fyear;

EXCEPTION WHEN OTHERS THEN
  RAISE;

END first_year;