--test case: Query # 201803619 

--*************************************************************
-- Production ver. 1. zip finder   				  --OLD
-- case study: all zip_codes within 60 Mi of Morris, MN 56267
--*************************************************************
drop table t999999999_zip;
create table t999999999_zip as 
with
	 temp_point_a as(select w.*
   								 from(	
                        select ad.id_addr,ad.geo_location 
                        from address ad 
                        where ad.code_addr_stat = 'C'
                        and ad.zip_code = '56267'          --Morris, MN
                        and ad.geo_location is not null 
                        and lower(ad.error_string)='no error' 
                   )w 
                   where rownum = 1 
                  )
select /*+ ordered NO_INDEX(c zip_code) */ 
		distinct c.zip_code 
from temp_point_a i
		 , address c
where 1=1  
--and c.id_addr <> i.id_addr
and c.code_addr_stat = 'C'
and c.code_country = 'USA'
and trim(c.zip_code) is not null 
and lower(c.error_string) = 'no error' 
and sdo_within_distance (c.geo_location             --c: addresses within 60 miles of 'address i' - zip_code to be returned. 
                          , i.geo_location          --i: Reference point - Used to check for distance against the 'Address c'  
                          , 'distance=60 unit=mile'
                         ) = 'TRUE'
            
;
select * from t999999999_zip;--135

--***********************************************************
-- Production: Code used in Stored Procedure. -- CURRENT
-- case study: all zip_codes within 60 Mi of Morris, MN 56267
--***********************************************************
drop table radius_zip_finder_a;
create table radius_zip_finder_a as 
with
	 temp_point_a as(select w.*
   								 from(	
                        select ad.id_addr,ad.geo_location 
                        from address ad 
                        where ad.code_addr_stat = 'C'
                        and ad.zip_code = '56267'          --Morris, MN
                        and ad.geo_location is not null 
                        and lower(ad.error_string) = 'no error' 
                   )w 
                   where rownum = 1 
                  )
select /*+ ordered NO_INDEX(a2 zip_code) */ 
		distinct a2.zip_code 
from address a2
where a2.code_addr_stat = 'C'
and a2.code_country = 'USA'
and trim(a2.zip_code) is not null 
and a2.geo_location is not null 
and lower(a2.error_string) = 'no error' 
and sdo_within_distance (a2.geo_location              --A2: All addresses within 60 miles of address A1 (a1.geo_location)
                          , (select a1.geo_location from temp_point_a a1) --A1: Refer. point to find if address A2 are within 60 mi distance
                          , 'distance=60 unit=mile'
                         ) = 'TRUE'
            
;
select * from radius_zip_finder_a; --135
select distinct city, state from address where zip_code = '56318';

--script version 1/2 difference 
select * from radius_zip_finder_a  z 
where z.zip_code not in (select c.zip_code 
												 from t999999999_zip c
                         ); --0

--*************************************************************************************************************** 
--Test:  Stored Procudure result vs. Zip Finder: w:\ics\cbsa\ZipCodeRadiusFinder_3.13\ZipCodeRadiusFinder.exe: 
--Expected outcome: Same number of Zip codes 
--***************************************************************************************************************
--1. Production: from zip radius finder software
select count(distinct zip_code) from zip_find_software_60ml_Morris; --111

--2. Test: using Procedure 
exec qryadm.radius_zip_finder('56267',60, 'radius_zip_finder_a');
select count(zip_code) from radius_zip_finder_a;--135
select * from radius_zip_finder_a a where a.zip_code = '56318';--135

--in both 
select distinct zip_code 
from radius_zip_finder_a a 
where trim(a.zip_code) in (select trim(z.zip_code) from aijibril.zip_find_software_60ml_Morris z);--104

--1. In procedure generated zip table, but In software generated zip table
select distinct zip_code 
from t201803619_zip_test a 
where trim(a.zip_code) not in (select trim(z.zip_code) from zip_find_software_60ml_Morris z); --31

--2. In Software generated zip, but NOT in procedure generated zip table
with temp_addr as 
								(select distinct zip_code 
                 from zip_find_software_60ml_Morris a 
                 where trim(a.zip_code) not in (select trim(z.zip_code) from radius_zip_finder_a z)--7
                 )
select * 
from address a 
where a.zip_code in (select trim(aa.zip_code) from temp_addr aa)
and a.code_addr_stat = 'C'
--and lower(a.street_1) not like '%p%box%'
;




 
--**********************************************
-- END TESTING 
--**********************************************

select to_char(z.zip_code)
from zip_find_software_60ml_Morris z 
where  to_char(z.zip_code) = '56201';


select distinct city, state from address where zip_code = '56318';





--HELPERS 

-- List of spatial indexes and their types 
--select * from mdsys.all_sdo_index_info@prod; --ADDRESS table 
 
--query Geographical Map zone in MN 
select cs_name, srid, wktext
from mdsys.cs_srs
where wktext like 'PROJCS%' and cs_name like '%Minnesota%';

