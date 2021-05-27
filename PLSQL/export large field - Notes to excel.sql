SELECT DISTINCT 
         a.id_demo
        , a.id_prospect_master
        , a.id_spouse
        , a.id_house
        , a.name_last
        , a.name_first
        , REPLACE (REPLACE (REPLACE (a.overall_strategy, chr(13)), chr(10)), chr(13)) AS overall_strategy
FROM t201604209_pool a 
LEFT JOIN t201604209_proposal b ON b.id_prospect_master = a.id_prospect_master 
                                AND a.id_solicit_master = b.id_solicit_master  
;
 
