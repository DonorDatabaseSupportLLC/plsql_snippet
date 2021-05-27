PACKAGE BODY "LARGEST_GIFT"
IS
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- jim Fairweather 10may-2007 create package
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below
   FUNCTION amt (string_in IN VARCHAR2)
      RETURN VARCHAR2
   IS
--VARIABLES
      tamt   VARCHAR2 (20);

--CURSORS
      CURSOR last_gift_cur
      IS
         SELECT SUBSTR (string_in
                      , INSTR (string_in, '~') + 1
                      ,   (  INSTR (string_in
                                  , '~'
                                  , 1
                                  , 2
                                   )
                           - INSTR (string_in, '~')
                          )
                        - 1
                       ) string_out
           FROM DUAL;
--RECORD TYPES
--PL/SQL TABLE TYPES
--RECORDS
--PL/SQL TABLES
   BEGIN
      tamt := ' ';

      FOR rec IN last_gift_cur
      LOOP
         tamt := LTRIM (rec.string_out);
      END LOOP;

      RETURN tamt;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END amt;

--***********************************************************
   FUNCTION dates (string_in IN VARCHAR2)
      RETURN VARCHAR2
   IS
--VARIABLES
      tclg   VARCHAR2 (200);

--CURSORS
      CURSOR last_gift_cur
      IS
         SELECT SUBSTR (string_in
                      , 1
                      , INSTR (string_in, '~') - 1
                       ) string_out
           FROM DUAL;
--RECORD TYPES
--PL/SQL TABLE TYPES
--RECORDS
--PL/SQL TABLES
   BEGIN
      tclg := ' ';

      FOR rec IN last_gift_cur
      LOOP
         tclg := rec.string_out;
      END LOOP;

      RETURN tclg;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END dates;
--***********************************************************
   FUNCTION dates2 (string_in IN VARCHAR2)
      RETURN DATE
   IS
--VARIABLES
      tclg   DATE;

--CURSORS
      CURSOR last_gift_cur
      IS
         SELECT
         CASE WHEN string_in IS NULL
              THEN NULL
              ELSE to_date(SUBSTR (string_in
                                , 1
                                , INSTR (string_in, '~') - 1
                               ) ,'DD-Mon-YYYY')
              END string_out
           FROM DUAL;
--RECORD TYPES
--PL/SQL TABLE TYPES
--RECORDS
--PL/SQL TABLES
   BEGIN
      tclg := ' ';

      FOR rec IN last_gift_cur
      LOOP
         tclg := rec.string_out;
      END LOOP;

      RETURN tclg;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END dates2;

--***********************************************************
   FUNCTION fund_desc (string_in IN VARCHAR2)
      RETURN VARCHAR2
   IS
--VARIABLES
      tclg   fund.desc_fund%TYPE;

--CURSORS
      CURSOR last_gift_cur
      IS
         SELECT SUBSTR (string_in
                      , INSTR (string_in
                             , '~'
                             , 1
                             , 3
                              ) + 1
                      ,   (  INSTR (string_in
                                  , '~'
                                  , 1
                                  , 4
                                   )
                           - INSTR (string_in
                                  , '~'
                                  , 1
                                  , 3
                                   )
                          )
                        - 1
                       ) string_out
           FROM DUAL;
--RECORD TYPES
--PL/SQL TABLE TYPES
--RECORDS
--PL/SQL TABLES
   BEGIN
      tclg := ' ';

      FOR rec IN last_gift_cur
      LOOP
         tclg := rec.string_out;
      END LOOP;

      RETURN tclg;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END fund_desc;

--***********************************************************
   FUNCTION fund_nbr (string_in IN VARCHAR2)
      RETURN VARCHAR2
   IS
--VARIABLES
      tclg   fund.nbr_fund%TYPE;

--CURSORS
      CURSOR last_gift_cur
      IS
         SELECT SUBSTR (string_in
                      , INSTR (string_in
                             , '~'
                             , 1
                             , 2
                              ) + 1
                      ,   (  INSTR (string_in
                                  , '~'
                                  , 1
                                  , 3
                                   )
                           - INSTR (string_in
                                  , '~'
                                  , 1
                                  , 2
                                   )
                          )
                        - 1
                       ) string_out
           FROM DUAL;
--RECORD TYPES
--PL/SQL TABLE TYPES
--RECORDS
--PL/SQL TABLES
   BEGIN
      tclg := ' ';

      FOR rec IN last_gift_cur
      LOOP
         tclg := rec.string_out;
      END LOOP;

      RETURN tclg;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END fund_nbr;

--***********************************************************
   FUNCTION solicitation (string_in IN VARCHAR2)
      RETURN VARCHAR2
   IS
--VARIABLES
      tclg   VARCHAR2 (1000);

--CURSORS
      CURSOR last_gift_cur
      IS
         SELECT SUBSTR (string_in
                      , INSTR (string_in
                             , '~'
                             , 1
                             , 4
                              ) + 1
                      ,   (  INSTR (string_in
                                  , '~'
                                  , 1
                                  , 5
                                   )
                           - INSTR (string_in
                                  , '~'
                                  , 1
                                  , 4
                                   )
                          )
                        - 1
                       ) string_out
           FROM DUAL;
--RECORD TYPES
--PL/SQL TABLE TYPES
--RECORDS
--PL/SQL TABLES
   BEGIN
      tclg := ' ';

      FOR rec IN last_gift_cur
      LOOP
         tclg := rec.string_out;
      END LOOP;

      RETURN tclg;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END solicitation;

--***********************************************************
   FUNCTION clg (string_in IN VARCHAR2)
      RETURN VARCHAR2
   IS
--VARIABLES
      tclg   q_production.code_clg%TYPE;

--CURSORS
      CURSOR last_gift_cur
      IS
         SELECT SUBSTR (string_in
                      , INSTR (string_in
                             , '~'
                             , 1
                             , 5
                              ) + 1
                      ,   (  INSTR (string_in
                                  , '~'
                                  , 1
                                  , 6
                                   )
                           - INSTR (string_in
                                  , '~'
                                  , 1
                                  , 5
                                   )
                          )
                        - 1
                       ) string_out
           FROM DUAL;
--RECORD TYPES
--PL/SQL TABLE TYPES
--RECORDS
--PL/SQL TABLES
   BEGIN
      tclg := ' ';

      FOR rec IN last_gift_cur
      LOOP
         tclg := rec.string_out;
      END LOOP;

      RETURN tclg;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END clg;

