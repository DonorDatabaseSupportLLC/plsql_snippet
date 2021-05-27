FUNCTION camp_potential
 --Returns overall campaign potential description
 (id_demo_in IN q_individual.id_demo%TYPE)
 RETURN VARCHAR2
 IS
   camp VARCHAR2(4000);

 CURSOR camp_potential_cur IS
     SELECT DISTINCT
        '('||p.code_camp_potential||') '||p.desc_camp_potential x
     FROM
        (
         SELECT
            i.id_demo_master
         FROM
            q_id i
         WHERE
            i.id_demo = id_demo_in
        ) t
        JOIN q_prospect p ON t.id_demo_master = p.id_prospect_master
    ;
 BEGIN
   camp := NULL;
   FOR rec IN camp_potential_cur
       LOOP
           camp := rec.x;
       END LOOP;
   RETURN camp;

 EXCEPTION WHEN others THEN
   RAISE;
 END camp_potential;
