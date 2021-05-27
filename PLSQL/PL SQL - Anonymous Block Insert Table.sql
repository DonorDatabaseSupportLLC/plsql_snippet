-- creating table with single column
-- add 10 digits 
create table integers
(i integer not null );

--DELETE FROM integers PURGE;
TRUNCATE TABLE integers;

--block to insert 
DECLARE
    i NUMBER := 0;
BEGIN
   LOOP
     INSERT INTO integers VALUES(i);
        i := i+1;
        EXIT WHEN i > 25;
    END LOOP;
    COMMIT; 
END;

--see table data inserted
SELECT * FROM integers;


PROMPT ****************  build consecutive giving years IN Q_production_id  ***************

--A. consecutive years 
select to_char(SYSDATE,'YYYY') - i as yr
  from integers i 
WHERE i BETWEEN 0 AND 10;



--build consecutive giving years
DROP TABLE consec_giving_years ;
CREATE TABLE consec_giving_years AS 
SELECT x.id_rel 
     , max(x.yr)                                              AS FirstMissing
     , to_number(to_char(SYSDATE, 'YYYY'))- max(x.yr)         AS Consec_Years
  FROM (SELECT i.id_rel
               , to_number(to_char(SYSDATE, 'YYYY')) - intg.i  AS yr
         FROM integers intg 
         CROSS JOIN ( SELECT id_rel
                            , year_fiscal
                            , g.code_anon 
                      FROM t201602607_gifts g 
                     -- WHERE g.id_rel = 930329335
                     )  i    
       )x 
LEFT JOIN t201602607_gifts t ON t.id_rel  = x.id_rel 
                            AND t.year_fiscal = x.yr
 WHERE t.id_rel IS NULL 
 GROUP BY x.id_rel 
 HAVING to_number(to_char(SYSDATE, 'YYYY')) - MAX(x.yr)  > 0;
 
SELECT * FROM consec_giving_years i WHERE i.id_rel IN (200493705 /*930329335*/);--id_rel: 930329335  --consec. yrs: 12.  --Missed: 2004
 SELECT * FROM t201602607_gifts   i WHERE i.id_rel IN (200493705 /*930329335*/);
 
 
 PROMPT ************ consecutive giving: filter_fun.functions() ********************
 SELECT s.year_fiscal
 FROM ( SELECT p.year_fiscal -- , p.id_demo
          FROM q_production_id p
         WHERE p.code_anon <= 1
           AND p.code_clg = 'LAW'
           AND p.year_fiscal BETWEEN 1992 AND 2016
           AND p.id_demo = 700391143
        GROUP BY p.year_fiscal
       )s
       
      UNION
      SELECT   p.year_fiscal
          FROM q_production_id p
         WHERE p.code_anon <= 1
           AND p.code_clg = 'LAW'
           AND p.year_fiscal BETWEEN 1992 AND 2016
           AND p.id_demo = i_info.id_spouse (700391143)
       GROUP BY p.year_fiscal
      ) s
      ORDER BY 1 DESC; --24 (wrong: missing 2004)
  
 
 -------------- Query Request  ----------------------
  Prompt*********************** law_js_201602607_v1 ******************************
/* Originally Created on 24-AUG-2016
Author: s. xiong
Query: 201602607
*/


/*Description:  */

--Donor Roster that includes anonymous gifts (coded as "Anonymous" Donor)
--*** RE-RUNS: Only tables a, aa, and b need adjustment for other college/units/time ranges
--Based upon two_prong

DROP TABLE t201602607_gifts;
CREATE TABLE t201602607_gifts AS 
SELECT a.id_rel
     , a.year_fiscal
     , decode(a.code_anon,'0','0','2') code_anon  --all anonymous gifts = 2
FROM
(
   SELECT DISTINCT
          p.id_rel
        , p.code_anon
        , p.year_fiscal
   FROM q_production_id p
   WHERE p.code_clg = 'LAW'
     AND p.year_fiscal >= 1992
     AND p.code_recipient IN ('U','F')
     AND p.code_anon IN ('0','1','2')
   UNION
   SELECT DISTINCT
          p.id_rel
        , p.code_anon
        , p.year_fiscal
   FROM q_receipted_id p
   WHERE p.code_clg = 'LAW'
     AND p.year_fiscal >= 1992
     AND p.code_recipient IN ('U','F')
     AND p.code_anon IN ('0','1','2')
 ) a 
GROUP BY 
         a.id_rel
       , a.year_fiscal
       , decode(a.code_anon,'0','0','2')
;       
SELECT * FROM t201602607_gifts;


