FUNCTION first_clg_degree_comb
--This function returns the grad year, degree, major description, code major for
-- the individual first degree from the given college.
    (id_demo_in             IN          q_academic.id_demo%TYPE,
     code_clg_in            IN          q_academic.code_clg%TYPE)
RETURN VARCHAR2 RESULT_CACHE
IS
--VARIABLES
    clg_degree                          VARCHAR2(300);
--CURSORS
CURSOR first_clg_degree_cur IS
 SELECT  decode(a.year_grad,9999,'Unknown Year',a.year_grad)
         ||' ('
         ||a.desc_degree
         ||') '
         ||a.desc_major_minor_long
         ||' ('
         ||a.code_major
         ||')' AS first_deg
 FROM (SELECT acad.year_grad
               , degd.desc_degree
               , majd.desc_major_minor_long
               , acad.code_major
               , RANK() OVER (PARTITION BY id_demo
                              ORDER BY acad.year_grad ASC
                              , gt.code_term_student_sys  ASC
                              , acad.code_degree             ASC
                              , CASE WHEN acad.code_campus = '1' THEN 1  --Twin Cities
                                     WHEN acad.code_campus = '6' THEN 2  --Mayo
                                     WHEN acad.code_campus = '3' THEN 3  --Duluth
                                     WHEN acad.code_campus = '4' THEN 4  --Morris
                                     WHEN acad.code_campus = '5' THEN 5  --Crookston
                                     WHEN acad.code_campus = '8' THEN 6  --Rochester
                                     WHEN acad.code_campus = '7' THEN 7  --Waseca
                                     WHEN acad.code_campus = '0' THEN 8  --Unknown
                                     ELSE 9
                                     END
                              , CASE WHEN acad.code_clg_query = 'UMD' THEN 1
                                     WHEN acad.code_clg_query = 'GRD' THEN 2
                                     ELSE 3
                                     END                DESC
                              , ROWNUM                  DESC) AS ranking
        FROM decode_major_minor majd
             , decode_degree degd
             , q_academic acad
             , decode_grad_term gt
             , decode_honor h
             , decode_campus camp
 WHERE acad.code_major     = majd.code_major_minor
 AND   acad.code_degree    = degd.code_degree
 AND   acad.code_grad_term = gt.code_grad_term
 AND   acad.code_honor     = h.code_honor
 AND   ACAD.code_campus    = camp.code_campus
 AND   acad.id_demo        = id_demo_in
 AND   acad.code_clg_query = code_clg_in
 ) a
WHERE a.ranking = 1;
--RECORD TYPES
--PL/SQL TABLE TYPES
--RECORDS
--PL/SQL TABLES
BEGIN
 clg_degree := NULL;
 FOR rec_rsct IN first_clg_degree_cur LOOP
   clg_degree := rec_rsct.first_deg;
 END LOOP;
RETURN clg_degree;

EXCEPTION WHEN OTHERS THEN
  RAISE;

END first_clg_degree_comb;