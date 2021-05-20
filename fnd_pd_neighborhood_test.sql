--fnd_pd_neighborhood.sql
ALTER SESSION SET SPATIAL_VECTOR_ACCELERATION = TRUE; --Value column MUST be TRUE to help performance for the spatial Query  
SELECT name,description, value FROM  v$PARAMETER p WHERE p.NAME = 'spatial_vector_acceleration';

exec qrydbo.trunc_tab('ADDRESS_NEIGHBORHOOD');

insert into address_neighborhood
with temp_neighborhood
as(select /*+ ORDERED */
      a.id_addr
      , 'N' as code_geo_type
      , jb.nbhd_name
  from qrydbo.pd_stg_geo_nbhd jb
       , address a
  where SDO_RELATE(a.geo_location, jb.Geom, 'mask=inside') = 'TRUE'  
  --mask=inside - Returns True, if the first object is entirely within the second object and the object boundaries do not touch; otherwise, returns FALSE.

)
select 
    id_addr
    , code_geo_type
    , nbhd_name
from temp_neighborhood
union 
select 
    a.id_addr
    , 'N'
    , 'Not in Neigborhood'
from address a 
     left join temp_neighborhood aa 
          on aa.id_addr = a.id_addr 
where aa.id_addr is null  
;

select 
  to_char(count(*),'999,999,999,999') all_rows_before
  , to_char(count(case when nbhd_name != 'Not in Neigborhood' 
                       then 1
                       else null 
                       end),'999,999,999,999') as address_with_NbHood_before
  , to_char(count(case when nbhd_name = 'Not in Neigborhood' 
                       then 1
                       else null 
                       end),'999,999,999,999') as address_with_out_NbHood_before
from address_neighborhood
;




--*******************************************
--ver 1: SDO_RELATE 
--runtime: 49/51/73 seconds (multiple runtime)
--********************************************
declare
  type ntt is table of address_neighborhood_abdi%rowtype; --change to after test: address_neighborhood
  l_rows  ntt;
  l_own   varchar2(30) := 'aijibril';                     --remove after test
  l_tab   varchar2(30) := 'address_neighborhood_abdi';    --change to after test: address_neighborhood
cursor l_cur is
with temp_addr
as(select a.id_addr, a.geo_location 
  from address a 
  where a.code_addr_stat = 'C'                            --only add neighborhood for valid address. 
)
,temp_valid_nbr
as(select 
    a.id_addr
    , 'N' as code_geo_type
    , case 
          when jb.nbhd_name is not null
          then jb.nbhd_name
          else 'Not in Neigborhood'
          end as nbhd_name
    , a.geo_location.sdo_point.X as longitute
    , a.geo_location.sdo_point.Y as latitude 
  from temp_addr a
       , qrydbo.pd_stg_geo_nbhd jb
  where SDO_RELATE(a.geo_location, jb.Geom, 'mask=inside') = 'TRUE' --A.geo_location (point) is INSIDE jb.geom spatial object 
)
select 
    id_addr
    , code_geo_type
    , nbhd_name
    , longitute
    , latitude  
from temp_valid_nbr
union 
select 
    a.id_addr
    , 'N'
    , 'Not in Neigborhood'
    , null 
    , null 
from address a 
     left join temp_valid_nbr aa 
          on aa.id_addr = a.id_addr 
where aa.id_addr is null  
;

begin
  execute immediate 'truncate table ' || l_own || '.' || l_tab;
  open l_cur;
  loop
    fetch l_cur bulk collect into l_rows limit 5000;
      forall i in 1..l_rows.count
        insert into aijibril.address_neighborhood_abdi values l_rows(i);
      exit when l_rows.count < 5000;
  end loop;
  commit;
  close l_cur;
exception
  when others then raise; 
end;
/
 
