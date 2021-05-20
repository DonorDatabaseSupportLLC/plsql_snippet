--option # 1 : drop large tables 
set serveroutput on ;
DECLARE
numb_table number(10):= 0; 
     
CURSOR large_table_cur IS 
         WITH 
               temp_dt AS (SELECT TO_CHAR(SYSDATE,'yyyy') AS yr 
                           FROM dual
                          ),
                temp_pool AS  
                           (SELECT table_name
                                  , ROUND(SUM(ds.bytes)/(1024 * 1024),2) AS megabites_mb
                                  , SUBSTR(u.table_name,2,4)             AS yr_created
                            FROM user_segments DS
                                JOIN user_tables u ON u.table_name = ds.segment_name 
                            GROUP by table_name
                            )
           SELECT table_name, yr_created, megabites_mb
           FROM temp_pool DS     
               cross join temp_dt dt 
           WHERE trim(yr_created) < (SELECT yr FROM temp_dt) 
           AND megabites_mb >= 8
					 AND table_name in ('T201704179A_QSTKR','T201701489A_GIR','T201701860_A1','T201703940_SEND','')
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