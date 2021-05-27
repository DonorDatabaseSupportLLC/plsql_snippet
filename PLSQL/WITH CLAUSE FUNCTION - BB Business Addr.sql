
WITH FUNCTION street_1_type
    (id_demo_in         IN      address.id_demo%TYPE,
     code_addr_type_in  IN      address.code_addr_type%TYPE,
     code_addr_stat_OPT IN      address.code_addr_stat%TYPE DEFAULT 'C'
     )
RETURN address.street_1%TYPE
IS
-- VARIABLES
    tstreet                     address.street_1%type;
    rowmax                      number;
--CURSORS
     CURSOR street_1_cur IS
     SELECT r.street_1, ROWNUM rownumber
       FROM address r
      WHERE r.id_demo = id_demo_in
        AND r.code_addr_type = code_addr_type_in
        AND code_addr_stat_OPT = r.code_addr_stat;

BEGIN
 tstreet := null;
 rowmax := 0;
  FOR rec IN street_1_cur LOOP
   IF (greatest(rowmax,rec.rownumber) > rowmax) then
    tstreet := rec.street_1;
    rowmax := rec.rownumber;
   END IF;
  END LOOP;
RETURN rowmax;
END;
--dbms_output.putline(rownmax);
select street_1_type(800471933,'B','C') as street_1_row_max 
from dual  
/ --Ste 2100
 
/*
SELECT r.*, ROWNUM rownumber
 FROM address r
WHERE r.id_demo = 800471933
  AND r.code_addr_type = 'B'
  AND code_addr_stat = 'C';*/