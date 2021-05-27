CREATE OR PACKAGE BODY namer_abdi
IS

--CONSTANTS
--VARIABLES
  errors_exist    BOOLEAN                           := FALSE;
  etitle          VARCHAR2(100)                     := 'BLANK';
  packname        VARCHAR2(50)                      := 'TEST';
--CURSORS
--RECORD TYPES
--PL/SQL TABLE TYPES
--RECORDS
--PL/SQL TABLES

--LOCAL PROCEDURE  SPECIFICATIONS
--***********************************************************



--***********************************************************
--PACKAGE BODY

--***********************************************************
  FUNCTION indv_salutation
-- returns RE individual_salutation, if exists, else null.
  ( id_demo_in q_individual.id_demo%type )
  RETURN names.name_other%type
  IS
  vreturn names.name_other%type;

  CURSOR is_cur IS
     SELECT
       n.name_other
     FROM names n
     WHERE
       n.id_demo = id_demo_in
     and n.code_name_type = 'IS'
     and n.code_name_stat = 'C'
    ;

  BEGIN
  vreturn := null;
   FOR rec IN is_cur
   LOOP
       vreturn := rec.name_other;
   END LOOP;
  RETURN (vreturn);

EXCEPTION WHEN OTHERS THEN
  RAISE;

  END indv_salutation;
--***********************************************************
--***********************************************************
  FUNCTION couple_addressee
-- returns RE couple_addressee, if exists, else null.
  ( id_demo_in q_individual.id_demo%type )
  RETURN names.name_other%type
  IS
  vreturn names.name_other%type;

  CURSOR ca_cur IS
     SELECT
       n.name_other
     FROM names n
     WHERE
       n.id_demo = id_demo_in
     and n.code_name_type = 'CA'
     and n.code_name_stat = 'C'
    ;

  BEGIN
  vreturn := null;
   FOR rec IN ca_cur
   LOOP
       vreturn := rec.name_other;
   END LOOP;
  RETURN (vreturn);

EXCEPTION WHEN OTHERS THEN
  RAISE;

  END couple_addressee;
--***********************************************************
--***********************************************************
  FUNCTION couple_salutation
-- returns RE couple_salutation, if exists, else null.
  ( id_demo_in q_individual.id_demo%type )
  RETURN names.name_other%type
  IS
  vreturn names.name_other%type;

  CURSOR cs_cur IS
     SELECT
       n.name_other
     FROM names n
     WHERE
       n.id_demo = id_demo_in
     and n.code_name_type = 'CS'
     and n.code_name_stat = 'C'
    ;

  BEGIN
  vreturn := null;
   FOR rec IN cs_cur
   LOOP
       vreturn := rec.name_other;
   END LOOP;
  RETURN (vreturn);

EXCEPTION WHEN OTHERS THEN
  RAISE;

  END couple_salutation;
--***********************************************************
--***********************************************************
  FUNCTION re_addressee
-- returns RE addressee, if exists, else namer.label
  ( id_demo_in q_individual.id_demo%type )
  RETURN names.name_other%type
  IS
  vreturn names.name_other%type;

  CURSOR ra_cur IS
     SELECT COALESCE
            (
                (SELECT
                   namer.couple_addressee(id_demo_in) name_other
                 FROM dual),

                (SELECT
                   namer.couple_addressee(i.id_spouse) name_other
                 FROM q_individual i
                   JOIN q_individual ii ON i.id_spouse = ii.id_demo
                 WHERE
                   i.id_demo = id_demo_in
                 AND ii.year_death IS NULL),

                (SELECT
                   namer.indv_addressee(id_demo_in) name_other
                 FROM dual),

                (SELECT
                   namer.indv_addressee(i.id_spouse) name_other
                 FROM q_individual i
                   JOIN q_individual ii ON i.id_spouse = ii.id_demo
                 WHERE
                   i.id_demo = id_demo_in
                 AND ii.year_death IS NULL),

                (SELECT
                   namer.label_punctuation(namer.comb(id_demo_in)) name_other
                 FROM dual)

             ) AS name_other
     FROM dual
     /*SELECT COALESCE
            (
                (SELECT
                   n.name_other
                 FROM names n
                 WHERE
                   n.id_demo = id_demo_in
                 and n.code_name_type = 'CA'
                 and n.code_name_stat = 'C'),

                (SELECT
                   n.name_other
                 FROM names n
                   JOIN q_individual i ON n.id_demo = i.id_spouse
                   JOIN q_individual ii ON i.id_spouse = ii.id_demo
                 WHERE
                   i.id_demo = id_demo_in
                 and n.code_name_type = 'CA'
                 and n.code_name_stat = 'C'
                 AND ii.year_death IS NULL),

                (SELECT
                   n.name_other
                 FROM names n
                 WHERE
                   n.id_demo = id_demo_in
                 and n.code_name_type = 'IA'
                 and n.code_name_stat = 'C'),

                (SELECT
                   n.name_other
                 FROM names n
                   JOIN q_individual i ON n.id_demo = i.id_spouse
                   JOIN q_individual ii ON i.id_spouse = ii.id_demo
                 WHERE
                   i.id_demo = id_demo_in
                 and n.code_name_type = 'IA'
                 and n.code_name_stat = 'C'
                 AND ii.year_death IS NULL),

                (SELECT
                   namer.label_punctuation(namer.comb(id_demo_in)) name_other
                 FROM dual)
             ) name_other
     FROM dual*/
    ;

  BEGIN
  vreturn := null;
   FOR rec IN ra_cur
   LOOP
       vreturn := rec.name_other;
   END LOOP;
  RETURN (vreturn);

