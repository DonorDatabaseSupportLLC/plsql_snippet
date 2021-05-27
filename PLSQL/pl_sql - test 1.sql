set serveroutput on size 30000;  
declare 

-- code_recipient -- ** global constants **
std_u CONSTANT VARCHAR2(4)  := 'U';
std_m CONSTANT VARCHAR2(4)  := 'M';
std_f CONSTANT VARCHAR2(4)  := 'F';

std_ltd CONSTANT VARCHAR2(20) := ''''||std_u||''''||','||''''||
                                 std_m||''''||','||''''||
                                 std_f||'''';
                                 
std_ltd_var varchar2(20);
begin 
select std_ltd
into std_ltd_var
from dual;

dbms_output.put_line(std_ltd_var);

end;