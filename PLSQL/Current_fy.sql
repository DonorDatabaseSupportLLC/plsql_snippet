with temp_a as
(select
case when to_number(to_char(day,'MM')) between 1 and 6
              then to_number(to_char(day,'YYYY'))
              else to_number(to_char(day,'YYYY'))+1
               end curr_fy
from (select sysdate/*TO_DATE('01-sep-2010')*/ day from dual)
)  
