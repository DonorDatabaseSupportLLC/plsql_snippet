
--remove duplicates within semicolon string
--Source https://community.oracle.com/message/14712262#14712262  
SELECT id_demo  
       , LISTAGG(c, ';') WITHIN GROUP (ORDER BY c) unique_units
FROM  (
       SELECT DISTINCT id_demo 
              , REGEXP_SUBSTR(units_given, '[^;:]+', 1, level) c  
       FROM t201801465a 
       CONNECT BY level <= REGEXP_COUNT(units_given, '[;:]') + 1  
       AND PRIOR id_demo = id_demo  
       AND PRIOR sys_guid() IS NOT NULL  
      )  
GROUP BY id_demo  
ORDER BY 1;  





--xxxx
WITH your_table (deptid, countries) AS (  
   SELECT 10, 'usa;uk;usa;uk' FROM dual UNION ALL  
   SELECT 20, 'aus;usa:usa'   FROM dual  
)  
SELECT deptid,  
       LISTAGG(c, ';') WITHIN GROUP (ORDER BY c) unique_countries  
FROM  (SELECT DISTINCT deptid,  
              REGEXP_SUBSTR(countries, '[^;:]+', 1, level) c  
       FROM  your_table  
       CONNECT BY level <= REGEXP_COUNT(countries, '[;:]') + 1  
       AND PRIOR deptid = deptid  
       AND PRIOR sys_guid() IS NOT NULL  
)  
GROUP BY deptid  
ORDER BY 1;  