DROP TABLE t201602607_giving;
CREATE TABLE t201602607_giving AS 
SELECT g.id_rel
       , g.code_anon
       , count(CASE WHEN g.year_fiscal BETWEEN 2012 AND 2016
                    THEN 1
                    ELSE NULL
               END) AS last_5_yrs 
       , count(CASE WHEN g.year_fiscal BETWEEN 2007 AND 2016
                    THEN 1
                    ELSE NULL
               END) AS last_10_yrs
       , count(CASE WHEN g.year_fiscal BETWEEN 2002 AND 2016
                    THEN 1
                    ELSE NULL
               END) AS last_15_yrs
       , count(CASE WHEN g.year_fiscal BETWEEN 1997 AND 2016
                    THEN 1
                    ELSE NULL
               END) AS last_20_yrs
       , count(CASE WHEN g.year_fiscal BETWEEN 1992 AND 2016
                    THEN 1
                    ELSE NULL
               END) AS last_25_yrs
FROM t201602607_gifts g
GROUP BY g.id_rel, g.code_anon
;
SELECT * FROM t201602607_giving g WHERE g.id_rel = 930329335;


prompt ********* commitments *********
DROP TABLE t201602607a;
CREATE TABLE t201602607a AS
SELECT a.id_rel
     , decode(a.code_anon,'0','0','2') code_anon  --all anonymous gifts = 2
     , SUM(a.amt_fund) total
FROM
  (
   SELECT
     DISTINCT
     p.id_rel
   , p.nbr_fund
   , p.id_gift
   , p.code_pmt_form
   , p.code_exp_type
   , p.amt_fund
   , p.code_anon
   , p.year_fiscal
   FROM
     q_production_id p
   WHERE p.code_clg = 'LAW'
   AND p.code_recipient IN ('U','F')
   AND p.code_anon IN ('0','1','2')
   ) a 
GROUP BY 
  a.id_rel
  , decode(a.code_anon,'0','0','2')
;
SELECT * FROM t201602607a;
SELECT COUNT(*) t201602607a FROM t201602607a;--11613

prompt ********* mitd *********
DROP TABLE t201602607aa;
CREATE TABLE t201602607aa AS
SELECT a.id_rel
     , decode(a.code_anon,'0','0','2') code_anon  --all anonymous gifts = 2
     , SUM(a.amt_fund) total
FROM
  (
   SELECT
     DISTINCT
     p.id_rel
   , p.nbr_fund
   , p.id_gift
   , p.code_pmt_form
   , p.code_exp_type
   , p.amt_fund
   , p.code_anon
   , p.id_expectancy
   , p.year_fiscal
   FROM
     q_receipted_id p
   WHERE p.code_clg = 'LAW'
   AND p.code_recipient IN ('U','F')
   AND p.code_anon IN ('0','1','2')
   ) a 
GROUP BY 
  a.id_rel
  , decode(a.code_anon,'0','0','2')
;
SELECT * FROM t201602607aa;
SELECT COUNT(*) t201602607aa FROM t201602607aa;--11683


prompt *********** b *************
DROP TABLE t201602607b;
CREATE TABLE t201602607b AS
SELECT
  a.id_demo
FROM
  (
   SELECT
     p.id_demo
   FROM
     q_production_id P
   WHERE p.code_clg = 'LAW'
   AND p.code_recipient IN ('U','F')
   AND p.code_anon IN ('0','1','2')
   UNION
   SELECT
     p.id_demo
   FROM
     q_receipted_id P
   WHERE p.code_clg = 'LAW'
   AND p.code_recipient IN ('U','F')
   AND p.code_anon IN ('0','1','2')
   ) a
;
SELECT * FROM t201602607b;
SELECT COUNT(*) t201602607b FROM t201602607b;--13842


prompt ********** stacker *************
EXEC qstackerrel('t201602607b','t201602607c','N','N');
SELECT COUNT(*) t201602607c FROM t201602607c;--12143
SELECT * FROM t201602607c;


prompt *********** dd *************
DROP TABLE t201602607dd;
CREATE TABLE t201602607dd AS
SELECT
  s.*
  , CASE WHEN tg.last_5_yrs = 5
         THEN 'Y'
         ELSE 'N'
    END AS last_5_yrs_giving
  , CASE WHEN tg.last_10_yrs = 10
         THEN 'Y'
         ELSE 'N'
    END AS last_10_yrs_giving
  , CASE WHEN tg.last_15_yrs = 15
         THEN 'Y'
         ELSE 'N'
    END AS last_15_yrs_giving
  , CASE WHEN tg.last_20_yrs = 20
         THEN 'Y'
         ELSE 'N'
    END AS last_20_yrs_giving
  , CASE WHEN tg.last_25_yrs = 25
         THEN 'Y'
         ELSE 'N'
    END AS last_25_yrs_giving
  , CASE WHEN tg_anon.last_5_yrs = 5
         THEN 'Y'
         ELSE 'N'
    END AS last_5_yrs_giving_anon
  , CASE WHEN tg_anon.last_10_yrs = 10
         THEN 'Y'
         ELSE 'N'
    END AS last_10_yrs_giving_anon
  , CASE WHEN tg_anon.last_15_yrs = 15
         THEN 'Y'
         ELSE 'N'
    END AS last_15_yrs_giving_anon
  , CASE WHEN tg_anon.last_20_yrs = 20
         THEN 'Y'
         ELSE 'N'
    END AS last_20_yrs_giving_anon
  , CASE WHEN tg_anon.last_25_yrs = 25
         THEN 'Y'
         ELSE 'N'
    END AS last_25_yrs_giving_anon
