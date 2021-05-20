--Count: Alums, Individual, Org,Corp and Foundation -without FY

--EIS Source
--DROP TABLE t999999999a;
--CREATE TABLE t999999999a AS
WITH 
		temp_money AS (
										SELECT DISTINCT 
                    				(SELECT GREATEST(p.id_demo,NVL(MAX(r.id_demo_rel),0)) 
                             FROM relation r
                             WHERE p.id_demo = r.id_demo
                             AND r.flag_give_rel = 'Y'	
                            ) 																													AS id_rel
                           , (SELECT LEAST(p.id_demo,NVL(MIN(r.id_demo_rel),p.id_demo)) 
                              FROM relation r 
                              WHERE p.id_demo = r.id_demo
                              AND r.flag_give_rel = 'Y'
                             ) 	 																												AS id_least
                           , p.id_demo 
                           , p.code_clg
                           , p.code_dept
                           , p.amt_fund
                           , p.year_fiscal
                           , id_gift 
                           , nbr_fund
                           , code_pmt_form 
                           , code_exp_type 
                    FROM q_production_id p
                    WHERE p.code_clg = 'MED'
                    AND p.code_dept = '2412'
                    AND p.year_fiscal BETWEEN 2014 AND 2018
                    AND p.code_recipient != 'S'
                    AND p.code_anon IN ('0','1','2')
                    ) 
    , temp_commit AS (SELECT id_rel
                             , id_least
                             , year_fiscal
                             , SUM(amt_fund) total
                      FROM temp_money
                      GROUP BY id_rel
                      				, id_least
                              , year_fiscal
                      )
    , temp_rel_org AS (SELECT id_rel
                              , ww.code_org_type
                              , ot.desc_org_type
                              , ranking
                       FROM (SELECT 
                              id_rel
                              , code_org_type
                              , rank() over (PARTITION BY id_rel
                                             ORDER BY CASE WHEN nvl(oo.code_org_type,'X') = 'C'
                                                                THEN 1
                                                           WHEN nvl(oo.code_org_type,'X') IN ('CF','CM','FF','IF')
                                                                THEN 2
                                                           WHEN nvl(oo.code_org_type,'X') = 'E'
                                                                THEN 3
                                                           WHEN nvl(oo.code_org_type,'X') = 'G'
                                                                THEN 4
                                                           WHEN nvl(oo.code_org_type,'X') = 'N'
                                                                THEN 5
                                                           WHEN nvl(oo.code_org_type,'X') IN ('A','P','PA','PC','T')
                                                                THEN 6
                                                           ELSE 7 END
                                                      , rownum
                                             ) ranking
                       FROM (
                       			 SELECT (SELECT GREATEST(r.id_demo,NVL(MAX(r3.id_demo_rel),0)) 
                                     FROM relation r3 
                                     WHERE r.id_demo = r3.id_demo
                                     AND r3.flag_give_rel = 'Y'
                                     )AS id_rel
                                    , r.id_demo
                                    , o.code_org_type
                             FROM relation r 
                                    JOIN q_organization o ON r.id_demo_rel = o.id_demo
                             WHERE EXISTS (SELECT 'x' FROM temp_money tm
                                           WHERE tm.id_demo = r.id_demo
                                           )
                             AND r.flag_give_rel = 'Y'
                             UNION
                             SELECT (SELECT GREATEST(o.id_demo,NVL(MAX(r2.id_demo_rel),0)) 
                                     FROM relation r2 
                                     WHERE o.id_demo = r2.id_demo
                                     AND r2.flag_give_rel = 'Y'
                                     ) AS id_rel
                                   , o.id_demo
                                   , o.code_org_type
                               FROM q_organization o
                               WHERE EXISTS (SELECT 'x' FROM temp_money tm
                                             WHERE tm.id_demo = o.id_demo
                                             )
                               ) oo
                             )ww
                             JOIN decode_org_type ot on ot.code_org_type = ww.code_org_type --Abdi Added 
                             WHERE ranking = 1
                      )--SELECT * FROM temp_rel_org;
