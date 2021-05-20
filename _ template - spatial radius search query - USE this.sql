--query # 201901927

/* ********************************************************************************************************* 

--1. Option - Preferred. 
--Using US Census Bureau site: https://geocoding.geo.census.gov, plugin address. 
Coordinates:
X: -89.3812  --longitude   
Y: 43.07263  --latitude


--2. Option. 
--Google map --type the address into google map and browser URL will have long/lat: 
Lat: 43.072474
Long: -89.3829197

--3. Another option. --do not use. 
--gps-coordinates.net: 
Latitude: 43.07252
Longitude: -89.381254

--=================================================================================================
--create SDO_GEOMETRY data type field so you can search people who live xyz raduis of this address 
--=================================================================================================

SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-X,Y,NULL),NULL,NULL)  --plug in X(longitute). Y(latitude)

--create table so you can use it as the Query Window table - reference point (Event/Invitees--it is the EVENT table).
create table t201901927_geo as 
select SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(89.3812,43.07263,NULL),NULL,NULL) as geo_location   
from dual ;


*********************************************************************************************************/




--Example: 1. Existing Address in DMS to use as Windows Query
drop table t201901927a;
create table t201901927a as 
with temp_alums                                 --1. Get the alums id_demo, geo_Location 
as(select w.id_demo, i.state, i.city, i.zip_code, cc.code_rating_capacity, ad.geo_location  
   from(select a.id_demo  
        from q_academic a
        where a.code_clg_query = 'CLA'
        union 
        select p.id_demo 
        from q_production_id p 
        where p.code_clg = 'CLA'
        and p.code_anon in ('0','1')
        and p.code_recipient != 'S'
      )w 
       join q_individual i 
            on i.id_demo = w.id_demo
       join address ad 
            on ad.id_addr = i.id_pref_addr 
       join q_capacity cc 
            on cc.id_household = i.id_household 
    where 1=1 
    and cc.code_rating_capacity <= 'K'--select * from decode_rating_capacity; 
    and ad.geo_location is not null 
    and i.year_death is null 
    and i.code_addr_stat = 'C'
    and i.code_anon in ('0','1')
    and lower(ad.error_string) = 'no error' 
    --and ad.state = 'WI'        
)
, temp_events                           --CBSA_COUNTY event locations --reference point  --from speicific zip code 
as(select a.id_demo, a.geo_location, a.id_addr, a.street_1, city, state, zip_code, a.code_addr_type
   from address a 
   where a.id_demo = 140200468  
   and a.id_addr = 1008020771
 )
select a1.id_demo, a1.city, a1.state, a1.zip_code, a1.code_rating_capacity 
      , sdo_geom.sdo_distance(a1.geo_location, a2.geo_location,0.0000000005, 'unit=mile') as distance_miles
from temp_alums a1 
     , temp_events a2 
where sdo_within_distance (a1.geo_location             --c: addresses within 60 miles of 'address i' - zip_code to be returned. 
                           , a2.geo_location             --i: Reference point - Used to check for distance against the 'Address c'  
                           , 'distance= 60 unit=mile'
                         ) = 'TRUE'
order by distance_miles
; --run time: 6 sec  
 

select count(distinct id_demo), count(*) from t201901927a; --41
select * from t201901927a a where a.id_demo = 140200468;

 
--Example: 2. Using zip code as Window Query 
drop table t201901927aa;
create table t201901927aa as 
with temp_alums                                 --1. Get the alums id_demo, geo_Location 
as(select w.id_demo, i.state, i.city, i.zip_code, cc.code_rating_capacity, ad.geo_location  
   from(select a.id_demo  
        from q_academic a
        where a.code_clg_query = 'CLA'
        union 
        select p.id_demo 
        from q_production_id p 
        where p.code_clg = 'CLA'
        and p.code_anon in ('0','1')
        and p.code_recipient != 'S'
      )w 
       join q_individual i 
            on i.id_demo = w.id_demo
       join address ad 
            on ad.id_addr = i.id_pref_addr 
       join q_capacity cc 
            on cc.id_household = i.id_household 
    where 1=1 
    and cc.code_rating_capacity <= 'K'            --select * from decode_rating_capacity; 
    and ad.geo_location is not null 
    and i.year_death is null 
    and i.code_addr_stat = 'C'
    and i.code_anon in ('0','1')
    and lower(ad.error_string) = 'no error' 
    --and ad.state = 'WI'        
)
, temp_events                           --CBSA_COUNTY event locations --reference point  --from speicific zip code 
as(select a.geo_location, zipcode as zip_code 
   from cbsa_county a 
   where a.zipcode = '53593' 
   and a.primaryrecord = 'P'
 )
