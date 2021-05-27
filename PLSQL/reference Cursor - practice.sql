--SELECT * FROM scott.emp;

--1. step 1
create or replace function get_dept_emps(p_deptno in number) return sys_refcursor is
      v_rc sys_refcursor;
    
    begin
      open v_rc for 'select empno, ename, mgr, sal from emp where deptno = :deptno' using p_deptno;
      return v_rc;
   end;
  /
--2. step 2
DECLARE 
rc refcursor; 
BEGIN 
:rc := get_dept_emps(10);
END;

SELECT * FROM user_objects u 
WHERE LOWER(u.object_name) = 'get_dept_emps';

