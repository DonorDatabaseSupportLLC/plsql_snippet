--combine first, second, third occurance of group name and nbr_gruop
select distinct 
   nbr_group
   , name_group
   , regexp_substr (name_group, '[A-z]+' ) as grp_name_short
   , regexp_substr (name_group, '(\S+)(\s)', 1, 1)||' '|| 
     regexp_substr (name_group, '(\S+)(\s)', 1, 2)||' '||
     regexp_substr (name_group, '(\S+)(\s)', 1, 3)||'('||nbr_group||')'   as name_grp_small
   , LENGTH(name_group) len_grp 
from t202001865_pool
;