, temp_alum AS (
								SELECT DISTINCT
                      (SELECT GREATEST(i.id_demo,NVL(MAX(r.id_demo_rel),0)) 
                       FROM relation r 
                       WHERE i.id_demo = r.id_demo
                       AND r.flag_give_rel = 'Y'
                       ) AS id_rel
                      , CASE WHEN a.id_demo IS NOT NULL OR aa.id_demo IS NOT NULL  THEN 'Y'
                             ELSE 'N'
                        END rel_is_alum
                      , CASE WHEN a.id_demo IS NOT NULL AND aa.id_demo IS NOT NULL THEN 2
                             WHEN a.id_demo IS NOT NULL AND aa.id_demo IS NULL 		 THEN 1
                             WHEN a.id_demo IS NULL AND aa.id_demo IS NOT NULL 		 THEN 1
                             ELSE 0
                        END alumni_count
               FROM q_individual i LEFT OUTER JOIN q_individual ii ON i.id_spouse = ii.id_demo
                                   LEFT OUTER JOIN academic a ON a.id_demo = i.id_demo
                                   LEFT OUTER JOIN academic aa ON aa.id_demo = ii.id_demo
               WHERE i.id_demo IN (SELECT id_least FROM temp_commit WHERE id_least < 900000000) 
               )--SELECT * FROM temp_alum;
SELECT CASE WHEN nvl(tas.rel_is_alum,'X') = 'Y'  
                   THEN 'Alumni'             
              WHEN least(tm.id_rel,tm.id_least) < 900000000 
              		 THEN 'Other Individuals'
              WHEN nvl(o.code_org_type,'X') = 'C'
              		 THEN 'Corporations'
              WHEN nvl(o.code_org_type,'X') IN ('CF','CM','FF','IF') 
              		 THEN 'Foundations'
              WHEN nvl(o.code_org_type,'X') = 'E' 
                   THEN 'Educational Institutions'
              WHEN nvl(o.code_org_type,'X') = 'G' 
                  THEN 'Government'
              WHEN nvl(o.code_org_type,'X') = 'N' 
              		 THEN 'Non-Government Organizations'
              WHEN nvl(o.code_org_type,'X') IN ('A','P','PA','PC','T')
                   THEN 'Other Organizations'
              WHEN tm.id_rel < 900000000
                   THEN 'Other Individuals'
              WHEN tm.id_rel >= 900000000
                   THEN 'Corporations'
              ELSE 'Unknown' END sources --groupings
       , year_fiscal 
       , SUM(CASE WHEN nvl(tas.rel_is_alum,'X') = 'Y' THEN alumni_count ELSE 1 END) AS cnt_donor
       , SUM (tm.total) total
FROM temp_commit tm 
		 LEFT JOIN temp_alum tas ON tm.id_rel = tas.id_rel
     LEFT JOIN temp_rel_org o ON tm.id_rel = o.id_rel
GROUP BY CASE WHEN nvl(tas.rel_is_alum,'X') = 'Y' 
                   THEN 'Alumni'
              WHEN least(tm.id_rel,tm.id_least) < 900000000
                   THEN 'Other Individuals'
              WHEN nvl(o.code_org_type,'X') = 'C'
                   THEN 'Corporations'
              WHEN nvl(o.code_org_type,'X') IN ('CF','CM','FF','IF')
                   THEN 'Foundations'
              WHEN nvl(o.code_org_type,'X') = 'E'
                   THEN 'Educational Institutions'
              WHEN nvl(o.code_org_type,'X') = 'G'
                   THEN 'Government'
              WHEN nvl(o.code_org_type,'X') = 'N'
                   THEN 'Non-Government Organizations'
              WHEN nvl(o.code_org_type,'X') IN ('A','P','PA','PC','T')
                   THEN 'Other Organizations'
              WHEN tm.id_rel < 900000000
                   THEN 'Other Individuals'
              WHEN tm.id_rel >= 900000000
                   THEN 'Corporations'
              ELSE 'Unknown'  END
              , year_fiscal
              ;
 
 SELECT * FROM t999999999a ORDER BY 1;
 SELECT TO_CHAR(SUM(total),'$999,999,999,999.99')AS total FROM t999999999a;-- $12,047,465.90  --Matches DMS total
 
--insert_inbox
exec batchman.ri_tapi.delete_report('t999999999a');
COMMIT;
exec batchman.ri_tapi.add_report('t999999999a','A report for giving in Otolaryngology (2412)','ALILLIE,AIJIBRIL');
COMMIT;

SELECT * FROM ri_report_user WHERE id_report = 't999999999a';
SELECT * FROM batchman.ri_scheduled_report WHERE id_report = 't999999999a';

exec batchman.ri_main.send_to_remote_inbox('t999999999a');
COMMIT;
exec batchman.ri_tapi.delete_report('t999999999a'); 
COMMIT; 


