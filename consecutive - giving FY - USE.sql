/* 
********************************************** USE this: Pattern matching summary results ***********   
This excludes "all rows per match", so you get the default of "one row per match" i.e. one per group. 
You can use the measures clause to define columns showing the number of rows, etc. 
as in the Tabibitosan group by summary.
PROMPT ***********************************************************************************************  
*/


--V1. Find x number of years of consecutive giving (i.e. CSE donors who gave 25 consecutive Fiscal Years)
WITH 
     temp_a AS(SELECT p.id_rel, p.year_fiscal
               FROM q_production_id p    
               WHERE p.code_clg = 'CSE'
               AND p.code_anon IN ('1','0')
               AND p.code_recipient != 'S'
               UNION
               SELECT p.id_rel, p.year_fiscal
               FROM q_receipted_id p    
               WHERE p.code_clg = 'CSE'
               AND p.code_anon IN ('1','0')
               AND p.code_recipient != 'S'
              ),
      temp_pool AS(
                   SELECT *   
                   FROM temp_a  
                   match_recognize (  
                                    partition by id_rel order by year_fiscal asc
                                    measures 
                                          first(year_fiscal)  as first_fy  
                                         , last(year_fiscal)  as last_fy 
                                          --, match_number()  as all_given_fy
                                          --, classifier()    as Yes_consec_fy  
                                         , COUNT(*)           as conseq_fy
                                     -- all rows per match       --Default means to start next row counting after match is found.
                                                 -- str/consecutive can be changed to any 'alpha'   
                                                 -- *: indicates 0 - to many. 
                                                 -- +: 1:many 
                                     pattern (strt consecutive* )  
                                     define   
                                          consecutive AS year_fiscal = (prev(year_fiscal) + 1 )
                                    )) 
select *
from(
      select a.*
             , rank()over(partition by id_rel order by conseq_fy desc, rownum) as rnk_conseq 
      from temp_pool a 
   )w 
where rnk_conseq = 1 
and conseq_fy >= 25
--and w.id_rel in (100004711, 100002757)
order by conseq_fy desc
;




-- v2. Find # of Consecutive giving FY
--    Must have given at least 2 years in a row, to be included)
WITH 
     temp_a AS(SELECT p.id_rel, p.year_fiscal
               FROM q_production_id p    
               WHERE p.code_clg = 'CSE'
               AND p.code_anon IN ('1','0')
               AND p.code_recipient != 'S'
               UNION
               SELECT p.id_rel, p.year_fiscal
               FROM q_receipted_id p    
               WHERE p.code_clg = 'CSE'
               AND p.code_anon IN ('1','0')
               AND p.code_recipient != 'S'
              ),
      temp_pool AS(
                   SELECT *  
                   FROM temp_a 
                   match_recognize (  
                                     partition by id_rel order by year_fiscal asc
                                     measures 
                                             first(year_fiscal)   AS conseq_first_fy  
                                             , last(year_fiscal)  AS conseq_last_fy 
                                             --, match_number()   AS all_given_fy
                                             --, classifier()     AS Yes_consec_fy  
                                             , COUNT(*)           AS conseq_fy
                                     pattern (strt consecutive* )  
                                     define   
                                     consecutive AS year_fiscal = (prev(year_fiscal) + 1 )
                                    )
                  )
                  
select *
from(
      select a.*
             , rank()over(partition by id_rel order by conseq_fy desc, conseq_last_fy desc, rownum) as rnk_conseq 
      from temp_pool a 
   )w 
where rnk_conseq = 1 
and conseq_fy >= 4
and w.id_rel in (100004711, 100002757)
order by rnk_conseq, conseq_fy desc
; 


--version 3 - Issue: 
--you would have to join the Table (B table) -- see version 2 
WITH 
		 temp_a AS(SELECT p.id_rel, p.year_fiscal
                  FROM q_production_id p		
                  WHERE p.code_clg = 'CSE'
                  AND p.code_anon IN ('1','0')
                  AND p.code_recipient != 'S'
                  UNION
                  SELECT p.id_rel, p.year_fiscal
                  FROM q_receipted_id p		
                  WHERE p.code_clg = 'CSE'
                  AND p.code_anon IN ('1','0')
                  AND p.code_recipient != 'S'
                  ),
      temp_pool AS(
                   SELECT *   
                   FROM temp_a   
                   match_recognize (  
                                     ORDER BY id_rel, year_fiscal measures 
                                     MAX(id_rel) 								  AS id_rel 
                                     , first(year_fiscal)         AS first_fy  
                                     , last(year_fiscal)  			  AS last_fy 
                                     , COUNT(*) 					 			  AS conseq_fy
                                     , match_number() 		        AS grp  
                                     pattern (strt consecutive* )  
                                     define   
                                     consecutive AS year_fiscal = (prev(year_fiscal) + 1 )
                                    )
                   --WHERE conseq_fy >= 3
                   --AND id_rel = 800034262
                  ) 
/*************************************************************************************** 
-- List ONLY Highest Consecutive FY given of those consecutive FYs given - ONE Per id_rel  
**************************************************************************************/
/*SELECT id_rel
     , MAX(conseq_fy)AS conseq_fy_max   
FROM temp_pool  
GROUP BY id_rel*/

