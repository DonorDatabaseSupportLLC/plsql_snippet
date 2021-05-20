--******************* umm_km_999999999_v1.SQL ***************************
--purpose: UMM Inquiry from Development Officer 
--author: Abdi Jibril
--date: 24-MAY-2019
--original Query: 999999999 --last query: 201901568 
--SELECT to_char(SYSDATE,'DD-MON-YYYY') as dt FROM dual;
--*************************************************************************
 
        
--pool 
drop table t999999999a;
create  table t999999999a as 
with temp_alums                                 --1. Get the alums id_demo, geo_Location 
as(select w.*, ad.geo_location as geom  
   from(
         select distinct a.id_demo, i.id_pref_addr, i.zip_code, i.city, i.state 
         from q_academic a
              join q_individual i on i.id_demo = a.id_demo
         where a.code_clg_query = 'UMM'
         and i.year_death is null 
         and i.code_addr_stat = 'C'
         and i.code_anon in ('0','1')
        )w 
         join address ad on ad.id_addr = w.id_pref_addr 
    where ad.geo_location is not null 
    --and lower(ad.error_string)='no error' 
    AND NOT EXISTS (SELECT 'x' FROM all_subscription_v asv
            WHERE 1=1
            AND asv.id_demo = w.id_demo 
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
    
)
, temp_events                         --CBSA_COUNTY event locations --reference point  --from speicific zip code 
as(select geo_location, zipcode as zip_event_loc  
   from cbsa_county
   where zipcode in ('55125','55118')   
   and primaryrecord = 'P'
 )
, temp_pool 
as(select w.*   
       , dense_rank()over(partition by id_demo order by distance asc, rownum) as rnk   
   from(
        select a.id_demo 
               , a.id_pref_addr
               , a.city             as pref_city          
               , a.state            as pref_state 
               , a.zip_code         as pref_zip
               , e.zip_event_loc
               , SDO_GEOM.SDO_DISTANCE(a.geom, e.geo_location, 0.005,'unit=mile') AS distance
         from temp_alums a 
              cross join temp_events e 
       )w 
   )
select * 
from temp_pool tp 
where tp.distance <= 10
--where id_demo = 330383326
 ;--20sec --25sec --39sec 
 
select count(*) cnt_all,count(distinct id_demo) cnt_alum,count(distinct id_pref_addr) cn_addr from t999999999a; --42,864/21,432/21,432  
select * from t999999999a a where a.id_pref_addr = 1008844410;
--55118: 153,946.97 --meter  --mile: 95.7
--55125: 167,419.69 --meters  --mile: 104.




--helpers 

 
select /*+ LEADING(a2) USE_NL(a2,a1) */     --LEADING(a2) helps performance when temp_event code is used in here--with where clauses. 
      a1.id_demo, a1.city, a1.state, a1.zip_code 
      , mdsys.sdo_geom.sdo_distance(a1.geo_location, a2.geo_location,0.05, 'unit=mile') as distance_miles
from temp_alums a1 
     , temp_events a2 
where sdo_within_distance (a1.geo_location             --c: addresses within 60 miles of 'address i' - zip_code to be returned. 
                           , a2.geo_location             --i: Reference point - Used to check for distance against the 'Address c'  
                           , 'distance=45 unit=mile'
                         ) = 'TRUE'
order by distance_miles
 --run time: 0.7 min  
 
select * from t999999999a;--30


--stacker 
exec qstackerrel('t999999999a','t999999999b','N','N');
select * from t999999999b; --29 (couple stacked)



--$$$$
drop table t999999999_inbox;
create  table t999999999_inbox as 
select s.* 
       , i_info.has_email(s.id_demo)as has_email 
       , acad.degree_list_major_clg(id_demo, 'UMM') as acad_info
from t999999999b s 
;

select * from t999999999_inbox;--28

--insert_inbox

EXEC batchman.ri_tapi.delete_report('t999999999_inbox');
COMMIT;
EXEC batchman.ri_tapi.add_report('t999999999_inbox','Alum in CITY, STATE within xy Miles','xxx,AIJIBRIL');
COMMIT;
SELECT * FROM ri_report_user WHERE id_report = 't999999999_inbox';
SELECT * FROM batchman.ri_scheduled_report WHERE id_report = 't999999999_inbox';
EXEC batchman.ri_main.send_to_remote_inbox('t999999999_inbox');
COMMIT;