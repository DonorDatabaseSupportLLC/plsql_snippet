PROMPT 1. ====================================================================================
-- Nested CASE Statements
-- CASE statements can be nested just as IF statements can. 
-- This rather difficult to follow implementation of my bonus logic uses a nested CASE statement:

CASE
    WHEN salary >= 10000 THEN  --OVER $10K SALARY
        CASE
            WHEN salary <= 20000 THEN give_bonus(employee_id, 1500) --
            WHEN salary > 40000 THEN give_bonus(employee_id, 500)
            WHEN salary > 20000 THEN give_bonus(employee_id, 1000)
        END CASE;
    WHEN salary < 10000 THEN    --UNDER $10K SALARY 
   give_bonus(employee_id,0) 
END CASE;

--EQUIVALENT - IF ELSEIF ELSE END IF.
IF salary >= 10000 AND salary <= 20000
   THEN give_bonus(employee_id, 1500) 
ELSIF salary > 20000 AND salary <= 40000
   THEN give_bonus(employee_id, 1000) 
ELSIF salary > 40000
   THEN give_bonus(employee_id, 400) 
ELSIF salary < 10000
   THEN give_bonus(employee_id, 0)   
END IF;

PROMPT 2 ===================================================================================
CASE    WHEN  CHANGE_TYPE = 'N'
        THEN  CASE 
                        WHEN  INSTR (UPPER (DETAIL_LEVEL_DESC), 'S/P') != 0 
                        THEN  'SPP'
                        WHEN  INSTR( UPPER (DETAIL_LEVEL_DESC), 'NIO') != 0 
                        THEN  'NIO'
                        ELSE  'NEW' 
              END                  -- No "comma," here
        ELSE  CASE 
                        WHEN  INSTR( UPPER( DETAIL_LEVEL_DESC), 'SOE') != 0 
                        THEN  'SOE'
                        ELSE  'SOM' 
              END
END
PROMPT ====================================================================================
CASE    WHEN  CHANGE_TYPE = 'N'
        THEN  CASE 
                        WHEN  INSTR (UPPER (DETAIL_LEVEL_DESC), 'S/P') != 0 
                        THEN  'SPP'
                        WHEN  INSTR( UPPER (DETAIL_LEVEL_DESC), 'NIO') != 0 
                        THEN  'NIO'
                        ELSE  'NEW' 
              END                  -- No "," here
        WHEN  INSTR( UPPER( DETAIL_LEVEL_DESC), 'SOE') != 0 
        THEN  'SOE'
        ELSE  'SOM' 
END

PROMPT ===============================================================================
CASE
   WHEN certv.id IS NOT NULL THEN NULL
   WHEN cert.id IS NOT NULL THEN
      CASE WHEN gr.gt_id = 0 THEN = 3 
           WHEN gr.gt_id = 1 THEN = 4 END
   WHEN not.id IS NOT NULL THEN NULL
END AS type_pre
PROMPT =================================================================================

---------------------------------- Examples ---------------------------------- 

--The following examples will make the use of CASE expression more clear, using Oracle CASE select statements.

E.g.: Returning categories based on the salary of the employee.

select sal, case when sal < 2000 then 'category 1' 
                 when sal < 3000 then 'category 2' 
                 when sal < 4000 then 'category 3' 
                 else 'category 4' 
            end 
from emp; 
--E.g.: The requirement is to find out the count of employees for various conditions as given below. There are multiple ways of getting this output. Five different --statements can be written to find the count of employees based on salary and commission conditions, or a single select having column-level selects could be written.

select count(1) 
from   emp 
where  sal < 2000 
and    comm is not null; 
 
select count(1) 
from   emp 
where  sal < 2000 
and    comm is null; 

select count(1) 
from   emp 
where  sal < 5000 
and    comm is not null; 

select count(1) 
from   emp 
where  sal < 5000 
and    comm is null; 

select count(1) 
from   emp 
where  sal > 5000; 
(or)

select (select count(1)
        from   emp
        where  sal < 2000
        and    comm is not null) a,
       (select count(1)
        from   emp
        where  sal < 2000
        and    comm is null) b,
       (select count(1)
        from   emp
        where  sal < 5000
        and    comm is not null) c,
       (select count(1)
        from   emp
        where  sal < 5000
        and    comm is null) d,
(select count(1)
from   emp
where  sal > 5000) e
from dual

--With CASE expression, the above multiple statements on the same table can be avoided using Oracle select case.
select count(case when sal < 2000 and comm is not null then 1 
                  else null 
             end), 
       count(case when sal < 2000 and comm is null then 1 
                  else null 
             end), 
       count(case when sal < 5000 and comm is not null then 1 
                  else null 
             end), 
       count(case when sal < 5000 and comm is null then 1 
                  else null 
             end), 
       count(case when sal > 5000 then 1   else null 
             end) 
from emp; 


select count(case when sal < 2000 and comm is not null then 1 
             end) cnt1, 
       count(case when sal < 2000 and comm is null then 1 
             end) cnt2, 
       count(case when sal < 5000 and comm is not null then 1 
             end) cnt3, 
       count(case when sal < 5000 and comm is null then 1 
             end) cnt4, 
       count(case when sal > 5000 then 1 
             end) cnt5 
from emp;
--CASE expression can also be nested.

select (case when qty_less6months < 0 and qty_6to12months < 0 then
                            (case when season_code in ('0', '1', '2', '3', '4') then 'value is negative'
                                  else 'No stock'
                             end)
             when qty_1to2years < 0 and qty_2to3years < 0 then
                            (case when season_code in ('A', 'B', 'C', 'D', 'E') then 'value is negative'
                                  else 'No stock'
                             end)
             else 'Stock Available'
        end) stock_check
from   jnc_lots_ageing_mexx_asof
where  rownum < 20
and    qty_less6months < 0 and qty_6to12months < 0
 