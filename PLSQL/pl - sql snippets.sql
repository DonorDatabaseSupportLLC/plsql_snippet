--Use a variable with �LIKE %� (e.g. �variable%�) in PL/SQL?

create or replace procedure PROC1(search VARCHAR2) 
 IS
  cursor test_cur(search IN VARCHAR2)
   IS
    SELECT student_name 
    FROM student
    WHERE student_name LIKE search||'%'; --you're putting you variable within quotes

 v_temp_var student.student_name%TYPE;

BEGIN

 OPEN test_cur(search);
  LOOP
   FETCH test_cur INTO v_temp_var;
    EXIT WHEN test_cur%NOTFOUND;

    DBMS_OUTPUT.PUT_LINE(v_temp_var);  
  END LOOP;

 CLOSE test_cur;

END test;
---------------------------------------------------------------------------

---------------------------------------------------------------------------

---------------------------------------------------------------------------

---------------------------------------------------------------------------

---------------------------------------------------------------------------

---------------------------------------------------------------------------

---------------------------------------------------------------------------

---------------------------------------------------------------------------

---------------------------------------------------------------------------

---------------------------------------------------------------------------