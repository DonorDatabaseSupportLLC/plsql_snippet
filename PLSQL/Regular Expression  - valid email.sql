with temp_e as (select email_addr_lower email from email) 
select * 
from temp_e e 
where 1=1 
--and not regexp_like (email,'^[a-z0-9._-]+@[a-z0-9.-]+\.[a-z]{2,3}$','i');
and not regexp_like (email,'^[a-z0-9._-]+@[a-z0-9.-]+\.[a-z]{2,3}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|asia|jobs|museum|coop$','i')
--and not regexp_like (email,'^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|asia|jobs|museum|coop)$','i')