FROM
  t201602607c s LEFT JOIN t201602607_giving tg      ON s.id_rel = tg.id_rel      AND tg.code_anon = '0'
                LEFT JOIN t201602607_giving tg_anon ON s.id_rel = tg_anon.id_rel AND tg_anon.code_anon = '2'
;
SELECT * FROM t201602607dd dd WHERE dd.id_rel = 930329335;
SELECT * FROM t201602607_giving dd WHERE dd.id_rel =  930329335; 


prompt *********** d *************
DROP TABLE t201602607d;
CREATE TABLE t201602607d AS
SELECT
  s.*
, nvl(tc.total,0) total_commit
, nvl(tg.total,0) total_mitd
, nvl(greatest(nvl(tc.total,0),nvl(tg.total,0)),0) AS largest_total
, nvl(tc_anon.total,0) total_commit_anon
, nvl(tg_anon.total,0) total_mitd_anon
, nvl(greatest(nvl(tc_anon.total,0),nvl(tg_anon.total,0)),0) AS largest_anon
FROM
  t201602607dd s LEFT OUTER JOIN t201602607a  tc      ON s.id_rel = tc.id_rel      AND tc.code_anon = '0'
                 LEFT OUTER JOIN t201602607aa tg      ON s.id_rel = tg.id_rel      AND tg.code_anon = '0'
                 LEFT OUTER JOIN t201602607a  tc_anon ON s.id_rel = tc_anon.id_rel AND tc_anon.code_anon = '2'
                 LEFT OUTER JOIN t201602607aa tg_anon ON s.id_rel = tg_anon.id_rel AND tg_anon.code_anon = '2'
;
SELECT * FROM t201602607d;


prompt *********** e SEND THIS TABLE *************
DROP TABLE t201602607e;
CREATE TABLE t201602607e AS
SELECT id_demo
       , name_label
       , id_spouse
       , name2_label
       , namer.comb_stacked_deceased(id_demo,id_spouse) AS name_label_comb
       , namer.roster(id_demo) AS name_roster
       , name_last
       , id_household
       , id_rel
       , total_commit AS total_commit_ltd
       , total_mitd AS total_mitd_ltd
       , largest_total AS largest_total_ltd
       , CASE WHEN largest_total >= 10000 THEN 1
              WHEN largest_total >=  1000 THEN 2
              WHEN largest_total >=   500 THEN 3
              WHEN largest_total >      0 THEN 4
         END AS donation_sort
       , CASE WHEN largest_total >= 10000 THEN '$10,000+'
              WHEN largest_total >=  1000 THEN '$1,000-$10,000'
              WHEN largest_total >=   500 THEN '$500-$999'
              WHEN largest_total >      0 THEN 'Up to $499'
         END AS donation_range
       , last_5_yrs_giving
       , last_10_yrs_giving
       , last_15_yrs_giving
       , last_20_yrs_giving
       , last_25_yrs_giving
FROM t201602607d d
WHERE largest_total > 0    --only includes non-anonymous gifts
  AND (last_5_yrs_giving = 'Y' 
    OR last_10_yrs_giving = 'Y' 
    OR last_15_yrs_giving = 'Y' 
    OR last_20_yrs_giving = 'Y' 
    OR last_25_yrs_giving = 'Y')
UNION
SELECT 999999999 AS id_demo
       , 'Anonymous Donor' AS name_label
       , 999999999 AS id_spouse
       , 'Anonymous Donor' AS name2_label
       , 'Anonymous Donor' AS name_label_comb
       , 'Anonymous Donor' AS name_roster
       , 'Anonymous Donor' AS name_last
       , 999999999 AS id_household
       , 999999999 AS id_rel
       , total_commit_anon
       , total_mitd_anon
       , largest_anon
       , CASE WHEN largest_anon >= 10000 THEN 1
              WHEN largest_anon >=  1000 THEN 2
              WHEN largest_anon >=   500 THEN 3
              WHEN largest_anon >      0 THEN 4
         END AS donation_sort
       , CASE WHEN largest_anon >= 10000 THEN '$10,000+'
              WHEN largest_anon >=  1000 THEN '$1,000-$10,000'
              WHEN largest_anon >=   500 THEN '$500-$999'
              WHEN largest_anon >      0 THEN 'Up to $499'
         END AS donation_range
       , last_5_yrs_giving_anon
       , last_10_yrs_giving_anon
       , last_15_yrs_giving_anon
       , last_20_yrs_giving_anon
       , last_25_yrs_giving_anon
FROM t201602607d d
WHERE largest_anon > 0      --Anonymous 1 or 2 gifts included here
  AND (last_5_yrs_giving_anon = 'Y' 
    OR last_10_yrs_giving_anon = 'Y' 
    OR last_15_yrs_giving_anon = 'Y' 
    OR last_20_yrs_giving_anon = 'Y' 
    OR last_25_yrs_giving_anon = 'Y')
;
SELECT * FROM t201602607e;--797


