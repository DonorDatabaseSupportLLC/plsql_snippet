
--retunrs number of x years given out of last y years
FUNCTION gave_x_out_of_y_fy(
              id_demo                IN   q_individual.id_demo%TYPE,
               y_number_fy 				   number,                        --y : 10 years
               x_fy_given 					 number,                        --x years given out of y years
               code_unit             IN   q_production.code_unit%TYPE DEFAULT NULL,
               code_anon_in          IN q_production_id.code_anon%TYPE DEFAULT global_constants.std_anon
              )
RETURN VARCHAR2
IS

--variable
fy_count_var     varchar2(10):= 0;
wrong_fy_given   EXCEPTION;

--cursor
CURSOR fy_given_unit_cur IS
with temp_fy as
(select to_number(to_char(add_months(sysdate,6),'YYYY')) - y_number_fy as fy --last 10 yrs
 from dual
)
SELECT a.id_rel
       , count(distinct year_fiscal) total_fy
FROM
  (
   SELECT id.id_rel, p.year_fiscal
   FROM q_production_id p
        join q_id id on id.id_rel = p.id_rel
   WHERE id.id_demo = gave_x_out_of_y_fy.id_demo
   AND   p.code_clg = gave_x_out_of_y_fy.code_unit
   AND   year_fiscal >= (select fy from temp_fy)
   AND   p.code_recipient in ('U','F')
   AND   p.code_anon <= code_anon_in
  ) a
group by a.id_rel
having count(*) >= x_fy_given
;

CURSOR fy_given_cur IS
with temp_fy as
(select to_number(to_char(add_months(sysdate,6),'YYYY')) - y_number_fy as fy
 from dual
)
SELECT a.id_rel
      , count(distinct year_fiscal) total_fy
FROM
  (
   SELECT id.id_rel, p.year_fiscal
   FROM q_production_id p
        join q_id id on id.id_rel = p.id_rel
   WHERE id.id_demo = gave_x_out_of_y_fy.id_demo
   AND   year_fiscal >= (select fy from temp_fy)
   AND   p.code_recipient in ('U','F')
   AND   p.code_anon <= code_anon_in
  ) a
group by a.id_rel
having count(*) >= x_fy_given
;

BEGIN
     CASE WHEN x_fy_given > y_number_fy THEN
               raise_application_error(-20000, 'Wrong Number of Fiscal years given was passed');
          WHEN code_unit IS NULL THEN
                FOR rec IN fy_given_cur
                   LOOP
                       fy_count_var :=  rec.total_fy;
                   END LOOP;
         ELSE
           FOR rec IN fy_given_unit_cur
               LOOP
                  fy_count_var := rec.total_fy;
               END LOOP;
     END CASE;

    RETURN fy_count_var;

     EXCEPTION
         WHEN wrong_fy_given THEN
                DBMS_OUTPUT.PUT_LINE(TO_CHAR(SQLERRM(-20000)));
         WHEN others THEN
                RAISE;
END gave_x_out_of_y_fy;