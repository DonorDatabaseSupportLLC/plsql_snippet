--*********************************************************************************
--Figuring out what events they should be invited that is closers to alums preferred address
--Case study: U Morris Alums in Twin Cities areas to be invited either: 
    --1. One event in St Paul/West St Paul
    --2. Another event in Woodbury/Maplewood
    --Condition: do not invite alums if they're more than 10 Miles away from venue. 

--*********************************************************************************

DBMS_STATS.GATHER_TABLE_STATS(ownname=>user,tabname=>'restaurants',cascade=>TRUE);
DBMS_STATS.GATHER_TABLE_STATS(ownname=>user,tabname=>'menu_items',cascade=>TRUE, method_opt=>'FOR ALL INDEXED COLUMNS SIZE AUTO');

--ver 1: based on primary Zip code (center of the areas)
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
as(select geo_location, zipcode 
   from cbsa_county
   where zipcode in ('55125','55118')   
   and primaryrecord = 'P'
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
        and ad.zip_code in ('55125')            
        and ad.geo_location is not null 
        and lower(ad.error_string)='no error' 
       )w 
   where rownum <= 1 
   union all --union would not work 
   select w.*
   from(select ad.id_addr, ad.zip_code, ad.geo_location 
        from address ad 
        where ad.code_addr_stat = 'C'
        and ad.zip_code in ('55118')            
        and ad.geo_location is not null 
        and lower(ad.error_string)='no error' 
       )w 
   where rownum <= 1  
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