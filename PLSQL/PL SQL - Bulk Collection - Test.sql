SET SERVEROUTPUT ON;

DECLARE
  TYPE t_indv IS TABLE OF q_individual%ROWTYPE  ;
  --TYPE t_exp IS TABLE OF  q_expectancy_id%TYPE;
  --TYPE t_org IS TABLE OF  q_organization%TYPE;
  --TYPE t_prod IS TABLE OF q_production_id%TYPE;
   
  l_t_indv  t_indv ;
 -- l_t_exp   t_exp_tab  := t_exp();
 -- l_t_org   t_org_tab  := t_org();
 -- l_t_prod  t_prod_tab := t_prod();
  
  l_start            NUMBER;
BEGIN
  -- Time a regular population.
  l_start := DBMS_UTILITY.get_time;

  FOR cur_rec IN (SELECT id_demo 
                         , name_last
                         , name_first
                  FROM   q_individual
                 )
  LOOP
     l_t_indv.id_demo    := cur_rec.id_demo;
  END LOOP;

  DBMS_OUTPUT.put_line('Regular (' || l_t_indv.count || ' rows): ' || 
                       (DBMS_UTILITY.get_time - l_start));
  
  -- Time bulk population.  
  l_start := DBMS_UTILITY.get_time;

  SELECT id_demo 
         , name_last
         , name_first
  BULK COLLECT INTO l_t_indv.id_demo,
                    l_t_indv.name_last,  
                    l_t_indv.name_first
  FROM   q_individual;

  DBMS_OUTPUT.put_line('Bulk    (' || l_t_indv.count || ' rows): ' || 
                       (DBMS_UTILITY.get_time - l_start));
END;
