--option # 1 : drop large tables

--STEP 1. review tables first 
WITH temp_dt 
AS(
   SELECT TO_NUMBER(TO_CHAR(SYSDATE,'yyyy')) AS yr 
   FROM dual
   )
, temp_pool
 AS(SELECT object_name as table_name 
      , object_type     
      , ROUND(SUM(ds.bytes)/(1024 * 1024),2) AS megabites_mb
      , EXTRACT(YEAR FROM u.created)         AS yr_created --t2019xxxxx
   FROM user_segments DS
        JOIN user_objects u ON u.object_name = ds.segment_name 
   WHERE 1=1
   GROUP by object_name
            , EXTRACT(YEAR FROM u.created) --table_name
            , object_type
)
 SELECT table_name, object_type, yr_created, megabites_mb
 FROM temp_pool DS     
 WHERE 1=1
 --AND trim(yr_created) < (SELECT yr FROM temp_dt) 
 AND megabites_mb >= 5
 AND table_name NOT IN ('VMC_CONNECTION_SCORE','T202000679_FINAL','T202001969_POOL','T202001969_PIVOT','T202001969_A',
                        'T202001232_SEND','T202001969_FINAL','T202000679_INBOX')
 AND upper(ds.object_type) = 'TABLE'
 ORDER BY megabites_mb desc 
;    


--STEP 2 - RUN DROP TABLES
set serveroutput on ;
DECLARE
numb_table number(10):= 0; 
     
CURSOR large_table_cur IS 
WITH temp_dt 
AS(
   SELECT TO_NUMBER(TO_CHAR(SYSDATE,'yyyy')) AS yr 
   FROM dual
   )
, temp_pool
 AS(SELECT object_name as table_name 
      , object_type     
      , ROUND(SUM(ds.bytes)/(1024 * 1024),2) AS megabites_mb
      , EXTRACT(YEAR FROM u.created)         AS yr_created --t2019xxxxx
   FROM user_segments DS
        JOIN user_objects u ON u.object_name = ds.segment_name 
   WHERE 1=1
   GROUP by object_name
            , EXTRACT(YEAR FROM u.created) --table_name
            , object_type
)
 SELECT table_name, object_type, yr_created, megabites_mb
 FROM temp_pool DS     
 WHERE 1=1
 --AND trim(yr_created) < (SELECT yr FROM temp_dt) 
 AND megabites_mb >= 5
 AND table_name NOT IN ('VMC_CONNECTION_SCORE','T202000679_FINAL','T202001969_POOL','T202001969_PIVOT','T202001969_A',
                        'T202001232_SEND','T202001969_FINAL','T202000679_INBOX')
 AND upper(ds.object_type) = 'TABLE'
 ORDER BY megabites_mb desc 
;     
                      
BEGIN
   FOR i IN large_table_cur
     LOOP   
       EXECUTE IMMEDIATE 'drop table '||i.TABLE_NAME; 
       numb_table := numb_table + 1;
      END LOOP;   
     COMMIT;
     dbms_output.PUT_LINE('total tables dropped is : '|| TO_CHAR(numb_table));
    EXCEPTION WHEN OTHERS THEN 
    raise_application_error(-20001,'ERROR MSG: '||SQLCODE||' -ERROR- '||SQLERRM);
      
  END;








/*--option # 2 : drop large tables 
declare 
begin
  for rec in (SELECT *
             FROM(
             SELECT table_name, ROUND(SUM(ds.bytes)/(1024 * 1024),2) AS megabites_mb
             FROM user_segments DS
                 JOIN user_tables u ON u.table_name = ds.segment_name 
             WHERE 1=1 
             AND (SUBSTR(u.table_name,2,4) LIKE '%2015%' OR SUBSTR(u.table_name,2,4) LIKE '%2016%')
             group by table_name
          )
        WHERE megabites_mb >= 2
             )
  loop
    execute immediate 'drop table '||rec.table_name;
  end loop;             
end;
/*/