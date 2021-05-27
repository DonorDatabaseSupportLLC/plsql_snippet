select  
       regexp_replace('763-657-1907','(^[[:digit:]]{3})([[:digit:]]{3})([[:digit:]]{4}$)','\1-\2-\3') as formatted_nbr_1  -- has already alpha
      , regexp_replace('6512760718','(^[[:digit:]]{3})([[:digit:]]{3})([[:digit:]]{4}$)','(\1)\2-\3')  as formatted_nbr_2  -- no alpha. Just numbers 
from dual
;