--***********************************************************
    FUNCTION hh_largest_commit_clg (
--This function returns the date, amount, fund number, description, solicitation(
-- camp, drive, audience) and college for the largets commitment,
-- if exists, else null.
      id_demo_in     IN   q_production_id.id_demo%TYPE
    , nbr_seq_in     IN   NUMBER DEFAULT 1
    , code_clg_opt   IN   q_production.code_clg%TYPE DEFAULT '%'
    , code_anon_in   IN   q_production.code_anon%TYPE DEFAULT '1'
    , add_spa        IN   q_production_id.code_recipient%TYPE DEFAULT NULL
   )
      RETURN VARCHAR2
   IS
--VARIABLES
      largest_gift   VARCHAR (200) := NULL;
      spouser        NUMBER        := i_info.id_spouse (id_demo_in);
   BEGIN
      IF code_clg_opt = '%'
      THEN
         SELECT    g.date_tran
                || '~'
                || TO_CHAR (NVL (g.amt_fund, '0'), '999999999.00')
                || '~'
                || NVL (g.nbr_fund, ' ')
                || '~'
                || NVL (funds.fdesc (nbr_fund), ' ')
                || '~'
                || NVL (g.code_camp, ' ')
                || NVL (g.code_drive, ' ')
                || NVL (g.code_audience, ' ')
                || '~'
                || NVL (g.code_clg, ' ')
                || '~'
                || NVL (g.code_dept, ' ')
                || '~'
           INTO largest_gift
           FROM (SELECT l.*
                      , RANK () OVER (ORDER BY l.amt_fund DESC, ROWNUM)
                                                                     rank_amt
                   FROM (SELECT p.code_clg
                              , p.date_tran
                              , p.nbr_fund
                              , p.amt_fund
                              , p.code_camp
                              , p.code_drive
                              , p.code_audience
                              , p.code_dept
                           FROM q_production_id p
                          WHERE p.code_anon <= code_anon_in
                        --   where p.code_anon < '2'
                            AND p.code_exp_type NOT IN ('MT', 'MR')
                            AND p.code_recipient IN
                                ( global_constants.std_u
                                , global_constants.std_f
                                , global_constants.std_m
                                , hh_largest_commit_clg.add_spa)
                            AND p.id_demo = id_demo_in
                         UNION
                         SELECT p.code_clg
                              , p.date_tran
                              , p.nbr_fund
                              , p.amt_fund
                              , p.code_camp
                              , p.code_drive
                              , p.code_audience
                              , p.code_dept
                           FROM q_production_id p
                          WHERE p.code_anon <= code_anon_in
                       --    where p.code_anon < '2'
                            AND p.code_exp_type NOT IN ('MT', 'MR')
                            AND p.code_recipient IN
                                ( global_constants.std_u
                                , global_constants.std_f
                                , global_constants.std_m
                                , hh_largest_commit_clg.add_spa)
                            AND p.id_demo = spouser) l) g
          WHERE g.rank_amt = nbr_seq_in;
      ELSE
         SELECT    g.date_tran
                || '~'
                || TO_CHAR (NVL (g.amt_fund, '0'), '999999999.00')
                || '~'
                || NVL (g.nbr_fund, ' ')
                || '~'
                || NVL (funds.fdesc (nbr_fund), ' ')
                || '~'
                || NVL (g.code_camp, ' ')
                || NVL (g.code_drive, ' ')
                || NVL (g.code_audience, ' ')
                || '~'
                || NVL (g.code_clg, ' ')
                || '~'
                || NVL (g.code_dept, ' ')
                || '~'
           INTO largest_gift
           FROM (SELECT l.*
                      , RANK () OVER (ORDER BY l.amt_fund DESC, ROWNUM)
                                                                     rank_amt
                   FROM (SELECT p.code_clg
                              , p.date_tran
                              , p.nbr_fund
                              , p.amt_fund
                              , p.code_camp
                              , p.code_drive
                              , p.code_audience
                              , p.code_dept
                           FROM q_production_id p
                          WHERE p.code_anon <= code_anon_in
                     --     where p.code_anon < '2'
                            AND p.code_recipient IN
                                ( global_constants.std_u
                                , global_constants.std_f
                                , global_constants.std_m
                                , hh_largest_commit_clg.add_spa)
                            AND p.code_exp_type NOT IN ('MT', 'MR')
                            AND p.code_clg = code_clg_opt
                            AND p.id_demo = id_demo_in
                         UNION
                         SELECT p.code_clg
                              , p.date_tran
                              , p.nbr_fund
                              , p.amt_fund
                              , p.code_camp
                              , p.code_drive
                              , p.code_audience
                              , p.code_dept
                           FROM q_production_id p
                          WHERE p.code_anon <= code_anon_in
                    --      where p.code_anon < '2'
                            AND p.code_recipient IN
                                ( global_constants.std_u
                                , global_constants.std_f
                                , global_constants.std_m
                                , hh_largest_commit_clg.add_spa)
                            AND p.code_exp_type NOT IN ('MT', 'MR')
                            AND p.code_clg = code_clg_opt
                            AND p.id_demo = spouser) l) g
          WHERE g.rank_amt = nbr_seq_in;
      END IF;

      RETURN largest_gift;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END hh_largest_commit_clg;

--***********************************************************
   FUNCTION hh_largest_gift_clg (
--This function returns the date, amount, fund number, description, solicitation(
-- camp, drive, audience) and college for the largest gift(money-in-the-door),
-- if exists, else null.
      id_demo_in     IN   q_production_id.id_demo%TYPE
    , nbr_seq_in     IN   NUMBER DEFAULT 1
    , code_clg_opt   IN   q_production.code_clg%TYPE DEFAULT '%'
    , add_spa        IN   q_production_id.code_recipient%TYPE DEFAULT NULL
   )
      RETURN VARCHAR2
   IS
