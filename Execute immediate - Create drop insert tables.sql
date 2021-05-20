--umd_lk_201702243.sql
DECLARE
i  NUMBER (4);
	BEGIN
				EXECUTE IMMEDIATE 'DROP TABLE temp_user_tb'; 
				EXCEPTION WHEN OTHERS THEN 
			  	EXECUTE IMMEDIATE 'SELECT table_name, ROUND(SUM(ds.bytes)/(1024 * 1024),2) AS megabites_mb' 
                                   ||' FROM user_segments DS'
                                   ||' JOIN user_tables u ON u.table_name = ds.segment_name' 
                                   ||' WHERE SUBSTR(u.table_name,2,4) LIKE '%2015%''
                                   ||' group by table_name'''; 
END;
	BEGIN 
				FOR i IN 2003 .. 2018
				LOOP
						INSERT INTO  t201702243_date VALUES (i);
				END LOOP; 
				DELETE t201702243_date where fy=0; 
				EXCEPTION WHEN OTHERS THEN 
				raise_application_error(-20001,'ERROR MSG: '||SQLCODE||' -ERROR- '||SQLERRM);
  END;

SELECT * FROM t201702243_date;