--51/73 seconds (with union bad address  


select  count(*) from ADDRESS_NEIGHBORHOOD_ABDI a where a.nbhd_name != 'Not in Neigborhood';--40343
select * from ADDRESS_NEIGHBORHOOD_ABDI;

select * from address id where id.id_addr = 1000002049;
select count(*) from address; --4,072,989  



--*****************************************************
--ver 2: SDO_INSIDE
--runtime: 2 hours and still was not finished 
--******************************************************
declare
  type ntt is table of address_neighborhood_abdi%rowtype; --change to after test: address_neighborhood
  l_rows  ntt;
  l_own   varchar2(30) := 'aijibril';                     --remove after test
  l_tab   varchar2(30) := 'address_neighborhood_abdi';    --change to after test: address_neighborhood
cursor l_cur is
with temp_addr
as(select a.id_addr, a.geo_location 
  from address a 
  where a.code_addr_stat = 'C'
)
,temp_valid_nbr
as(select 
    a.id_addr
    , 'N' as code_geo_type
    , case 
          when jb.nbhd_name is not null
          then jb.nbhd_name
          else 'Not in Neigborhood'
          end as nbhd_name
    , a.geo_location.sdo_point.X as longitute
    , a.geo_location.sdo_point.Y as latitude 
  from temp_addr a
       left join qrydbo.pd_stg_geo_nbhd jb 
            on sdo_inside(a.geo_location, jb.geom) = 'TRUE'
)
select 
    id_addr
    , code_geo_type
    , nbhd_name
    , longitute
    , latitude  
from temp_valid_nbr
union all
select 
    a.id_addr
    , 'N'
    , 'Not in Neigborhood'
    , null 
    , null 
from address a 
     left join temp_valid_nbr aa 
          on aa.id_addr = a.id_addr 
where aa.id_addr is null  
;

begin
  execute immediate 'truncate table ' || l_own || '.' || l_tab;
  open l_cur;
  loop
    fetch l_cur bulk collect into l_rows limit 5000;
      forall i in 1..l_rows.count
        insert into aijibril.address_neighborhood_abdi values l_rows(i);
      exit when l_rows.count < 5000;
  end loop;
  commit;
  close l_cur;
exception
  when others then raise; 
end;
/


select count(distinct id_addr), count(*) from ADDRESS_NEIGHBORHOOD_ABDI a where a.nbhd_name != 'Not in Neigborhood';--40343
select count(distinct id_addr), count(*) from ADDRESS_NEIGHBORHOOD_ABDI a where a.nbhd_name = 'Not in Neigborhood';--40343

select * from address id where id.id_addr = 1000002049;


--*******************************************************
--ver 3A 
--Direct insert version with SDO_INSIDE 
--runtime: 30min and did not finish before I stopped. 
--******************************************************

insert into aijibril.address_neighborhood_mike
with temp_addr
as(select a.id_addr, a.geo_location 
  from address a 
  where a.code_addr_stat = 'C'
)
,temp_valid_nbr
as(select 
    a.id_addr
    , 'N' as code_geo_type
    , case 
          when jb.nbhd_name is not null
          then jb.nbhd_name
          else 'Not in Neigborhood'
          end as nbhd_name
    , a.geo_location.sdo_point.X as longitute
    , a.geo_location.sdo_point.Y as latitude 
  from temp_addr a
       left join qrydbo.pd_stg_geo_nbhd jb 
            on sdo_inside(a.geo_location, jb.geom) = 'TRUE'
)
select 
    id_addr
    , code_geo_type
    , nbhd_name
    , longitute
    , latitude  
from temp_valid_nbr
union all
select 
    a.id_addr
    , 'N'
    , 'Not in Neigborhood'
    , null 
    , null 
from address a 
     left join temp_valid_nbr aa 
          on aa.id_addr = a.id_addr 
where aa.id_addr is null  
;

--************************************************
-- version 3B: direct insert into  
-- With SDO_inside  
-- Runtime: --39 seconds --xx Minutes
--************************************************
exec qrydbo.trunc_tab('address_neighborhood');
truncate table address_neighborhood;
select * from address_neighborhood;

--insert statement 
insert into address_neighborhood
with temp_addr
as(select a.id_addr, a.geo_location 
  from address a 
  where a.code_addr_stat = 'C'                           
)
,temp_valid_nbr
as(select  /*+ ORDERED */
    a.id_addr
    , 'N' as code_geo_type
    , jb.nbhd_name
    from qrydbo.pd_stg_geo_nbhd jb 
       , temp_addr a
    where SDO_INSIDE(a.geo_location, jb.Geom) = 'TRUE' --A.geo_location (point) is INSIDE jb.geom spatial object 
)select count(*) from temp_valid_nbr;
select 
  id_addr
  , code_geo_type
  , nbhd_name
from temp_valid_nbr
union 
select 
  a.id_addr
  , 'N'
  , 'Not in Neigborhood'
from address a 
     left join temp_valid_nbr aa 
          on aa.id_addr = a.id_addr 
where aa.id_addr is null  
;


select 
    to_char(count(*),'999,999,999,999') nbr_rows_after 
    , to_char(count(case when nbhd_name != 'Not in Neigborhood' 
                         then 1
                         else null 
                         end)
                         ,'999,999,999,999') as address_with_NBHood_after
     , to_char(count(case when nbhd_name = 'Not in Neigborhood' 
                          then 1
                          else null 
                          end)
                          ,'999,999,999,999') as address_with_out_NBHood_after
from address_neighborhood
;
--NBR_ROWS_AFTER  	ADDRESS_WITH_NBH	ADDRESS_WITH_OUT
----------------	----------------	----------------
-- 4,073,700	          40,351	       4,033,349

--end copy/past 



--************************************************
-- version 4: direct insert into  
-- With SDO_RELATE 
-- Runtime: 50 --38 --xx seconds
--************************************************
select count(*) as address_neighborhood_before from address_neighborhood; 

--truncate table qrydbo.ADDRESS_NEIGHBORHOOD;  --insufficient privileges
exec qrydbo.trunc_tab('ADDRESS_NEIGHBORHOOD');

insert into address_neighborhood
with temp_addr
as(select a.id_addr, a.geo_location 
  from address a 
  where a.code_addr_stat = 'C'                            --only add neighborhood for valid address. 
)
,temp_valid_nbr
as(select 
    a.id_addr
    , 'N' as code_geo_type
    , case 
          when jb.nbhd_name is not null
          then jb.nbhd_name
          else 'Not in Neigborhood'
          end as nbhd_name
    --, a.geo_location.sdo_point.X as longitute
    --, a.geo_location.sdo_point.Y as latitude 
  from temp_addr a
       , qrydbo.pd_stg_geo_nbhd jb
  where SDO_RELATE(a.geo_location, jb.Geom, 'mask=inside') = 'TRUE' --A.geo_location (point) is INSIDE jb.geom spatial object 
)
select 
    id_addr
    , code_geo_type
    , nbhd_name
    --, longitute
    --, latitude  
from temp_valid_nbr
union 
select 
    a.id_addr
    , 'N'
    , 'Not in Neigborhood'
    --, null 
    --, null 
from address a 
     left join temp_valid_nbr aa 
          on aa.id_addr = a.id_addr 
where aa.id_addr is null  
;

select count(*) as address_neighborhood_all from address_neighborhood; --4073700
select count(*) as address_with_NBHood_after from address_neighborhood  a where a.nbhd_name != 'Not in Neigborhood';--40351
select count(*) as address_without_NBHood_after from address_neighborhood  a where a.nbhd_name = 'Not in Neigborhood';--4033349


--start 
--************************************************
-- version 4B: direct insert into  
-- With SDO_RELATE 
-- Runtime:--38 --xx seconds
--************************************************
--truncate table qrydbo.ADDRESS_NEIGHBORHOOD;  --insufficient privileges
exec qrydbo.trunc_tab('ADDRESS_NEIGHBORHOOD');

insert into address_neighborhood
with temp_addr
as(select a.id_addr, a.geo_location 
  from address a 
  where a.code_addr_stat = 'C'                           
)
,temp_valid_nbr
as(select 
    a.id_addr
    , 'N' as code_geo_type
    , jb.nbhd_name
    --, a.geo_location.sdo_point.X as longitute
    --, a.geo_location.sdo_point.Y as latitude 
    from temp_addr a
       , qrydbo.pd_stg_geo_nbhd jb
    where SDO_RELATE(a.geo_location, jb.Geom, 'mask=inside') = 'TRUE' --A.geo_location (point) is INSIDE jb.geom spatial object 
)
select 
  id_addr
  , code_geo_type
  , nbhd_name
  --, longitute
  --, latitude  
from temp_valid_nbr
union 
select 
  a.id_addr
  , 'N'
  , 'Not in Neigborhood'
  --, null 
  --, null 
from address a 
     left join temp_valid_nbr aa 
          on aa.id_addr = a.id_addr 
where aa.id_addr is null  
;

select 
    to_char(count(*),'999,999,999,999') nbr_rows_after 
    , to_char(count(case when nbhd_name != 'Not in Neigborhood' 
                         then 1
                         else null 
                         end)
                         ,'999,999,999,999') as address_with_NBHood_after
     , to_char(count(case when nbhd_name = 'Not in Neigborhood' 
                          then 1
                          else null 
                          end)
                          ,'999,999,999,999') as address_with_out_NBHood_after
from address_neighborhood
;

 

--**********************************************************
-- sdo_inside
--runtime: 16 hours & was still running before been stopped. 
--**********************************************************
--truncate table qrydbo.ADDRESS_NEIGHBORHOOD;  --insufficient privileges
exec qrydbo.trunc_tab('ADDRESS_NEIGHBORHOOD');

insert into address_neighborhood
with temp_addr
as(select a.id_addr, a.geo_location 
  from address a 
  where a.code_addr_stat = 'C'
)
SELECT id_addr
       , 'N' AS code_geo_type
       , CASE WHEN jb.nbhd_name IS NOT NULL
              THEN jb.nbhd_name
              ELSE 'Not in Neigborhood'
              END AS nbhd_name
FROM address a
     LEFT JOIN qrydbo.pd_stg_geo_nbhd jb
          ON sdo_inside(a.geo_location,jb.geom) = 'TRUE'
;





--helpers

--option 1
WITH src AS (SELECT id_addr, jb.nbhd_name 
              FROM qrydbo.pd_stg_geo_nbhd jb
                   JOIN address a ON 1=1
              WHERE sdo_inside(a.geo_location,jb.geom) = 'TRUE'
              )
SELECT id_addr, 'N' AS code_geo_type, nbhd_name
FROM src
WHERE id_addr = 1014045807
UNION ALL
SELECT id_addr, 'N' as code_geo_type, 'Not in Neighborhood' AS nbhd_name
FROM address a
WHERE 1=1
AND id_addr = 1014045807
AND NOT EXISTS (SELECT 'x' FROM src s WHERE s.id_addr = a.id_addr);

--option 2
SELECT id_addr, 'N' AS code_geo_type , CASE WHEN jb.nbhd_name IS NOT NULL
                                                 THEN jb.nbhd_name
                                                 ELSE 'Not in Neigborhood'
                                                 END AS nbhd_name
              FROM address a
                   LEFT JOIN qrydbo.pd_stg_geo_nbhd jb ON sdo_inside(a.geo_location,jb.geom) = 'TRUE'
              --WHERE id_addr = 1014045807
;



--*****************************************************
--compare sdo_inside vs. sdo_relate 
--*****************************************************
SELECT count(distinct id_addr) cnt_unique, count(*) count_all 
FROM qrydbo.pd_stg_geo_nbhd jb
     JOIN address a ON 1=1
WHERE sdo_inside(a.geo_location,jb.geom) = 'TRUE'
AND a.code_addr_stat = 'C'
;--40351
--runtime: 5.89

SELECT count(distinct id_addr) cnt_unique, count(*) count_all 
FROM qrydbo.pd_stg_geo_nbhd jb
     , address a  
WHERE sdo_relate(a.geo_location,jb.geom, 'mask=inside') = 'TRUE'
AND a.code_addr_stat = 'C'
; --40351 --runtime: 5.89