--VARIABLES
      largest_gift   VARCHAR (200) := NULL;
      spouser        NUMBER        := i_info.id_spouse (id_demo_in);
   BEGIN
      IF code_clg_opt = '%'
      THEN
         SELECT    g.date_tran
                || '~'
                || TO_CHAR (NVL (g.amt_fund, '0'), '999999999.00')
                || '~'
                || NVL (g.nbr_fund, ' ')
                || '~'
                || NVL (funds.fdesc (nbr_fund), ' ')
                || '~'
                || NVL (g.code_camp, ' ')
                || NVL (g.code_drive, ' ')
                || NVL (g.code_audience, ' ')
                || '~'
                || NVL (g.code_clg, ' ')
                || '~'
           INTO largest_gift
           FROM (SELECT l.*
                      , RANK () OVER (ORDER BY l.amt_fund DESC, ROWNUM)
                                                                     rank_amt
                   FROM (SELECT p.code_clg
                              , p.date_tran
                              , p.nbr_fund
                              , p.amt_fund
                              , p.code_camp
                              , p.code_drive
                              , p.code_audience
                           FROM q_receipted_id p
                          WHERE p.code_anon = '0'
                            AND p.code_recipient IN
                                ( global_constants.std_u
                                , global_constants.std_f
                                , global_constants.std_m
                                , hh_largest_gift_clg.add_spa)
                            AND p.code_exp_type NOT IN ('MT', 'MR')
                            AND p.id_demo = id_demo_in
                         UNION
                         SELECT p.code_clg
                              , p.date_tran
                              , p.nbr_fund
                              , p.amt_fund
                              , p.code_camp
                              , p.code_drive
                              , p.code_audience
                           FROM q_receipted_id p
                          WHERE p.code_anon = '0'
                            AND p.code_recipient IN
                                ( global_constants.std_u
                                , global_constants.std_f
                                , global_constants.std_m
                                , hh_largest_gift_clg.add_spa)
                            AND p.code_exp_type NOT IN ('MT', 'MR')
                            AND p.id_demo = spouser) l) g
          WHERE g.rank_amt = nbr_seq_in;
      ELSE
         SELECT    g.date_tran
                || '~'
                || TO_CHAR (NVL (g.amt_fund, '0'), '999999999.00')
                || '~'
                || NVL (g.nbr_fund, ' ')
                || '~'
                || NVL (funds.fdesc (nbr_fund), ' ')
                || '~'
                || NVL (g.code_camp, ' ')
                || NVL (g.code_drive, ' ')
                || NVL (g.code_audience, ' ')
                || '~'
                || NVL (g.code_clg, ' ')
                || '~'
           INTO largest_gift
           FROM (SELECT l.*
                      , RANK () OVER (ORDER BY l.amt_fund DESC, ROWNUM)
                                                                     rank_amt
                   FROM (SELECT p.code_clg
                              , p.date_tran
                              , p.nbr_fund
                              , p.amt_fund
                              , p.code_camp
                              , p.code_drive
                              , p.code_audience
                           FROM q_receipted_id p
                          WHERE p.code_anon = '0'
                            AND p.code_recipient IN
                                ( global_constants.std_u
                                , global_constants.std_f
                                , global_constants.std_m
                                , hh_largest_gift_clg.add_spa)
                            AND p.code_exp_type NOT IN ('MT', 'MR')
                            AND p.code_clg = code_clg_opt
                            AND p.id_demo = id_demo_in
                         UNION
                         SELECT p.code_clg
                              , p.date_tran
                              , p.nbr_fund
                              , p.amt_fund
                              , p.code_camp
                              , p.code_drive
                              , p.code_audience
                           FROM q_receipted_id p
                          WHERE p.code_anon = '0'
                            AND p.code_recipient IN
                                ( global_constants.std_u
                                , global_constants.std_f
                                , global_constants.std_m
                                , hh_largest_gift_clg.add_spa)
                            AND p.code_exp_type NOT IN ('MT', 'MR')
                            AND p.code_clg = code_clg_opt
                            AND p.id_demo = spouser) l) g
          WHERE g.rank_amt = nbr_seq_in;
      END IF;

      RETURN largest_gift;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END hh_largest_gift_clg;

--***********************************************************
   FUNCTION hh_largest_commit_dept (
--This function returns the date, amount, fund number, description, solicitation(
-- camp, drive, audience) and college for the largets commitment for a
-- department, if exists, else null.
      id_demo_in   IN   q_production_id.id_demo%TYPE
    , nbr_seq_in   IN   NUMBER DEFAULT 1
    , code_dept_in    IN   q_production.code_dept%TYPE
    , add_spa        IN   q_production_id.code_recipient%TYPE DEFAULT NULL
   )
      RETURN VARCHAR2
   IS
--VARIABLES
      largest_gift   VARCHAR (200) := NULL;
      spouser        NUMBER        := i_info.id_spouse (id_demo_in);
   BEGIN
      SELECT    g.date_tran
             || '~'
             || TO_CHAR (NVL (g.amt_fund, '0'), '999999999.00')
             || '~'
             || NVL (g.nbr_fund, ' ')
             || '~'
             || NVL (funds.fdesc (nbr_fund), ' ')
             || '~'
             || NVL (g.code_camp, ' ')
             || NVL (g.code_drive, ' ')
             || NVL (g.code_audience, ' ')
             || '~'
             || NVL (g.code_clg, ' ')
             || '~'
        INTO largest_gift
        FROM (SELECT l.*
                   , RANK () OVER (ORDER BY l.amt_fund DESC, ROWNUM) rank_amt
                FROM (SELECT p.code_clg
                           , p.date_tran
                           , p.nbr_fund
                           , p.amt_fund
                           , p.code_camp
                           , p.code_drive
                           , p.code_audience
                        FROM q_production_id p
                       WHERE p.code_anon = '0'
                        AND p.code_recipient IN
                            ( global_constants.std_u
                            , global_constants.std_f
                            , global_constants.std_m
                            , hh_largest_commit_dept.add_spa)
                         AND p.code_exp_type NOT IN ('MT', 'MR')
                         AND p.code_dept = code_dept_in
                         AND p.id_demo = id_demo_in
                      UNION
                      SELECT p.code_clg
                           , p.date_tran
                           , p.nbr_fund
                           , p.amt_fund
                           , p.code_camp
                           , p.code_drive
                           , p.code_audience
                        FROM q_production_id p
                       WHERE p.code_anon = '0'
                        AND p.code_recipient IN
                            ( global_constants.std_u
                            , global_constants.std_f
                            , global_constants.std_m
                            , hh_largest_commit_dept.add_spa)
                         AND p.code_exp_type NOT IN ('MT', 'MR')
                         AND p.code_dept = code_dept_in
                         AND p.id_demo = spouser) l) g
       WHERE g.rank_amt = nbr_seq_in;

      RETURN largest_gift;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END hh_largest_commit_dept;

--***********************************************************
   FUNCTION hh_largest_gift_dept (
--This function returns the date, amount, fund number, description, solicitation(
-- camp, drive, audience) and college for the largest gift(money-in-the-door),
-- for a department, if exists, else null.
      id_demo_in     IN   q_production_id.id_demo%TYPE
    , nbr_seq_in     IN   NUMBER DEFAULT 1
    , code_dept_in   IN   q_production.code_dept%TYPE
    , add_spa        IN   q_production_id.code_recipient%TYPE DEFAULT NULL
   )
      RETURN VARCHAR2
   IS
