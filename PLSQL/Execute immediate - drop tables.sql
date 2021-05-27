
--option # 1 : drop large tables 
set serverout on 
DECLARE
     numb_table number(10); 
     
     CURSOR large_table_cur IS 
         SELECT *
         FROM(
            SELECT table_name, ROUND(SUM(ds.bytes)/(1024 * 1024),2) AS megabites_mb
            FROM user_segments DS
                 JOIN user_tables u ON u.table_name = ds.segment_name 
            WHERE 1=1 
            AND (SUBSTR(u.table_name,2,4) LIKE '%2015%' OR SUBSTR(u.table_name,2,4) LIKE '%2016%')
            group by table_name
          )
        WHERE megabites_mb >= 2
        ;                       
BEGIN
   for i in large_table_cur
     Loop     
       EXECUTE IMMEDIATE 'drop table '||i.TABLE_NAME; 
       numb_table := numb_table + 1;
     end loop;   
     
   EXCEPTION WHEN OTHERS THEN 
    raise_application_error(-20001,'ERROR MSG: '||SQLCODE||' -ERROR- '||SQLERRM);
   dbms_output.PUT_LINE('total tables dropped '|| numb_table);
   COMMIT;
  END;



--option # 1 : drop large tables 
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
/