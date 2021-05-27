--Both couples where one is in SPECIFIC College and the other spouse is in ANOTHER College
--AND, at least one of them LIVING

WITH 
		temp_alum AS(
    						 SELECT w.*
    										, COUNT(id_house)over(PARTITION BY id_house) AS cnt_hh_degree  
                 FROM(       
                       SELECT DISTINCT 
                              a.id_demo
                              , i.name_first 
                              , i.name_last 
                              , i.name_label_comb
                              , a.code_degree
                              , dd.desc_degree
                              , a.code_clg_query college
                              , i.id_spouse 
                              , i.id_household AS id_house 
                              , DECODE(i.year_death,NULL,'N','Y') AS deceased 
                              , DECODE(ii.year_death,NULL,'N','Y') AS deceased_sp
                       FROM q_academic a  
                            JOIN decode_degree dd ON dd.code_degree = a.code_degree 
                            JOIN q_individual i ON i.id_demo = a.id_demo 
                            LEFT JOIN q_individual ii ON ii.id_spouse = a.id_demo 
                       WHERE 1=1  
                       AND (a.code_clg_query = 'NUR' 
                            OR 
                           (a.code_clg_query = 'MED' AND a.code_degree IN ('FEL','RES','402'))) 
                   )w          
                ORDER BY id_house
    						),
    temp_unique AS( 
                   SELECT DISTINCT
                  			 a1.id_demo 
                         , a1.id_spouse
                         , a1.id_house 
                         , a1.deceased 
                         , a1.deceased_sp
                  FROM temp_alum a1 
                  WHERE a1.college IN ('MED')
                  AND EXISTS(SELECT 1 
                             FROM temp_alum a2 
                             WHERE a2.college = 'NUR' 
                             AND a2.id_demo = a1.id_spouse 
                             )
                UNION 
                 SELECT DISTINCT
                  			 a1.id_demo 
                         , a1.id_spouse
                         , a1.id_house 
                         , a1.deceased 
                         , a1.deceased_sp
                  FROM temp_alum a1 
                  WHERE a1.college = 'NUR'
                  AND EXISTS(SELECT 1 
                             FROM temp_alum a2 
                             WHERE a2.college = 'MED' 
                             AND a2.id_demo = a1.id_spouse 
                             )
                 ),
   temp_pool AS(
                SELECT w.id_demo
                       , tl.name_last 
                       , tl.name_first 
                       , tl.name_label_comb
                       , tl.code_degree
                       , tl.desc_degree
                       , tl.id_spouse 
                       , tl.college 
                       , tl.deceased 
                       , tl.deceased_sp
                       , tl.id_house 
                       , tl.cnt_hh_degree
                FROM(
                    SELECT ta.id_demo 
                    FROM temp_unique ta
                    UNION 
                    SELECT ta.id_spouse 
                    FROM temp_unique ta
                   )w
                   JOIN temp_alum tl ON tl.id_demo = w.id_demo 
                   --JOIN q_individual i ON i.id_demo = w.id_demo 
                WHERE 1=1 
                AND NOT EXISTS(SELECT 1
                               FROM temp_unique tpp 
                               WHERE tpp.id_house = tl.id_house
                               AND tl.deceased = 'Y' 
                               AND tl.deceased_sp = 'Y'
                              )
        )
SELECT id_demo
        , name_last 
        , name_first 
        , id_house
        , id_spouse 
        , deceased 
        , deceased_sp 
			  , listagg(desc_degree||'('||code_degree||')', '; ')within GROUP(ORDER BY NULL) AS degree_info
FROM(
      SELECT DISTINCT 
      		a.id_demo
          , a.name_last 
          , a.name_first
          , a.id_house
          , a.id_spouse 
          , a.code_degree 
          , a.desc_degree 
          , a.college 
          , deceased 
          , deceased_sp 
      FROM t201802774_pool a 
    ) 
GROUP BY id_demo
        , name_last 
        , name_first 
        , id_house
        , id_spouse 
        , deceased 
        , deceased_sp 
;