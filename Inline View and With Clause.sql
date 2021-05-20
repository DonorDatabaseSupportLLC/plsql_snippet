--In-Line View -
--purpose: sing the SCOTT schema, for each employee we want to know how many other people are in their department.

SELECT e.ename AS employee_name, dc.dept_count AS emp_dept_count
  FROM scott.emp e,
       (  SELECT deptno, COUNT (*) AS dept_count
            FROM scott.emp
        GROUP BY deptno) dc
 WHERE e.deptno = dc.deptno;   --Non ANSI-92 Standard - USe Inner JOINS instead
 
 /
 
--WITH clause --More Efficient >>> TEMP table 
WITH dept_count --temp table
     AS (  SELECT deptno, COUNT (*) AS dept_count
             FROM scott.emp
         GROUP BY deptno)
SELECT e.ename AS employee_name, dc.dept_count AS emp_dept_count
  FROM scott.emp e INNER JOIN dept_count dc ON (e.deptno = dc.deptno)
  ORDER BY emp_dept_count desc;

-- Inline View

