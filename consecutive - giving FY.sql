/* 
********************************************** USE this: Pattern matching summary results ***********   
This excludes "all rows per match", so you get the default of "one row per match" i.e. one per group. 
You can use the measures clause to define columns showing the number of rows, etc. 
as in the Tabibitosan group by summary.
PROMPT ***********************************************************************************************  
*/
WITH 
		 temp_a AS(SELECT p.id_rel, p.year_fiscal
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
                   WHERE conseq_fy >= 3
                   --AND id_rel = 800034262
                  ) 
/*************************************************************************************** 
-- List ONLY Highest Consecutive FY given of those consecutive FYs given - ONE Per id_rel  
**************************************************************************************/
SELECT id_rel
     , MAX(conseq_fy)AS conseq_fy_max   
FROM temp_pool  
GROUP BY id_rel

/*************************************************************************************** 
-- List All Consecutive FY that meet the criteria, NOT just Highest   
SELECT id_rel
       , first_fy 
       , last_fy 
       , conseq_fy 
FROM temp_pool  
ORDER BY first_fy ASC 
**************************************************************************************/
;
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






