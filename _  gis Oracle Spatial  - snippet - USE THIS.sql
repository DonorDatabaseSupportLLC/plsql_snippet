--fnd_pd_neighborhood.sql

prompt *****************************************************************************************************************
-- spatial metadata tables to be familiar with - 

--query spatial tables
select * from ALL_SDO_GEOM_METADATA;  
select * from USER_SDO_GEOM_METADATA; --empty 

--Centroid: We can create the centroid (center of gravity) for a polygonal shape using the following template:
SELECT a.*, SDO_GEOM.SDO_CENTROID(geom, 0.05) from aijibril.pd_stg_geo_nbhd_abdi a ;

--If SDO_SRID is not null, it must contain a value from the SRID column of the SDO_COORD_REF_SYS table, 
--and this value must be inserted into the SRID column of the USER_SDO_GEOM_METADATA view.
select *
from SDO_COORD_REF_SYS a 
where 1=1 
and srid in (/*8307,*/4326)
--and data_source = 'Oracle' --8307 is legacy (oracle specific)
;
select * from sdo_srid ;

--EPSG to SRID
select SDO_CS.MAP_EPSG_SRID_TO_ORACLE(8307)   as epsg_to_oracle_srid 
       , SDO_CS.MAP_ORACLE_SRID_TO_EPSG(8307) as oracle_to_epsg_srid 
from dual;

--Gets the version number of the EPSG dataset used by Oracle Spatial.
SELECT SDO_CS.GET_EPSG_DATA_VERSION FROM DUAL; --7.5
 
--set this parameter to help speed up the spatial query SDO_JOIN
SELECT * FROM  v$PARAMETER p WHERE p.NAME = 'spatial_vector_acceleration';
ALTER SESSION SET SPATIAL_VECTOR_ACCELERATION = TRUE;

--get the Geo Shape type 
select distinct s.geom.get_gtype() as geometry_shape from qrydbo.pd_stg_geo_nbhd s; --1:point. 2:line 3: polygon. 7:Multipolygon.
select * from qrydbo.pd_stg_geo_nbhd;
                 
-- Review this site to explain Datum: https://gisgeography.com/ellipsoid-oblate-spheroid-earth/
select * from MDSYS.CS_SRS a 
where a.srid in (4326    --universal/Google  
                 , 8307 --Oracle 
                 );
                 
prompt *****************************************************************************************************************

--1. set these session level parameters 
SELECT * FROM  v$PARAMETER p WHERE p.NAME = 'spatial_vector_acceleration';  

ALTER SESSION SET SPATIAL_VECTOR_ACCELERATION = TRUE; --DO NOT USE we have NO Oracle SPATIAL License. We have ONLY LOCATOR. 

--2. spatial tables/view available - Metadata view  
select * from ALL_SDO_GEOM_METADATA ;  

--get the srid from DMS 
select srid from all_sdo_geom_metadata where table_name = 'ADDRESS';  

--Neighborhood data for qrydbo - copy to Abdi's schema to test 
select * from aijibril.pd_stg_geo_nbhd_abdi;

--production synonyms under schema borah.pd_stg_geo_nbhd  table. 
select * from qrydbo.pd_stg_geo_nbhd;

--select * from pd_stg_geo_nbhd_abdi;

--******************************************************
--tolerance: --v1 --select * from ALL_SDO_GEOM_METADATA; 
--******************************************************
SELECT DISTINCT 
    m.table_name
    , m.owner
    , m.column_name 
    , srid
    , to_char((D.SDO_TOLERANCE)) AS Tolerance
FROM ALL_SDO_GEOM_METADATA M
     , TABLE(m.DIMINFO) D 
;

--******************************************************
--tolerance: --v2
--******************************************************
SELECT META.TABLE_NAME
       , META.COLUMN_NAME
       , META.SRID
       , DIM.*
FROM ALL_SDO_GEOM_METADATA META
     , TABLE(META.DIMINFO) DIM
--WHERE META.TABLE_NAME = 'ADDRESS'
;



--get spatial shape type 
select distinct s.geom.get_gtype() as geometry_shape 
from aijibril.pd_stg_geo_nbhd_abdi s; --1:point. 2:line 3: polygon. 7:Multipolygon.

