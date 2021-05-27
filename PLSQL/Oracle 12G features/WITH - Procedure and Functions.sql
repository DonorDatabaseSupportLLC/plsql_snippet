DROP TABLE t1 PURGE;
CREATE TABLE t1 AS
SELECT 1 AS id
FROM   dual
CONNECT BY level <= 1000000;
SELECT * FROM t1;/
-- Gathering stats on a CTAS is no longer necessary in 12c,
-- provided the statement is issued by a non-SYS user.
-- EXEC DBMS_STATS.gather_table_stats(USER, 't1');
--Functions in the WITH Clause
--SET trace ON ; 
WITH
  FUNCTION with_function(p_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN p_id ;
  END;
SELECT with_function(id)
FROM   t1
WHERE  rownum = 1;

/

--test 2. works in SQLPlus > Command line.  but it prompts you with '/' to add. 
WITH
 function add_number(num1 number, num2 number) return number is
   begin
      return num1+num2 /
    end/
   select add_number(1,2) from dual
 / 
   
   

--procudre 
WITH
  PROCEDURE with_procedure(p_id IN NUMBER) IS
  BEGIN
    DBMS_OUTPUT.put_line('p_id=' || p_id);
  END;
SELECT id
FROM   t1
WHERE  rownum = 1
/

SELECT * FROM PRODUCT_COMPONENT_VERSION;