/*************************************************************************************** */
-- List All Consecutive FY that meet the criteria, NOT just Highest   
SELECT id_rel
       , first_fy 
       , last_fy 
       , conseq_fy 
FROM temp_pool  
WHERE id_rel = 140424796
ORDER BY first_fy ASC 
/**************************************************************************************/
;
 

--Version 4 
with temp_pool 
as(SELECT p.id_rel, p.year_fiscal
   FROM q_production_id p    
   WHERE p.code_clg = 'CSE'
   AND p.code_anon IN ('1','0')
   AND p.code_recipient != 'S'
   UNION
   SELECT p.id_rel, p.year_fiscal
   FROM q_receipted_id p    
   WHERE p.code_clg = 'CSE'
   AND p.code_anon IN ('1','0')
   AND p.code_recipient != 'S'
)
, temp_consec_pool
AS(SELECT w.*
   FROM(
         SELECT p.id_rel, p.year_fiscal
         FROM q_production_id p    
         WHERE p.code_clg = 'CSE'
         AND p.code_anon IN ('1','0')
         AND p.code_recipient != 'S'
         UNION
         SELECT p.id_rel, p.year_fiscal
         FROM q_receipted_id p    
         WHERE p.code_clg = 'CSE'
         AND p.code_anon IN ('1','0')
         AND p.code_recipient != 'S' 
     )W 
     JOIN temp_pool b          --join this table 
          ON b.id_rel = w.id_rel 
     where b.id_rel = 140424796
)
, temp_conseq_final 
AS(SELECT id_rel 
        , MAX(conseq_fy)AS conseq_fy_giving 
   FROM(SELECT *   
        FROM temp_consec_pool   
        match_recognize (ORDER BY id_rel, year_fiscal measures 
                         MAX(id_rel)                   AS id_rel 
                         , first(year_fiscal)          AS first_fy  
                         , last(year_fiscal)           AS last_fy 
                         , COUNT(*)                    AS conseq_fy
                         , match_number()              AS grp  
                         pattern (strt consecutive* )  
                         define   
                         consecutive AS year_fiscal = (prev(year_fiscal) + 1 )
                        )
      ) 
GROUP BY id_rel
)  
select * 
from temp_conseq_final 
--where id_rel = 140424796
;


--site: https://livesql.oracle.com/apex/livesql/file/content_F8P1XASWD667NDOFJTM74NYE9.html
--araarso@gmail.com to connect. 

--------------------------------------------------------------------------------------  
--  HELPERS 
--------------------------------------------------------------------------------------  

WITH 
		 temp_pool AS(SELECT w.*
                  FROM(
                         SELECT p.id_rel, p.year_fiscal
                         FROM q_production_id p		
                         WHERE p.code_clg = 'SOM'
                         AND p.code_anon IN ('1','0')
                         AND p.code_recipient != 'S'
                         UNION
                         SELECT p.id_rel, p.year_fiscal
                         FROM q_receipted_id p		
                         WHERE p.code_clg = 'SOM'
                         AND p.code_anon IN ('1','0')
                         AND p.code_recipient != 'S'
                        )w 
                   WHERE w.id_rel = 100016083  
                   ),
		temp_groups AS(
                   SELECT id_rel 
                        , year_fiscal
                        , row_number()over(PARTITION BY id_rel  ORDER by year_fiscal) rn 
                        , year_fiscal - row_number() over (order by year_fiscal) grp_fy
                   FROM temp_pool
                   ) --SELECT * FROM temp_groups;
 select id_rel
 				, min(year_fiscal) AS first_fy
        , max(year_fiscal) AS last_fy    
        , count(*) 				 AS fy 
        , row_number() over (PARTITION BY year_fiscal order by min(year_fiscal)) grp  
  from  temp_groups  
  where id_rel = 140424796
  group  by id_rel, year_fiscal   
  order  by min(year_fiscal)   
;


/********************************* Pattern matching method ******************************************** 
Starting in 12c, you can use match_recognize to do the same thing. 
A row is consecutive with the previous when the current date equals the previous date plus one. 
So define a pattern variable which checks for this. This follows an "always true" initial variable. 
Classifier and match_number are functions for match_recognize. Classifier shows which variable was matched 
and match_number returns the group number. Pattern matching method
**********************************************************************************************************/
WITH 
		 temp_pool AS(SELECT w.*
                  FROM(
                         SELECT p.id_rel, p.year_fiscal
                         FROM q_production_id p		
                         WHERE p.code_clg = 'SOM'
                         AND p.code_anon IN ('1','0')
                         AND p.code_recipient != 'S'
                         UNION
                         SELECT p.id_rel, p.year_fiscal
                         FROM q_receipted_id p		
                         WHERE p.code_clg = 'SOM'
                         AND p.code_anon IN ('1','0')
                         AND p.code_recipient != 'S'
                        )w 
                   WHERE w.id_rel = 100016083  
                   )
select *  
from   temp_pool  
match_recognize (order by year_fiscal measures  
     	classifier()   as var, 
      match_number() as grp 
  		all rows per match 
  pattern ( strt consecutive* ) 
  define  
  consecutive as year_fiscal = ( prev ( year_fiscal ) + 1 ) 
);






