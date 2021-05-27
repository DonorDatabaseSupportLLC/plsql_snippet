CREATE OR REPLACE FUNCTION top_3_unit_list   (
      id_demo_in     IN     NUMBER(9), --q_production_id.id_Demo%TYPE,
      unit_nbr_in   IN     NUMBER DEFAULT 3
     )
RETURN VARCHAR2
IS
--VARIABLES
    tlist                                           VARCHAR2(4000);
--CURSORS
CURSOR top_3_unit_cur IS
   SELECT
     s.id_house
   , s. code_unit
   , SUM(s.amt_fund)
   , rank() over (order by sum(s.amt_fund) desc) rank1
   FROM
     (
      SELECT
       i_info.id_hh(p.id_demo) id_house
      , p.code_unit
      , p.id_gift
      , p.nbr_fund
      , p.code_pmt_form
      , p.amt_fund
      FROM
        q_production_id p
      WHERE
        p.id_demo = id_demo_in
      AND p.code_anon = '0'
      UNION
      SELECT
        i_info.id_hh(p.id_demo) id_house
      , p.code_unit
      , p.id_gift
      , p.nbr_fund
      , p.code_pmt_form
      , p.amt_fund
      FROM
        q_production_id p
      WHERE
        p.id_demo = i_info.id_spouse(id_demo_in)
      AND p.code_anon = '0'
     ) s
   GROUP BY
     s.id_house
   , s.code_unit
;
--RECORD TYPES
--PL/SQL TABLE TYPES
--RECORDS
--PL/SQL TABLES
BEGIN
 tlist := null;
 FOR rec IN top_3_unit_cur LOOP
   IF rec.rank1 <= clg_nbr_in then
     tlist := tlist||','||rec.code_unit;
   END IF;
 END LOOP;
RETURN substr(tlist,2);

EXCEPTION WHEN OTHERS THEN
  RAISE;

END top_3_unit_list;
--***********************************************************

select