--VARIABLES
      largest_gift   VARCHAR (200) := NULL;
      spouser        NUMBER        := i_info.id_spouse (id_demo_in);
   BEGIN
      SELECT    g.date_tran
             || '~'
             || TO_CHAR (NVL (g.amt_fund, '0'), '999999999.00')
             || '~'
             || NVL (g.nbr_fund, ' ')
             || '~'
             || NVL (funds.fdesc (nbr_fund), ' ')
             || '~'
             || NVL (g.code_camp, ' ')
             || NVL (g.code_drive, ' ')
             || NVL (g.code_audience, ' ')
             || '~'
             || NVL (g.code_clg, ' ')
             || '~'
        INTO largest_gift
        FROM (SELECT l.*
                   , RANK () OVER (ORDER BY l.amt_fund DESC, ROWNUM) rank_amt
                FROM (SELECT p.code_clg
                           , p.date_tran
                           , p.nbr_fund
                           , p.amt_fund
                           , p.code_camp
                           , p.code_drive
                           , p.code_audience
                        FROM q_receipted_id p
                       WHERE p.code_anon = '0'
                        AND p.code_recipient IN
                            ( global_constants.std_u
                            , global_constants.std_f
                            , global_constants.std_m
                            , hh_largest_gift_dept.add_spa)
                         AND p.code_exp_type NOT IN ('MT', 'MR')
                         AND p.code_dept = code_dept_in
                         AND p.id_demo = id_demo_in
                      UNION
                      SELECT p.code_clg
                           , p.date_tran
                           , p.nbr_fund
                           , p.amt_fund
                           , p.code_camp
                           , p.code_drive
                           , p.code_audience
                        FROM q_receipted_id p
                       WHERE p.code_anon = '0'
                        AND p.code_recipient IN
                            ( global_constants.std_u
                            , global_constants.std_f
                            , global_constants.std_m
                            , hh_largest_gift_dept.add_spa)
                         AND p.code_exp_type NOT IN ('MT', 'MR')
                         AND p.code_dept = code_dept_in
                         AND p.id_demo = spouser) l) g
       WHERE g.rank_amt = nbr_seq_in;

      RETURN largest_gift;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END hh_largest_gift_dept;

--***********************************************************
/* Formatted on 2008/01/08 14:31 (Formatter Plus v4.8.7) University of Minnesota Foundation*/
FUNCTION hh_largest_commit_fund (
--This function returns the date, amount, fund number, description, solicitation(
-- camp, drive, audience) and college for the largets commitment
-- for a specific fund, if exists, else null.
   id_demo_in    IN   q_production_id.id_demo%TYPE
 , nbr_seq_in    IN   NUMBER DEFAULT 1
 , nbr_fund_in   IN   q_production.nbr_fund%TYPE
 , add_spa       IN   q_production_id.code_recipient%TYPE DEFAULT NULL
)
   RETURN VARCHAR2
IS
--VARIABLES
   largest_gift   VARCHAR (200) := NULL;
   spouser        NUMBER        := i_info.id_spouse (id_demo_in);
BEGIN
   SELECT    g.date_tran
          || '~'
          || TO_CHAR (NVL (g.amt_fund, '0'), '999999999.00')
          || '~'
          || NVL (g.nbr_fund, ' ')
          || '~'
          || NVL (funds.fdesc (nbr_fund), ' ')
          || '~'
          || NVL (g.code_camp, ' ')
          || NVL (g.code_drive, ' ')
          || NVL (g.code_audience, ' ')
          || '~'
          || NVL (g.code_clg, ' ')
          || '~'
     INTO largest_gift
     FROM (SELECT l.*
                , RANK () OVER (ORDER BY l.amt_fund DESC, ROWNUM) rank_amt
             FROM (SELECT p.code_clg
                        , p.date_tran
                        , p.nbr_fund
                        , p.amt_fund
                        , p.code_camp
                        , p.code_drive
                        , p.code_audience
                     FROM q_production_id p
                    WHERE p.code_anon = '0'
                    AND p.code_recipient IN
                        ( global_constants.std_u
                        , global_constants.std_f
                        , global_constants.std_m
                        , hh_largest_commit_fund.add_spa)
                      AND p.code_exp_type NOT IN ('MT', 'MR')
                      AND p.nbr_fund = nbr_fund_in
                      AND p.id_demo = id_demo_in
                   UNION
                   SELECT p.code_clg
                        , p.date_tran
                        , p.nbr_fund
                        , p.amt_fund
                        , p.code_camp
                        , p.code_drive
                        , p.code_audience
                     FROM q_production_id p
                    WHERE p.code_anon = '0'
                    AND p.code_recipient IN
                        ( global_constants.std_u
                        , global_constants.std_f
                        , global_constants.std_m
                        , hh_largest_commit_fund.add_spa)
                      AND p.code_exp_type NOT IN ('MT', 'MR')
                      AND p.nbr_fund = nbr_fund_in
                      AND p.id_demo = spouser) l) g
    WHERE g.rank_amt = nbr_seq_in;

   RETURN largest_gift;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END hh_largest_commit_fund;


--***********************************************************
/* Formatted on 2008/01/08 14:30 (Formatter Plus v4.8.7) University of Minnesota Foundation*/
FUNCTION hh_largest_gift_fund (
--This function returns the date, amount, fund number, description, solicitation(
-- camp, drive, audience) and college for the largest gift(money-in-the-door),
-- for a specific fund, if exists, else null.
   id_demo_in    IN   q_production_id.id_demo%TYPE
 , nbr_seq_in    IN   NUMBER DEFAULT 1
 , nbr_fund_in   IN   q_production.nbr_fund%TYPE
 , add_spa       IN   q_production_id.code_recipient%TYPE DEFAULT NULL
)
   RETURN VARCHAR2
IS
--VARIABLES
   largest_gift   VARCHAR (200) := NULL;
   spouser        NUMBER        := i_info.id_spouse (id_demo_in);
BEGIN
   SELECT    g.date_tran
          || '~'
          || TO_CHAR (NVL (g.amt_fund, '0'), '999999999.00')
          || '~'
          || NVL (g.nbr_fund, ' ')
          || '~'
          || NVL (funds.fdesc (nbr_fund), ' ')
          || '~'
          || NVL (g.code_camp, ' ')
          || NVL (g.code_drive, ' ')
          || NVL (g.code_audience, ' ')
          || '~'
          || NVL (g.code_clg, ' ')
          || '~'
     INTO largest_gift
     FROM (SELECT l.*
                , RANK () OVER (ORDER BY l.amt_fund DESC, ROWNUM) rank_amt
             FROM (SELECT p.code_clg
                        , p.date_tran
                        , p.nbr_fund
                        , p.amt_fund
                        , p.code_camp
                        , p.code_drive
                        , p.code_audience
                     FROM q_receipted_id p
                    WHERE p.code_anon = '0'
                    AND p.code_recipient IN
                        ( global_constants.std_u
                        , global_constants.std_f
                        , global_constants.std_m
                        , hh_largest_gift_fund.add_spa)
                      AND p.code_exp_type NOT IN ('MT', 'MR')
                      AND p.nbr_fund = nbr_fund_in
                      AND p.id_demo = id_demo_in
                   UNION
                   SELECT p.code_clg
                        , p.date_tran
                        , p.nbr_fund
                        , p.amt_fund
                        , p.code_camp
                        , p.code_drive
                        , p.code_audience
                     FROM q_receipted_id p
                    WHERE p.code_anon = '0'
                    AND p.code_recipient IN
                        ( global_constants.std_u
                        , global_constants.std_f
                        , global_constants.std_m
                        , hh_largest_gift_fund.add_spa)
                      AND p.code_exp_type NOT IN ('MT', 'MR')
                      AND p.nbr_fund = nbr_fund_in
                      AND p.id_demo = spouser) l) g
    WHERE g.rank_amt = nbr_seq_in;

   RETURN largest_gift;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END hh_largest_gift_fund;