EXCEPTION WHEN OTHERS THEN
  RAISE;

  END re_addressee;
--***********************************************************
--***********************************************************
  FUNCTION re_salutation
-- returns RE couple_salutation, if exists, else null.
  ( id_demo_in q_individual.id_demo%type )
  RETURN names.name_other%type
  IS
  vreturn names.name_other%type;

  CURSOR rs_cur IS
     SELECT COALESCE
            (
                (SELECT
                   namer.couple_salutation(id_demo_in) name_other
                 FROM dual),

                (SELECT
                   namer.couple_salutation(i.id_spouse) name_other
                 FROM q_individual i
                   JOIN q_individual ii ON i.id_spouse = ii.id_demo
                 WHERE
                   i.id_demo = id_demo_in
                 AND ii.year_death IS NULL),

                (SELECT
                   namer.indv_salutation(id_demo_in) name_other
                 FROM dual),

                (SELECT
                   namer.indv_salutation(i.id_spouse) name_other
                 FROM q_individual i
                   JOIN q_individual ii ON i.id_spouse = ii.id_demo
                 WHERE
                   i.id_demo = id_demo_in
                 AND ii.year_death IS NULL),

                (SELECT
                   namer.label_punctuation(namer.label(id_demo_in)) name_other
                 FROM dual)

             ) AS name_other
     FROM dual
     /*SELECT COALESCE
            (
                (SELECT
                   n.name_other
                 FROM names n
                 WHERE
                   n.id_demo = id_demo_in
                 and n.code_name_type = 'CS'
                 and n.code_name_stat = 'C'),

                (SELECT
                   n.name_other
                 FROM names n
                   JOIN q_individual i ON n.id_demo = i.id_spouse
                   JOIN q_individual ii ON i.id_spouse = ii.id_demo
                 WHERE
                   i.id_demo = id_demo_in
                 and n.code_name_type = 'CS'
                 and n.code_name_stat = 'C'
                 AND ii.year_death IS NULL),

                (SELECT
                   n.name_other
                 FROM names n
                 WHERE
                   n.id_demo = id_demo_in
                 and n.code_name_type = 'IS'
                 and n.code_name_stat = 'C'),

                (SELECT
                   n.name_other
                 FROM names n
                   JOIN q_individual i ON n.id_demo = i.id_spouse
                   JOIN q_individual ii ON i.id_spouse = ii.id_demo
                 WHERE
                   i.id_demo = id_demo_in
                 and n.code_name_type = 'IS'
                 and n.code_name_stat = 'C'
                 AND ii.year_death IS NULL),

                (SELECT
                   namer.label_punctuation(namer.label(id_demo_in)) name_other
                 FROM dual)
             ) name_other
     FROM dual*/
    ;

  BEGIN
  vreturn := null;
   FOR rec IN rs_cur
   LOOP
       vreturn := rec.name_other;
   END LOOP;
  RETURN (vreturn);

EXCEPTION WHEN OTHERS THEN
  RAISE;

  END re_salutation;
--***********************************************************
--***********************************************************
END NAMER;
