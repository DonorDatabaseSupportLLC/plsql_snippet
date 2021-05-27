--dynamically create table in PL/SQL 
DECLARE
 l varchar2(1);
begin 
  select
    'x' into l
  from  dual
  where exists (select null from umd_deceased);
exception 
    when no_data_found
    then execute immediate 'drop table umd_deceased';
         execute immediate 'create table umd_deceased as 
                            select
                           ''No UMD Deceased'' note
                           from dual';


--test 
SET serveroutput ON ;
DECLARE 
x_var  VARCHAR2(4000);


BEGIN 
FOR i IN 1..4000 
LOOP 
		x_var := x_var ||'x'; --dbms_output.put_line(x_var); 
END LOOP;
--EXECUTE IMMEDIATE 'DROP TABLE test_upload_size';
EXECUTE IMMEDIATE  'create table  test_upload_size as select' ||TRIM(x_var)|| 'from dual'; 

--dbms_output.put_line(x_var); 
END;
/