--***********************************************************
/* Formatted on 2008/01/08 14:30 (Formatter Plus v4.8.7) University of Minnesota Foundation*/
FUNCTION indv_largest_commit_clg (
--This function returns the date, amount, fund number, description, solicitation(
-- camp, drive, audience, and college for the largest commitment,
-- for an individual id_demo, if exists, else null.
   id_demo_in     IN   q_production_id.id_demo%TYPE
 , nbr_seq_in     IN   NUMBER DEFAULT 1
 , code_clg_opt   IN   q_production.code_clg%TYPE DEFAULT '%'
 , add_spa        IN   q_production_id.code_recipient%TYPE DEFAULT NULL
)
   RETURN VARCHAR2
IS
--VARIABLES
   largest_gift   VARCHAR (200) := NULL;
BEGIN
   IF code_clg_opt = '%'
   THEN
      SELECT    g.date_tran
             || '~'
             || TO_CHAR (NVL (g.amt_fund, '0'), '999999999.00')
             || '~'
             || NVL (g.nbr_fund, ' ')
             || '~'
             || NVL (funds.fdesc (nbr_fund), ' ')
             || '~'
             || NVL (g.code_camp, ' ')
             || NVL (g.code_drive, ' ')
             || NVL (g.code_audience, ' ')
             || '~'
             || NVL (g.code_clg, ' ')
             || '~'
        INTO largest_gift
        FROM (SELECT l.*
                   , RANK () OVER (ORDER BY l.amt_fund DESC, ROWNUM) rank_amt
                FROM (SELECT p.code_clg
                           , p.date_tran
                           , p.nbr_fund
                           , p.amt_fund
                           , p.code_camp
                           , p.code_drive
                           , p.code_audience
                        FROM q_production_id p
                       WHERE p.code_anon = '0'
                        AND p.code_recipient IN
                            ( global_constants.std_u
                            , global_constants.std_f
                            , global_constants.std_m
                            , indv_largest_commit_clg.add_spa)
                         AND p.code_exp_type NOT IN ('MT', 'MR')
                         AND p.id_demo = id_demo_in) l) g
       WHERE g.rank_amt = nbr_seq_in;
   ELSE
      SELECT    g.date_tran
             || '~'
             || TO_CHAR (NVL (g.amt_fund, '0'), '999999999.00')
             || '~'
             || NVL (g.nbr_fund, ' ')
             || '~'
             || NVL (funds.fdesc (nbr_fund), ' ')
             || '~'
             || NVL (g.code_camp, ' ')
             || NVL (g.code_drive, ' ')
             || NVL (g.code_audience, ' ')
             || '~'
             || NVL (g.code_clg, ' ')
             || '~'
        INTO largest_gift
        FROM (SELECT l.*
                   , RANK () OVER (ORDER BY l.amt_fund DESC, ROWNUM) rank_amt
                FROM (SELECT p.code_clg
                           , p.date_tran
                           , p.nbr_fund
                           , p.amt_fund
                           , p.code_camp
                           , p.code_drive
                           , p.code_audience
                        FROM q_production_id p
                       WHERE p.code_anon = '0'
                        AND p.code_recipient IN
                            ( global_constants.std_u
                            , global_constants.std_f
                            , global_constants.std_m
                            , indv_largest_commit_clg.add_spa)
                         AND p.code_exp_type NOT IN ('MT', 'MR')
                         AND p.code_clg = code_clg_opt
                         AND p.id_demo = id_demo_in) l) g
       WHERE g.rank_amt = nbr_seq_in;
   END IF;

   RETURN largest_gift;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END indv_largest_commit_clg;


--***********************************************************
/* Formatted on 2008/01/08 14:30 (Formatter Plus v4.8.7) University of Minnesota Foundation*/
FUNCTION indv_largest_gift_clg (
--This function returns the date, amount, fund number, description, solicitation(
-- camp, drive, audience, and college for the largest gift(money-in-the-door),
-- for an individual id_demo, if exists, else null.
   id_demo_in     IN   q_production_id.id_demo%TYPE
 , nbr_seq_in     IN   NUMBER DEFAULT 1
 , code_clg_opt   IN   q_production.code_clg%TYPE DEFAULT '%'
 , add_spa        IN   q_production_id.code_recipient%TYPE DEFAULT NULL
)
   RETURN VARCHAR2
IS
--VARIABLES
   largest_gift   VARCHAR (200) := NULL;
BEGIN
   IF code_clg_opt = '%'
   THEN
      SELECT    g.date_tran
             || '~'
             || TO_CHAR (NVL (g.amt_fund, '0'), '999999999.00')
             || '~'
             || NVL (g.nbr_fund, ' ')
             || '~'
             || NVL (funds.fdesc (nbr_fund), ' ')
             || '~'
             || NVL (g.code_camp, ' ')
             || NVL (g.code_drive, ' ')
             || NVL (g.code_audience, ' ')
             || '~'
             || NVL (g.code_clg, ' ')
             || '~'
        INTO largest_gift
        FROM (SELECT l.*
                   , RANK () OVER (ORDER BY l.amt_fund DESC, ROWNUM) rank_amt
                FROM (SELECT p.code_clg
                           , p.date_tran
                           , p.nbr_fund
                           , p.amt_fund
                           , p.code_camp
                           , p.code_drive
                           , p.code_audience
                        FROM q_receipted_id p
                       WHERE p.code_anon = '0'
                        AND p.code_recipient IN
                            ( global_constants.std_u
                            , global_constants.std_f
                            , global_constants.std_m
                            , indv_largest_gift_clg.add_spa)
                         AND p.code_exp_type NOT IN ('MT', 'MR')
                         AND p.id_demo = id_demo_in) l) g
       WHERE g.rank_amt = nbr_seq_in;
   ELSE
      SELECT    g.date_tran
             || '~'
             || TO_CHAR (NVL (g.amt_fund, '0'), '999999999.00')
             || '~'
             || NVL (g.nbr_fund, ' ')
             || '~'
             || NVL (funds.fdesc (nbr_fund), ' ')
             || '~'
             || NVL (g.code_camp, ' ')
             || NVL (g.code_drive, ' ')
             || NVL (g.code_audience, ' ')
             || '~'
             || NVL (g.code_clg, ' ')
             || '~'
        INTO largest_gift
        FROM (SELECT l.*
                   , RANK () OVER (ORDER BY l.amt_fund DESC, ROWNUM) rank_amt
                FROM (SELECT p.code_clg
                           , p.date_tran
                           , p.nbr_fund
                           , p.amt_fund
                           , p.code_camp
                           , p.code_drive
                           , p.code_audience
                        FROM q_receipted_id p
                       WHERE p.code_anon = '0'
                        AND p.code_recipient IN
                            ( global_constants.std_u
                            , global_constants.std_f
                            , global_constants.std_m
                            , indv_largest_gift_clg.add_spa)
                         AND p.code_exp_type NOT IN ('MT', 'MR')
                         AND p.code_clg = code_clg_opt
                         AND p.id_demo = id_demo_in) l) g
       WHERE g.rank_amt = nbr_seq_in;
   END IF;

   RETURN largest_gift;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END indv_largest_gift_clg;


--***********************************************************
/* Formatted on 2008/01/08 14:29 (Formatter Plus v4.8.7) University of Minnesota Foundation*/
FUNCTION hh_largest_outright_gift_clg (
--This function returns the date, amount, fund number, description, solicitation(
-- camp, drive, audience) and college for the largest outright gift to the
-- university(default) or to a college(optional)
-- (code_exp_type = 'G'), if exists, else null.
   id_demo_in     IN   q_production_id.id_demo%TYPE
 , nbr_seq_in     IN   NUMBER DEFAULT 1
 , code_clg_opt   IN   q_production.code_clg%TYPE DEFAULT '%'
 , add_spa        IN   q_production_id.code_recipient%TYPE DEFAULT NULL
)
   RETURN VARCHAR2
IS
--VARIABLES
   largest_gift   VARCHAR (200) := NULL;
   spouser        NUMBER        := i_info.id_spouse (id_demo_in);
BEGIN
   IF code_clg_opt = '%'
   THEN
      SELECT    g.date_tran
             || '~'
             || TO_CHAR (NVL (g.amt_fund, '0'), '999999999.00')
             || '~'
             || NVL (g.nbr_fund, ' ')
             || '~'
             || NVL (funds.fdesc (nbr_fund), ' ')
             || '~'
             || NVL (g.code_camp, ' ')
             || NVL (g.code_drive, ' ')
             || NVL (g.code_audience, ' ')
             || '~'
             || NVL (g.code_clg, ' ')
             || '~'
        INTO largest_gift
        FROM (SELECT l.*
                   , RANK () OVER (ORDER BY l.amt_fund DESC, ROWNUM) rank_amt
                FROM (SELECT p.code_clg
                           , p.date_tran
                           , p.nbr_fund
                           , p.amt_fund
                           , p.code_camp
                           , p.code_drive
                           , p.code_audience
                        FROM q_receipted_id p
                       WHERE p.code_anon = '0'
                         AND p.code_recipient IN
                            ( global_constants.std_u
                            , global_constants.std_f
                            , global_constants.std_m
                            , hh_largest_outright_gift_clg.add_spa)
                         AND p.code_exp_type = 'G'
                         AND p.id_demo = id_demo_in
                      UNION
                      SELECT p.code_clg
                           , p.date_tran
                           , p.nbr_fund
                           , p.amt_fund
                           , p.code_camp
                           , p.code_drive
                           , p.code_audience
                        FROM q_receipted_id p
                       WHERE p.code_anon = '0'
                         AND p.code_recipient IN
                            ( global_constants.std_u
                            , global_constants.std_f
                            , global_constants.std_m
                            , hh_largest_outright_gift_clg.add_spa)
                         AND p.code_exp_type = 'G'
                         AND p.id_demo = spouser) l) g
       WHERE g.rank_amt = nbr_seq_in;
   ELSE
      SELECT    g.date_tran
             || '~'
             || TO_CHAR (NVL (g.amt_fund, '0'), '999999999.00')
             || '~'
             || NVL (g.nbr_fund, ' ')
             || '~'
             || NVL (funds.fdesc (nbr_fund), ' ')
             || '~'
             || NVL (g.code_camp, ' ')
             || NVL (g.code_drive, ' ')
             || NVL (g.code_audience, ' ')
             || '~'
             || NVL (g.code_clg, ' ')
             || '~'
        INTO largest_gift
        FROM (SELECT l.*
                   , RANK () OVER (ORDER BY l.amt_fund DESC, ROWNUM) rank_amt
                FROM (SELECT p.code_clg
                           , p.date_tran
                           , p.nbr_fund
                           , p.amt_fund
                           , p.code_camp
                           , p.code_drive
                           , p.code_audience
                        FROM q_receipted_id p
                       WHERE p.code_anon = '0'
                         AND p.code_recipient IN
                            ( global_constants.std_u
                            , global_constants.std_f
                            , global_constants.std_m
                            , hh_largest_outright_gift_clg.add_spa)
                         AND p.code_exp_type = 'G'
                         AND p.code_clg = code_clg_opt
                         AND p.id_demo = id_demo_in
                      UNION
                      SELECT p.code_clg
                           , p.date_tran
                           , p.nbr_fund
                           , p.amt_fund
                           , p.code_camp
                           , p.code_drive
                           , p.code_audience
                        FROM q_receipted_id p
                       WHERE p.code_anon = '0'
                         AND p.code_recipient IN
                            ( global_constants.std_u
                            , global_constants.std_f
                            , global_constants.std_m
                            , hh_largest_outright_gift_clg.add_spa)
                         AND p.code_exp_type = 'G'
                         AND p.code_clg = code_clg_opt
                         AND p.id_demo = spouser) l) g
       WHERE g.rank_amt = nbr_seq_in;
   END IF;

   RETURN largest_gift;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END hh_largest_outright_gift_clg;


--***********************************************************
   FUNCTION hh_largest_outright_gift_dept (
--This function returns the date, amount, fund number, description, solicitation(
-- camp, drive, audience) and college for the largest outright gift to a department
-- (code_exp_type = 'G'), if exists, else null.
      id_demo_in     IN   q_production_id.id_demo%TYPE
    , nbr_seq_in     IN   NUMBER DEFAULT 1
    , code_dept_in   IN   q_production.code_clg%TYPE
    , add_spa        IN   q_production_id.code_recipient%TYPE DEFAULT NULL
   )
      RETURN VARCHAR2
   IS
--VARIABLES
      largest_gift   VARCHAR (200) := NULL;
      spouser        NUMBER        := i_info.id_spouse (id_demo_in);
   BEGIN
      SELECT    g.date_tran
             || '~'
             || TO_CHAR (NVL (g.amt_fund, '0'), '999999999.00')
             || '~'
             || NVL (g.nbr_fund, ' ')
             || '~'
             || NVL (funds.fdesc (nbr_fund), ' ')
             || '~'
             || NVL (g.code_camp, ' ')
             || NVL (g.code_drive, ' ')
             || NVL (g.code_audience, ' ')
             || '~'
             || NVL (g.code_clg, ' ')
             || '~'
        INTO largest_gift
        FROM (SELECT l.*
                   , RANK () OVER (ORDER BY l.amt_fund DESC, ROWNUM) rank_amt
                FROM (SELECT p.code_clg
                           , p.date_tran
                           , p.nbr_fund
                           , p.amt_fund
                           , p.code_camp
                           , p.code_drive
                           , p.code_audience
                        FROM q_receipted_id p
                       WHERE p.code_anon = '0'
                         AND p.code_recipient IN
                            ( global_constants.std_u
                            , global_constants.std_f
                            , global_constants.std_m
                            , hh_largest_outright_gift_dept.add_spa)
                         AND p.code_exp_type = 'G'
                         AND p.code_dept = code_dept_in
                         AND p.id_demo = id_demo_in
                      UNION
                      SELECT p.code_clg
                           , p.date_tran
                           , p.nbr_fund
                           , p.amt_fund
                           , p.code_camp
                           , p.code_drive
                           , p.code_audience
                        FROM q_receipted_id p
                       WHERE p.code_anon = '0'
                         AND p.code_recipient IN
                            ( global_constants.std_u
                            , global_constants.std_f
                            , global_constants.std_m
                            , hh_largest_outright_gift_dept.add_spa)
                         AND p.code_exp_type = 'G'
                         AND p.code_dept = code_dept_in
                         AND p.id_demo = spouser) l) g
       WHERE g.rank_amt = nbr_seq_in;

      RETURN largest_gift;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END hh_largest_outright_gift_dept;
--***********************************************************
   FUNCTION dept (string_in IN VARCHAR2)
      RETURN VARCHAR2
   IS
--VARIABLES
      tdept   q_production.code_dept%TYPE;

--CURSORS
      CURSOR last_gift_cur
      IS
         SELECT SUBSTR (string_in
                      , INSTR (string_in
                             , '~'
                             , 1
                             , 6
                              ) + 1
                      ,   (  INSTR (string_in
                                  , '~'
                                  , 1
                                  , 7
                                   )
                           - INSTR (string_in
                                  , '~'
                                  , 1
                                  , 6
                                   )
                          )
                        - 1
                       ) string_out
           FROM DUAL;
--RECORD TYPES
--PL/SQL TABLE TYPES
--RECORDS
--PL/SQL TABLES
   BEGIN
      tdept := ' ';

      FOR rec IN last_gift_cur
      LOOP
         tdept := rec.string_out;
      END LOOP;

      RETURN tdept;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END dept;
--***********************************************************
    FUNCTION hh_largest_umf_commit_clg (
--This function returns the date, amount, fund number, description, solicitation(
-- camp, drive, audience) and college for the largets UMF commitment,
-- if exists, else null.
      id_demo_in     IN   q_production_id.id_demo%TYPE
    , nbr_seq_in     IN   NUMBER DEFAULT 1
    , code_clg_opt   IN   q_production.code_clg%TYPE DEFAULT '%'
    , add_spa        IN   q_production_id.code_recipient%TYPE DEFAULT NULL
   )
      RETURN VARCHAR2
   IS
--VARIABLES
      largest_gift   VARCHAR (200) := NULL;
      spouser        NUMBER        := i_info.id_spouse (id_demo_in);
   BEGIN
      IF code_clg_opt = '%'
      THEN
         SELECT    g.date_tran
                || '~'
                || TO_CHAR (NVL (g.amt_fund, '0'), '999999999.00')
                || '~'
                || NVL (g.nbr_fund, ' ')
                || '~'
                || NVL (funds.fdesc (nbr_fund), ' ')
                || '~'
                || NVL (g.code_camp, ' ')
                || NVL (g.code_drive, ' ')
                || NVL (g.code_audience, ' ')
                || '~'
                || NVL (g.code_clg, ' ')
                || '~'
                || NVL (g.code_dept, ' ')
                || '~'
           INTO largest_gift
           FROM (SELECT l.*
                      , RANK () OVER (ORDER BY l.amt_fund DESC, ROWNUM)
                                                                     rank_amt
                   FROM (SELECT p.code_clg
                              , p.date_tran
                              , p.nbr_fund
                              , p.amt_fund
                              , p.code_camp
                              , p.code_drive
                              , p.code_audience
                              , p.code_dept
                           FROM q_production_id p
                          WHERE p.code_anon = '0'
                            AND p.code_exp_type NOT IN ('MT', 'MR')
                            AND p.code_recipient IN
                                ( global_constants.std_u
                                , global_constants.std_f
                             --   , global_constants.std_m
                                , hh_largest_umf_commit_clg.add_spa)
                            AND p.id_demo = id_demo_in
                         UNION
                         SELECT p.code_clg
                              , p.date_tran
                              , p.nbr_fund
                              , p.amt_fund
                              , p.code_camp
                              , p.code_drive
                              , p.code_audience
                              , p.code_dept
                           FROM q_production_id p
                          WHERE p.code_anon = '0'
                            AND p.code_exp_type NOT IN ('MT', 'MR')
                            AND p.code_recipient IN
                                ( global_constants.std_u
                                , global_constants.std_f
                             --   , global_constants.std_m
                                , hh_largest_umf_commit_clg.add_spa)
                            AND p.id_demo = spouser) l) g
          WHERE g.rank_amt = nbr_seq_in;
      ELSE
         SELECT    g.date_tran
                || '~'
                || TO_CHAR (NVL (g.amt_fund, '0'), '999999999.00')
                || '~'
                || NVL (g.nbr_fund, ' ')
                || '~'
                || NVL (funds.fdesc (nbr_fund), ' ')
                || '~'
                || NVL (g.code_camp, ' ')
                || NVL (g.code_drive, ' ')
                || NVL (g.code_audience, ' ')
                || '~'
                || NVL (g.code_clg, ' ')
                || '~'
           INTO largest_gift
           FROM (SELECT l.*
                      , RANK () OVER (ORDER BY l.amt_fund DESC, ROWNUM)
                                                                     rank_amt
                   FROM (SELECT p.code_clg
                              , p.date_tran
                              , p.nbr_fund
                              , p.amt_fund
                              , p.code_camp
                              , p.code_drive
                              , p.code_audience
                           FROM q_production_id p
                          WHERE p.code_anon = '0'
                            AND p.code_recipient IN
                                ( global_constants.std_u
                                , global_constants.std_f
                            --   , global_constants.std_m
                                , hh_largest_umf_commit_clg.add_spa)
                            AND p.code_exp_type NOT IN ('MT', 'MR')
                            AND p.code_clg = code_clg_opt
                            AND p.id_demo = id_demo_in
                         UNION
                         SELECT p.code_clg
                              , p.date_tran
                              , p.nbr_fund
                              , p.amt_fund
                              , p.code_camp
                              , p.code_drive
                              , p.code_audience
                           FROM q_production_id p
                          WHERE p.code_anon = '0'
                            AND p.code_recipient IN
                                ( global_constants.std_u
                                , global_constants.std_f
                            --    , global_constants.std_m
                                , hh_largest_umf_commit_clg.add_spa)
                            AND p.code_exp_type NOT IN ('MT', 'MR')
                            AND p.code_clg = code_clg_opt
                            AND p.id_demo = spouser) l) g
          WHERE g.rank_amt = nbr_seq_in;
      END IF;

      RETURN largest_gift;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END hh_largest_umf_commit_clg;
--***********************************************************
    FUNCTION rel_largest_commit_clg (
--This function returns the date, amount, fund number, description, solicitation(
-- camp, drive, audience), college and id_demo_receipt for the largets related commitment,
-- if exists, else null.
      id_demo_in     IN   q_production_id.id_demo%TYPE
    , nbr_seq_in     IN   NUMBER DEFAULT 1
    , code_clg_opt   IN   q_production.code_clg%TYPE DEFAULT '%'
    , code_anon_in   IN   q_production.code_anon%TYPE DEFAULT '1'
    , add_spa        IN   q_production_id.code_recipient%TYPE DEFAULT NULL
   )
      RETURN VARCHAR2
   IS
--VARIABLES
      largest_gift   VARCHAR (200) := NULL;
      spouser        NUMBER        := i_info.id_spouse (id_demo_in);
   BEGIN
      IF code_clg_opt = '%'
      THEN
         SELECT    g.date_tran
                || '~'
                || TO_CHAR (NVL (g.amt_fund, '0'), '999999999.00')
                || '~'
                || NVL (g.nbr_fund, ' ')
                || '~'
                || NVL (funds.fdesc (nbr_fund), ' ')
                || '~'
                || NVL (g.code_camp, ' ')
                || NVL (g.code_drive, ' ')
                || NVL (g.code_audience, ' ')
                || '~'
                || NVL (g.code_clg, ' ')
                || '~'
                || NVL (g.code_dept, ' ')
                || '~'
                || NVL (to_char(g.id_demo_receipt), ' ')
                || '~'
           INTO largest_gift
           FROM (SELECT l.*
                      , RANK () OVER (ORDER BY l.amt_fund DESC, ROWNUM)
                                                                     rank_amt
                   FROM (SELECT distinct
                                p.id_gift
                              , p.code_pmt_form
                              , p.code_clg
                              , p.date_tran
                              , p.nbr_fund
                              , p.amt_fund
                              , p.code_camp
                              , p.code_drive
                              , p.code_audience
                              , p.code_dept
                              , p.id_demo_receipt
                           FROM q_production_id p
                            ,  (select r.id_demo_rel
                                from relation r
                                where r.id_demo = id_demo_in
                                and   r.flag_give_rel = 'Y'
                                union all
                                select id_demo_in
                                from dual
                                ) x
                          WHERE p.code_anon <= code_anon_in
                          --p.code_anon = '0'
                        --   where p.code_anon < '2'
                            AND p.code_exp_type NOT IN ('MT', 'MR')
                            AND p.code_recipient IN
                                ( global_constants.std_u
                                , global_constants.std_f
                                , global_constants.std_m
                                , rel_largest_commit_clg.add_spa)
                            AND p.id_demo = x.id_demo_rel ) l
                   ) g
          WHERE g.rank_amt = nbr_seq_in;
      ELSE
         SELECT    g.date_tran
                || '~'
                || TO_CHAR (NVL (g.amt_fund, '0'), '999999999.00')
                || '~'
                || NVL (g.nbr_fund, ' ')
                || '~'
                || NVL (funds.fdesc (nbr_fund), ' ')
                || '~'
                || NVL (g.code_camp, ' ')
                || NVL (g.code_drive, ' ')
                || NVL (g.code_audience, ' ')
                || '~'
                || NVL (g.code_clg, ' ')
                || '~'
                || NVL (to_char(g.id_demo_receipt), ' ')
                || '~'
           INTO largest_gift
           FROM (SELECT l.*
                      , RANK () OVER (ORDER BY l.amt_fund DESC, ROWNUM)
                                                                     rank_amt
                   FROM (SELECT distinct
                                p.id_gift
                              , p.code_pmt_form
                              , p.code_clg
                              , p.date_tran
                              , p.nbr_fund
                              , p.amt_fund
                              , p.code_camp
                              , p.code_drive
                              , p.code_audience
                              , p.id_demo_receipt
                           FROM q_production_id p
                            ,  (select r.id_demo_rel
                                from relation r
                                where r.id_demo = id_demo_in
                                and   r.flag_give_rel = 'Y'
                                union all
                                select id_demo_in
                                from dual
                                ) x
                          WHERE p.code_anon <= code_anon_in
                          --p.code_anon = '0'
                     --     where p.code_anon < '2'
                            AND p.code_recipient IN
                                ( global_constants.std_u
                                , global_constants.std_f
                                , global_constants.std_m
                                , rel_largest_commit_clg.add_spa)
                            AND p.code_exp_type NOT IN ('MT', 'MR')
                            AND p.code_clg = code_clg_opt
                            AND p.id_demo = x.id_demo_rel) l
                  ) g
          WHERE g.rank_amt = nbr_seq_in;
      END IF;

      RETURN largest_gift;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END rel_largest_commit_clg;
--***********************************************************
   FUNCTION id_demo_receipt (string_in IN VARCHAR2)
      RETURN VARCHAR2
   IS
--VARIABLES
      tdept   VARCHAR2(10);

--CURSORS
      CURSOR last_gift_cur
      IS
         SELECT SUBSTR (string_in
                      , INSTR (string_in
                             , '~'
                             , 1
                             , 7
                              ) + 1
                      ,   (  INSTR (string_in
                                  , '~'
                                  , 1
                                  , 8
                                   )
                           - INSTR (string_in
                                  , '~'
                                  , 1
                                  , 7
                                   )
                          )
                        - 1
                       ) string_out
           FROM DUAL;
--RECORD TYPES
--PL/SQL TABLE TYPES
--RECORDS
--PL/SQL TABLES
   BEGIN
      tdept := ' ';

      FOR rec IN last_gift_cur
      LOOP
         tdept := rec.string_out;
      END LOOP;

      RETURN tdept;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END id_demo_receipt;
--***********************************************************
   -- Enter further code below as specified in the Package spec.
END;