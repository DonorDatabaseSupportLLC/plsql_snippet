-- Find group names 
-- that does not have the characters between [square bracket]
-- and has space after that  
select distinct 
   nbr_group
   , name_group
   , LENGTH(name_group) len_grp 
from t202001865_pool 
where 1=1
and not regexp_like(name_group, '[^0-9A-Za-z,-,+,/,&,.,()](\s)') 
--and nbr_group = 13366
;


-- Find group names 
-- that does not have the characters between [square bracket]
-- and has NON-space characters after that  
select distinct 
   nbr_group
   , name_group
   , LENGTH(name_group) len_grp 
from t202001865_pool 
where 1=1
and not regexp_like(name_group, '[^0-9A-Za-z,-,+,/,&,.,()](\S*)') 
--and nbr_group = 13366
;