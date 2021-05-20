select REGEXP_REPLACE('xyz)_.', '[^0-9A-Za-z]', '')  remove_non_alpha
from dual;


SELECT REGEXP_SUBSTR('Ramsey, MN', '[^,]+') county_name
FROM dual;



select distinct
     REGEXP_SUBSTR(gg.desc_geo, '[^,]+') county_name 
from q_individual i 
     join address_geo ge on ge.id_addr = i.id_pref_addr 
     join decode_geo gg on gg.code_geo = ge.code_geo
where 1=1 
and i.id_demo = 300400907
and gg.code_geo_type = 'A'
and i.code_addr_stat = 'C'
;