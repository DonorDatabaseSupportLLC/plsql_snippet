--******************* clg_km_999999999_v1.SQL *********************************************
--Purpose: Query alum/donors/prospects who live within xy miles in certain areas 
--         Using Oracle Spatial capacity  (US ONLY)
--*******************************************************************************************


--*************************************************************************
--1. find zip of the city/areas requested --use the zip with highest pop. density  
--*************************************************************************
with temp_city
as(select rank()over(order by population desc, rownum) as most_populas
         , a.*  
  from cbsa_county a 
  where lower(a.city) = 'nashville'
  and a.state = 'TN'
  and primaryrecord = 'P'
 ) 
select most_populas, city, state, zipcode, primaryrecord, population
from temp_city 
where most_populas = 1 
;
 
--*************************************************************************
--2. get zipcode within this range  
--*************************************************************************
 exec qryadm.radius_addr_finder('37211', 45, 't999999999_ids')
 select * from t999999999_ids; --1575  
 
 
--a
drop table t999999999_a;
create  table t999999999_a as 
select distinct 
       a.id_demo
       , i.id_pref_addr
       , i.city        as pref_city
       , i.state       as state_pref 
       , i.zip_code    as pref_zip
from q_academic a
    join q_individual i on i.id_demo = a.id_demo
where a.code_clg_query = 'UMM'  
and i.year_death is null 
and i.code_addr_stat = 'C'
and i.code_anon in ('0','1')
and i.id_pref_addr in (select aa.id_addr from t999999999_ids aa)
AND NOT EXISTS (SELECT 'x' FROM all_subscription_v asv
                WHERE 1=1
                AND asv.id_demo = i.id_demo 
                AND asv.code_unit = 'UNIT'
                AND asv.code_channel = 'CHANNEL'         --M = Mail  --E = Email  --P = Phone
                AND asv.code_subscript_type = 'TYPE'  --E = Event  --P = Publication  --S = Solicitation  --V = Survey
                AND asv.code_subscription IS NULL  -- Use for general subscription level
                AND asv.code_subscript_opt_type = 'OUT'
                AND NOT EXISTS (SELECT 'x' FROM all_subscription_v asv2
                                WHERE 1=1
                                  AND asv.id_demo = asv2.id_demo
                                  AND asv.code_unit = asv2.code_unit
                                  AND asv.code_channel = asv2.code_channel
                                  AND asv.code_subscript_type = asv2.code_subscript_type
                                  AND asv.code_subscription = asv2.code_subscription
                                  AND asv2.code_subscript_opt_type = 'IN'
                                  )
                )
    ;
select * from t999999999_a;--30


--stacker id_demo finder 
exec qstackerrel('t999999999_a','t999999999_qstkr','N','N');
select * from t999999999_qstkr;--29



--insert_inbox
EXEC batchman.ri_tapi.delete_report('t999999999_qstkr');
COMMIT;
EXEC batchman.ri_tapi.add_report('t999999999_qstkr','Alums within xy Miles in CITY, STATE','xxx,AIJIBRIL');
COMMIT;
SELECT * FROM ri_report_user WHERE id_report = 't999999999_qstkr';
SELECT * FROM batchman.ri_scheduled_report WHERE id_report = 't999999999_qstkr';
EXEC batchman.ri_main.send_to_remote_inbox('t999999999_qstkr');
COMMIT;