select a1.id_demo, a1.city, a1.state, a1.zip_code, a1.code_rating_capacity 
      , mdsys.sdo_geom.sdo_distance(a1.geo_location, a2.geo_location,0.0000000005, 'unit=mile') as distance_miles
from temp_alums a1 
     , temp_events a2 
where sdo_within_distance (a1.geo_location                --c: addresses within 60 miles of 'address i' - zip_code to be returned. 
                           , a2.geo_location              --i: Reference point - Used to check for distance against the 'Address c'  
                           , 'distance = 60 unit=mile'
                         ) = 'TRUE'
order by distance_miles
; --run time: 6 sec  

select * from t201901927aa; --39. 



--***************************************************************************************
-- Non-DMS Address: Geoded to be used as Query Window
-- Madison Club (5 E Wilson St, Madison, WI 53703). 
-- v1: alum/donors with $50K+ capacity 
--*************************************************************************************** 


--Example 3. using Non-DMS address 
--Optionally you can create the Window Query table upfront instead of 'Temp table'
create table t201901927_geo as 
select SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(89.3812,43.07263,NULL),NULL,NULL) as geo_location --SDO_GEOMETRY data type    
from dual a;
select * from t201901927_geo; 
desc t201901927_geo; --confirm data type. 


--pool 
drop table t201901927d;
create table t201901927d as 
with temp_alums                                 --1. Get the alums id_demo, geo_Location 
as(select w.id_demo, i.state, i.city, i.zip_code, cc.code_rating_capacity, ad.geo_location  
   from(select a.id_demo  
        from q_academic a
        where a.code_clg_query = 'CLA'
        union 
        select p.id_demo 
        from q_production_id p 
        where p.code_clg = 'CLA'
        and p.code_anon in ('0','1')
        and p.code_recipient != 'S'
      )w 
       join q_individual i 
            on i.id_demo = w.id_demo
       join address ad 
            on ad.id_addr = i.id_pref_addr 
       join q_capacity cc 
            on cc.id_household = i.id_household 
    where 1=1 
    and cc.code_rating_capacity <= 'K'--select * from decode_rating_capacity; 
    and ad.geo_location is not null 
    and i.year_death is null 
    and i.code_addr_stat = 'C'
    and i.code_anon in ('0','1')
    and lower(ad.error_string) = 'no error' 
    --and ad.state = 'WI'        
)
, temp_events                            
as(select SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-89.3812,43.07263,NULL),NULL,NULL) as geo_location   --Build Query Window 
   from dual a 
 )
select a1.id_demo, a1.city, a1.state, a1.zip_code, a1.code_rating_capacity 
      , mdsys.sdo_geom.sdo_distance(a1.geo_location, a2.geo_location,0.0000000005, 'unit=mile') as distance_miles --param1. search field, param2: Window Query.
from temp_alums a1 
     , temp_events a2 
where sdo_within_distance (a1.geo_location             --c: addresses within 60 miles of 'address i' - zip_code to be returned.  -- Search field 
                           , a2.geo_location           --i: Reference point - Used to check for distance against the 'Address c' -- Window Query  
                           , 'distance= 60 unit=mile'
                         ) = 'TRUE'
order by distance_miles
; --run time: 6 sec  
 

select count(distinct id_demo), count(*) from  t201901927xx; --50
select * from t201901927d a where a.id_demo = 140200468;



