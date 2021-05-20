--*********************************************************************************
--Figuring out what events they should be invited that is closers to alums preferred address
--Case study: U Morris Alums in Twin Cities areas to be invited either: 
    --1. One event in St Paul/West St Paul
    --2. Another event in Woodbury/Maplewood
    --Condition: do not invite alums if they're more than 10 Miles away from venue. 

--*********************************************************************************
 select * from all_sdo_index_info;
 select * from all_sdo_index_metadata; --RTREE

--ver 1: based on primary Zip code (center of the areas)
drop table t999999999_2;
create table t999999999_2 as 
with temp_pool 
as(select w.*, ad.geo_location  
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
as(select geo_location, zipcode 
   from cbsa_county
   where zipcode in ('55125','55118')   
   and primaryrecord = 'P'
 )
select a1.*
      , a2.zipcode   
      --, sdo_nn_distance (1)       as dist_miles_1  --pulling wrong miles 
      , mdsys.sdo_geom.sdo_distance(a1.geo_location, a2.geo_location,0.05, 'unit=mile') as dist_miles
from temp_events a2
     , temp_pool a1
where sdo_nn(a1.geo_location          -- Query Search Geometry (address of alums/donors)       
             , a2.geo_location        -- Query Windows Geometry (location of events)
             , 'sdo_batch_size = 4000 distance=10 unit=mile',1) = 'TRUE'
order by dist_miles
;--3 minutes
 
select * from t999999999_2;--3223 





--ver2: specific location 
drop table t999999999_pool;
create table t999999999_pool as 
with temp_pool 
as(
   select w.*, ad.geo_location  
   from(
        select distinct a.id_demo, i.id_pref_addr as id_addr, i.zip_code, i.city  
        from q_academic a
             join q_individual i on i.id_demo = a.id_demo
             join address_geo ag on ag.id_addr = i.id_pref_addr
       where a.code_clg_query = 'UMM'
       and ag.code_geo = 'C33460'   
       and i.year_death is null 
       and i.code_addr_stat = 'C'
      )w 
      join address ad on ad.id_addr = w.id_addr 
 where ad.geo_location is not null 
 and ad.error_string = 'No Error'
)
, temp_events                         --CBSA_COUNTY event locations --reference point  --from speicific zip code 
as(select w.*
   from(select ad.id_addr, ad.zip_code as zipcode, ad.geo_location 
        from address ad 
        where ad.code_addr_stat = 'C'
        and ad.id_demo = []      --id_demo of the DMS location address 
        and ad.geo_location is not null 
        and lower(ad.error_string)='no error' 
       )w 
 )
select /*+ LEADING(a2) USE_NL(a2) */   
      a1.*
      , a2.zipcode   
      --, round(sdo_nn_distance (1)) dist_miles  --pulling wrong miles 
      , mdsys.sdo_geom.sdo_distance(a1.geo_location, a2.geo_location,0.05, 'unit=mile') as dist_miles
from temp_pool a1
     , temp_events a2 
where sdo_nn(a1.geo_location          -- Query Search Geometry (address of alums/donors)       
             , a2.geo_location        -- Query Windows Geometry (location of events)
             , 'sdo_batch_size = 100 distance=10 unit=mile',1) = 'TRUE'
order by dist_miles
;

--select 182/60 minnts from dual; --runtime: 3.8 minutes

select * from t999999999_pool w where w.id_demo = 140326609; -- 630432570  --730380980;--3129 
 

 --stacker 
exec qstackerrel('t999999999_pool','t999999999b','N','N');
select * from t999999999b;



--$$$$
drop table t999999999_inbox;
create  table t999999999_inbox as 
select s.* 
       , i_info.has_email(s.id_demo)as has_email 
       , acad.degree_list_major_clg(id_demo, 'UMM') as acad_info
from t999999999b s 
;

select * from t999999999_inbox;--28


--stats 
select * from t999999999_pool /*closest_loc_b*/ a where a.id_demo = 300026153;

--insert_inbox

EXEC batchman.ri_tapi.delete_report('t999999999_inbox');
COMMIT;
EXEC batchman.ri_tapi.add_report('t999999999_inbox','Event held in areas xx/yy closests to the alum/donor within xy Miles','xxx,AIJIBRIL');
COMMIT;
SELECT * FROM ri_report_user WHERE id_report = 't999999999_inbox';
SELECT * FROM batchman.ri_scheduled_report WHERE id_report = 't999999999_inbox';
EXEC batchman.ri_main.send_to_remote_inbox('t999999999_inbox');
COMMIT;