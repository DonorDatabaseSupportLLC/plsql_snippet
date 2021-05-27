--******************* fnd_mg_999999999_v2.SQL ***************************
--purpose:  
--author: Abdi Jibril
--date: 24-MAY-2019
--original Query: 999999999 --last query: 201901568 
--SELECT to_char(SYSDATE,'DD-MON-YYYY') as dt FROM dual;
--***********************************************************************

--*********************************************************************** 
-- 1. Search Fields: CLA $2k+ donors OR Planned Giving donors 
-- 2. Query Window: Madison Club (5 E Wilson St, Madison, WI 53703). 
-- 3. Radius: 100 miles from Query Windows (2). 
--************************************************************************


--select srid from ALL_SDO_GEOM_METADATA where upper(table_name) = 'ADDRESS' --srid
 

--create event location: Query Windows (spatial reference point)
drop table t999999999_geo;
create table t999999999_geo as 
select 
/*       SDO_GEOMETRY(2001
                    , 4326
                    , SDO_POINT_TYPE(-89.3812       --make sure '- negative sign is there for X-longitude 
                                     , 43.07263
                                     , NULL
                                     )
                    , NULL
                    , NULL) as geo_location*/
qryadm.get_sdo_geometry(-89.3812, 43.07263) as geo_location
from dual
;
select * from t201901927_geo; 
--desc t999999999_geo;  --geo_location must be SDO_GEOMETRY data type --similar to the Address.geo_location  feild. 
--desc address; 


--pool 
drop table t999999999_a;
create table t999999999_a as 
with temp_alums                                 
as(select w.id_demo, i.state, i.city, i.zip_code, ad.geo_location --1. Search field: temp_alums.geo_Location 
   from(
        select p.id_demo 
        from q_production_id p 
             join decode_exp_type et 
                  on et.code_exp_type = p.code_exp_type 
        where p.code_clg = 'CLA'
        and et.flag_deferred = 'Y'
        and p.code_anon in ('0','1')
        and p.code_recipient != 'S'
        union 
        select id_demo 
        from q_donor_ltd 
        where amt_ltd_rel >= 2000
        and key_value = 'CLA'
        and code_key_value = 'C'
        union 
        select a.id_demo
        from q_academic a 
             join q_individual i 
                  on i.id_demo = a.id_demo 
             join q_capacity cc 
                  on cc.id_household = i.id_household 
        where a.code_clg_query = 'CLA'
        and cc.code_rating_capacity <= 'K' --select * from decode_rating_capacity; --K  ($50K - $100K)
      )w 
       join q_individual i 
            on i.id_demo = w.id_demo
       join address ad 
            on ad.id_addr = i.id_pref_addr 
    where 1=1 
    and ad.geo_location is not null 
    and i.year_death is null 
    and i.code_addr_stat = 'C'
    and i.code_anon in ('0','1')
    and lower(ad.error_string) = 'no error' 
)
, temp_events                          --2. Query window (temp_events.geo_location --reference point  
as(
    select geo_location from t999999999_geo
    --select sdo_geometry(2001,4326,SDO_POINT_TYPE(-89.3812,43.07263,null),null,null) as geo_location from dual a 
 )
select  /* Leading(a2) */
    distinct a1.id_demo, a1.city, a1.state, a1.zip_code 
    , mdsys.sdo_geom.sdo_distance(a1.geo_location, a2.geo_location, 0.0000000005, 'unit=mile') as distance_miles
from temp_alums a1 
     , temp_events a2 
where sdo_within_distance (a1.geo_location             --a1: Search column: addresses within 60 miles of 'address i' 
                           , a2.geo_location           --a2: Query window: Reference point - Used to check for distance against the 'temp_alums.geo_location'  
                           , 'distance = 100 unit=mile'
                         ) = 'TRUE'
order by distance_miles
; --run time: 1.8 seconds  


select * from t999999999_a; 
SELECT COUNT (*) FROM t999999999_a;--190
 


 