--spatial indexes 
select * from all_SDO_INDEX_INFO;


--3. get tolerance 
column num format 99999999999;
SELECT distinct 
       m.table_name
       , m.column_name
       , srid
       , (d.SDO_TOLERANCE) as tolerance
       , to_char(SDO_TOLERANCE)as tolerance_numb
       , sdo_units 
       , o.owner 
       , o.object_type 
       , o.created 
       , o.status 
       , o.last_ddl_time 
FROM all_SDO_GEOM_METADATA m 
     , TABLE(m.DIMINFO) d
     , all_objects o 
WHERE lower(o.object_name) = lower(m.table_name) 
AND lower(TABLE_NAME) = 'pd_stg_geo_nbhd'
AND o.object_type = 'TABLE'
AND o.owner = 'QRYDBO' --remove later 
;
 

--gis data structure 
select * 
from SDO_COORD_REF_SYS a 
where a.srid in (4326    --universal/Google  
                 , 8307  --Oracle 
                 );
      
--check invalidate the neighborhood 
WITH temp_gis 
AS(
  SELECT c.*
        , SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(c.geom, 0.0000000005) as valid_hood  --get from item # 3. 
  FROM qrydbo.pd_stg_geo_nbhd /*aijibril.pd_stg_geo_nbhd_abdi*/  c 
  )
select *
from temp_gis c
where valid_hood != 'TRUE'
and c.nbhd_name = 'Edina'
;

--**************************************************************
-- check validity of shape/polygon file 
--**********************************************************

--find invalid shapes
with temp_a 
as(
    select s.*
           , s.geom.st_isvalid()  as status 
           , s.geom.get_wkt()     as well_known_text
           , case when s.geom.st_isvalid() = 1 
                  then 'Y' 
                  else 'N' 
             end as is_valid 
    from aijibril.pd_stg_geo_nbhd_abdi s
) 
select ta.*
       , dbms_lob.substr(ta.well_known_text,4000,1)       as well_known_text
       , ta.geom.get_gtype()                              as geo_type
       , SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(ta.geom,0.0000000005) as validation   
       , t.x 
       , t.y 
from temp_a ta 
     , TABLE(SDO_UTIL.GETVERTICES(ta.geom)) t
where ta.is_valid = 'N'
;



--**********************************************************
--remove duplicates 
--if dupe exists, it will remove 
--if not, it will return entire shapefile
--**********************************************************
drop table gis_neighbor_valid;
create table gis_neighbor_valid as 
SELECT 
    SDO_UTIL.REMOVE_DUPLICATE_VERTICES(s.geom
                                       --, 0.0000000005  --tolerance value
                                       , 0.005           --tolerance value of 5 meters
                                      )                             as geom_valid  
    , s.nbhd_name
    , s.geom                                  
    , SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(s.geom,0.0000000005)  as validation_5E_10
    , SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(s.geom,0.005 )        as validation_005
FROM aijibril.pd_stg_geo_nbhd_abdi s
;
select * from gis_neighbor_valid;

--
select 
    a.id_addr 
    , a.id_demo 
    , a.city 
    , a.zip_code 
    , jb.*
from gis_neighbor_valid /*aijibril.pd_stg_geo_nbhd_abdi*/ jb
inner join address a 
    on sdo_inside(a.geo_location, jb.geom_valid /*jb.geom*/) = 'TRUE'  --a.geo_location is INSIDE jb.geom
where jb.NBHD_NAME = 'Edina'
--and a.id_addr = 1013863187
and a.code_addr_stat = 'C'
;--7748  --15073 



--**************************************************************************************
--1. get the duplicate addressess' vertertices (lon/lat)
--2. tolerance make the difference -- 0.005(5 meters) vs. 0.0000000005 (on file)
--**************************************************************************************
with temp_a 
as(
    select s.*
           , s.geom.st_isvalid()  as status 
    from gis_neighbor_valid /*aijibril.pd_stg_geo_nbhd_abdi*/ s
    where s.geom.st_isvalid()  = 0
) 
, temp_b 
as(select ta.*
         --, SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(ta.geom,0.005) as validation
         , t.x 
         , t.y 
  from temp_a ta 
       , TABLE(SDO_UTIL.GETVERTICES(ta.geom)) t
)--select * from temp_b tb where tb.x = '-93.37126468' and tb.y = '44.8633524530001'; 
select tb.NBHD_NAME
       , x 
       , y 
       , count(*) cnt_lan_lon 
