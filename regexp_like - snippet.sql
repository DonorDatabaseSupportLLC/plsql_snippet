select * 
from decode_sub_corridor ss 
where ss.code_corridor = 'CH'
and REGEXP_LIKE (ss.desc_sub_corridor,'(hospital|clinic|applied|program)','i')

;

select *
from decode_use ss
where REGEXP_LIKE (ss.desc_use,'(research|education|applied)','i')
;


--remove non-numeric characters.
select 
      trim(REGEXP_REPLACE('651-276-0718','[^0-9]',''))   as phone_removed_dash
      , trim(REGEXP_REPLACE('651A276B0718','[^0-9]','')) as phone_removed_alpha
      , trim(REGEXP_REPLACE('651/276/0718','[^0-9]','')) as phone_removed_slash
from dual; 