--Anonmous PL/SQL Block type
--Variable Data types: 
     -- Number (n,m) ,  Varchar2 (n) , Date , Long 
     -- Char (n) , Long raw, Raw, Blob, Clob, Nclob, Bfile
     -- Use %TYPE so if column data type changes, you do not Worry about changing var. data type as well.
DECLARE 
----declare variable
salary  scott.emp.sal%TYPE;
empID  scott.emp.empno%TYPE;
bonus scott.emp.comm%TYPE := .10;
BEGIN
   SELECT e.empno, e.sal 
          INTO empID, salary  
   FROM scott.emp  e
   WHERE e.empno = 7499;
   
IF salary >1500 THEN 
   salary := salary + (salary * bonus);
ELSE 
   salary := salary;
END IF ; 
--output results
dbms_output.PUT_LINE(empID ||' has a salary of '|| salary);
END;






--assign value to variable 
SELECT * FROM scott.emp e   WHERE e.empno = 7499;;