from temp_b tb 
where 1=1 
--and tb.x = '-93.37126468' and tb.y = '44.8633524530001'
group by tb.NBHD_NAME
       , x 
       , y 
having count(*) > 1
;

--another ways to get errors 
select a.*
       , substr(sdo_geom.validate_geometry(a.geom,0.005),1,10) as errCode
       --, sdo_geom.validate_geometry(a.geom,0.000000005)  as errCode
from aijibril.pd_stg_geo_nbhd_abdi   a
where 1=1 
--and a.geom is not null
--group by sdo_geom.validate_geometry(a.geom,0.005) 
;

--get x/y(long/lat)
select id_addr 
       , id_demo 
       , t.x longitude
       , t.y latitude
from address 
     , table (sdo_util.getvertices(geo_location)) t
where state= 'MN'
and city = 'Minneapolis'
and code_addr_stat = 'C'
;


--valid unit of distance 
select * from MDSYS.SDO_DIST_UNITS ; 

--********************************************
--get the vertices (lon/lat) 
-- 1. DOES NOT WORK for polygon/multipolygon shapes 
-- 2. WORKS for Point shape type - 
--********************************************

with temp_address 
as(select * 
   from address a 
   where a.id_demo = 830048950
   --nd a.code_addr_stat = 'C'
   )
select --p.geom.SDO_POINT.X, p.geom.SDO_POINT.Y 
      p.id_addr, p.street_1, p.street_2, p.city, p.state, p.zip_code 
      , p.geo_location.SDO_POINT.X
      , p.geo_location.SDO_POINT.Y 
from  temp_address p/*aijibril.pd_stg_geo_nbhd_abdi*/  /* aijibril.pd_stg_geo_nbhd_abdi*/ 
;

