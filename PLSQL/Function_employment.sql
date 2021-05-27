/* Formatted on 2007/10/12 16:03 (Formatter Plus v4.8.7) University of Minnesota Foundation*/
FUNCTION employment_abdi (
-- returns employer info; default code_rel_stat_in = 'C'; any other value
-- will return whatever employer info is found.
   id_demo_in      IN   q_individual.id_demo%TYPE
 , code_rel_stat_in   IN   q_individual.code_rel_stat%TYPE DEFAULT 'C'
)
   RETURN employer.name_emp%TYPE
IS
--VARIABLES
   tname   employer.name_emp%TYPE;
BEGIN
   SELECT CASE
             WHEN code_rel_stat_in = 'C'
                THEN COALESCE (
                               (SELECT j.name_emp
                                  FROM q_individual r, employer j
                                 WHERE r.id_pref_empl = j.id_empl
                                   AND r.code_rel_stat = 'C'
                                   AND r.id_demo = id_demo_in
                                )
                             , (SELECT j.name_label
                                  FROM q_individual r, q_organization j
                                 WHERE r.id_pref_empl = j.id_demo
                                   AND r.code_rel_stat = 'C'
                                   AND r.id_demo = id_demo_in
                               )
                             , NULL
                            )
             ELSE COALESCE (
                            (SELECT j.name_emp
                               FROM q_individual r, employer j
                              WHERE r.id_pref_empl = j.id_empl
                                AND r.id_demo = id_demo_in
                             )
                          , (SELECT j.name_label
                               FROM q_individual r, q_organization j
                              WHERE r.id_pref_empl = j.id_demo
                                AND r.id_demo = id_demo_in
                            )
                          , NULL
                       )
          END
     INTO tname
     FROM DUAL;

   RETURN tname;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END employment;



SELECT * FROM q_individual i 
WHERE i.id_demo = 140291220;


--a
SELECT id_demo
       , name_label
       , i.name_emp
       , i_info.employment(140291220) AS current_employer 
FROM q_individual i 
WHERE i.id_demo = 140291220
;

SELECT * FROM relation r 
WHERE r.id_demo_rel  = 930007047
  AND r.id_demo = 140291220;