select a.* --a.longitude, a.latitude, a.geo_Location
from address a 
where a.id_addr = 1003074831 --sdo_SRID: 8307
;

--You can check the SDO metadata table to get spatial information:
select * from MDSYS.ALL_SDO_GEOM_METADATA

-- GIS NOTES NOTES  
 
--test case: distance between these two address 
select a.id_addr, a.id_demo,a.street_1,city,state,zip_code,geo_location,a.longitude,latitude 
from address a
where a.code_addr_stat = 'C'
and  a.id_addr in (1006858039,1013178573,1013408768,1003807811)
;



--SDO_nn (nn: Nearest Neighbor) - Uses the spatial index to identify the nearest neighbors for a geometry.
/* 
sdo_nn(geometry1    SDO_GEOMETRY
			 , geometry2  SDO_GEOMETRY 
       , param      VARCHAR2  
       , number     NUMBER --If SDO_NN_DISTANCE is included in the call to SDO_NN, same number used as sdo_nn_distance.      
       )  
         
***************************************************/



--*********************************************************************************************
--  5 miles within addresss: 300 Shamrock Way Saint Paul,MN 55115 (id_addr = 1003807811)
--  Distance (in Google) is not driving distance, but rather STRAIGHT LINE distance
--********************************************************************************************* 
select * from address a where a.id_addr in (1013412401,1000963605) ;  

select /*+ ordered */ 
       a2.*
FROM address a1
   , address a2
WHERE a1.id_addr = 1013412401
and a1.id_addr <> a2.id_addr
and a2.id_addr = 1000963605
AND sdo_within_distance (a1.geo_location, a2.geo_location, 'distance=60 unit=mile') = 'TRUE'
;

   

select /*+ ordered */ 
     round(sdo_nn_distance(60)/1000,3) as distance_mile  --1A. MUST match #5 (sdo_nn- parameter # 4 - value in Meters (convert to Miles)
     , sdo_nn_distance(60) as distance_meter  --1B. Defines distance between Point A(id_addr=	1003807811) & nearest neighbor - in Meter	
     , a2.*
FROM address a1
   , address a2
WHERE a1.id_addr = 1000963605  --300 Shamrock WaySaint Paul,MN 55115
--and a1.id_addr <> a2.id_addr
and a2.code_addr_stat = 'C'
and a1.code_addr_stat = 'C'
and a2.id_addr =  1013412401
and sdo_nn(a2.geo_location             --2. geometry 1
					, a1.geo_location            --3. geometry 2 
          , 'sdo_num_res=100000'       --4. Specifies the number of rows (nearest neighbors) to be returned.
          , 60                         --5 distance NUMBER  
          ) = 'TRUE'
--order by distance desc 
order by distance_mile desc 
; 




 




--version 
SELECT SDO_VERSION FROM DUAL;

--value spatial 
SELECT PARAMETER,VALUE FROM v$option WHERE parameter= 'Spatial';

--Snippet from Sanjeev 
--SDO_nn (nn: Nearest Neighbor) - Uses the spatial index to identify the nearest neighbors for a geometry.
/* 
sdo_nn(geometry1    SDO_GEOMETRY
			 , geometry2  SDO_GEOMETRY 
       , param      VARCHAR2  
       , number     NUMBER --If SDO_NN_DISTANCE is included in the call to SDO_NN, same number used as sdo_nn_distance.      
       )  
         
*/

--sanjeev snippet          
select /*+ ordered */ 
       round(sdo_nn_distance(5)/1000,1) distance     --1. MUST match #5 (sdo_nn- parameter # 4 (number)
     , a2.*
FROM address a1
   , address a2
WHERE a1.id_addr = 1003807811
and a1.id_addr <> a2.id_addr
and a2.code_addr_stat = 'C'
and a1.code_addr_stat = 'C'
and a2.id_addr = 1006858039
and sdo_nn(a2.geo_location             --2. geometry 1
					, a1.geo_location            --3. geometry 2 
          , 'sdo_num_res=10000'      --4. Specifies the number of rows (nearest neighbors) to be returned.
          , 5                          --5 distance 100 
          ) = 'TRUE'
order by distance desc 
; 





--**********************************************************************
--Snippet from Sanjeev : DO NOT CHANGE
--**********************************************************************
select /*+ ordered */ 
       sdo_nn_distance(1) distance
     , a2.*
FROM address a1
   , address a2
WHERE a1.id_addr = 1003070152
and a1.id_addr <> a2.id_addr
AND sdo_nn(a2.geo_location, a1.geo_location, 'sdo_num_res=100',1) = 'TRUE'
order by distance
/

select /*+ ordered */ 
       a2.*
FROM address a1
   , address a2
WHERE a1.id_addr = 1003070152
and a1.id_addr <> a2.id_addr
AND sdo_within_distance (a2.geo_location, a1.geo_location, 'distance=1 unit=mile') = 'TRUE'

 