--********************************************
--WKT(well known text repre
--********************************************
select s.geom.get_wkt() from aijibril.pd_stg_geo_nbhd_abdi s;

--fixed 
WITH temp_gis 
AS(
    SELECT c.*
           --, SDO_UTIL.RECTIFY_GEOMETRY(c.geom, 0.005) as valid_hood 
    FROM aijibril.pd_stg_geo_nbhd_abdi c 
  ) 
select 
    a.id_addr  
    , a.city 
    , jb.*
    , a.city
from temp_gis jb
inner join address a 
    on sdo_inside(a.geo_location, jb.valid_hood) = 'TRUE'  --a.geo_location is INSIDE jb.geom
where 1=1 
and jb.NBHD_NAME = 'Edina'
and a.code_addr_stat = 'C'
and a.id_addr = 1013863187
;--15069

--Not Fixed 
select 
    a.id_addr 
    , a.id_demo 
    , a.city 
    , a.zip_code 
    , jb.*
from aijibril.pd_stg_geo_nbhd_abdi jb
inner join address a 
    on sdo_inside(a.geo_location, jb.geom) = 'TRUE'  --a.geo_location is INSIDE jb.geom
where jb.NBHD_NAME = 'Edina'
and a.id_addr = 1013863187
and a.code_addr_stat = 'C'
;--15069

select * from address a where a.id_demo  = 830048950 and a.id_addr in (1013064268,1009529979); --44.974432,-93.4080257






--*****************************************************************
--option 1: Batchman Scripts 
--*****************************************************************

WITH src AS (SELECT id_addr, jb.nbhd_name 
             FROM aijibril.pd_stg_geo_nbhd_abdi jb
                   JOIN address a ON 1=1
              WHERE sdo_inside(a.geo_location,jb.geom) = 'TRUE'
              )
SELECT id_addr, 'N' AS code_geo_type, nbhd_name
FROM src
WHERE id_addr = 222
UNION ALL
SELECT id_addr, 'N' as code_geo_type, 'Not in Neighborhood' AS nbhd_name
FROM address a
WHERE 1=1
AND id_addr = 2222
AND NOT EXISTS (SELECT 'x' FROM src s WHERE s.id_addr = a.id_addr);

--option 2
SELECT id_addr, 'N' AS code_geo_type , CASE WHEN jb.nbhd_name IS NOT NULL
                                                 THEN jb.nbhd_name
                                                 ELSE 'Not in Neigborhood'
                                                 END AS nbhd_name
FROM address a
LEFT JOIN aijibril.pd_stg_geo_nbhd_abdi jb ON sdo_inside(a.geo_location,jb.geom) = 'TRUE'
WHERE id_addr = 2222
;

--**********************************************************************************
--option 3(Abdi): SDO_INSIDE - WORKS
--**********************************************************************************
select 
    a.id_addr  
    --, a.street_1 
    --, a.code_addr_stat 
    --, a.id_demo 
    --, a.city 
    , jb.NBHD_NAME
from aijibril.pd_stg_geo_nbhd_abdi jb
inner join address a 
    on sdo_inside(a.geo_location, jb.geom) = 'TRUE'  --a.geo_location is INSIDE jb.geom
where 1=1 
--and id_demo in (300400907, 140298562)
;--total: 83998 
 --0.2
 

 
--**********************************************************************************
--option 4A. WORKS: SDO_RELATE
--url: https://docs.oracle.com/cd/E11882_01/appdev.112/e11830/sdo_intro.htm#SPATL460
--**********************************************************************************
with temp_a 
as(
   SELECT b.id_addr
          , a.NBHD_NAME
   FROM aijibril.pd_stg_geo_nbhd_abdi a 
         , address b
   WHERE SDO_RELATE(b.geo_location, a.Geom, 'mask=inside') = 'TRUE' -- b is reted to A because b.geo_location is INSIDE a.geom
   ) 
select a.* --count(*), count(distinct id_addr) cnt 
from temp_a a
--where a.id_addr = 1005268073
;
--runtime: 0.2
--total  : 83,998 


--SDO_RELATE (Contains parameter): super slow - donot use 
with temp_a 
as(
   SELECT b.id_addr
          , a.NBHD_NAME
   FROM aijibril.pd_stg_geo_nbhd_abdi a 
         , address b
   WHERE b.code_addr_stat = 'C'
   AND SDO_RELATE(a.Geom , b.geo_location, 'mask=contains') = 'TRUE' -- b is reted to A because b.geo_location is INSIDE a.geom
   ) 
select a.*  
from temp_a a
;
 

--**********************************************************************************
--option 5: CONTAINS: WORKS. SUPER SLOW. DO NOT USE
--**********************************************************************************
SELECT b.id_addr
       , a.NBHD_NAME
FROM address b 
     JOIN aijibril.pd_stg_geo_nbhd_abdi a 
          ON SDO_CONTAINS(a.Geom, b.geo_location) = 'TRUE' --A.geom neighborhood polygon CONTAINS b.geo_location 
WHERE 1=1
--AND b.id_addr = 1005268073
;




--*******************************************************************************
--helpers
--*******************************************************************************
 


--option 1 (Abdi) - Testing 
select 
    house.address,
    neighbourhood.name
from table(sdo_join('HOUSE', 'GEOMETRY', 'NEIGHBOURHOOD', 'GEOMETRY', 'mask=INSIDE')) a 
inner join house
    on a.rowid1 = house.rowid
inner join neighbourhood
    on a.rowid2 = neighbourhood.rowid;
    


--helpers


SELECT * FROM decode_geo_type;

SELECT *FROM q_individual WHERE id_psoft = '2104185';

SELECT * FROM aijibril.pd_stg_geo_nbhd_abdi;

SELECT * FROM address a where a.code_addr_stat = 'C' and a.city = 'Minneapolis' ;


--***********************************
-- check if shape/polygon is valid 
--***********************************
select a.* --substr(sdo_geom.validate_geometry(a.geom,0.005),1,10) as errCode
from qrydbo.pd_stg_geo_nbhd  a
where 1=1 
--and a.geom is not null
group by substr(sdo_geom.validate_geometry(A.geom,0.005),1,10)
;

create table pd_stg_geo_nbhd_abdi_2 as select * from borah.pd_stg_geo_nbhd ; 


 


SELECT c.name, SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(c.shape, 0.005)
   FROM cola_markets c WHERE c.name = 'cola_invalid_geom';