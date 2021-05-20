--fnd_pd_neighborhood.sql
--completion/failure     : batchman email
--Frequency              : xxx
-- What day of the week  : xxx
--Dependencies           : spatial table in qrydbo.pd_stg_geo_nbhd
--Tables (Dependencies)  : none
--Original Query Name    : xxx

--Modifications
--------------   ------------------     ----------------------------------------
--Date           Name                   Descritpions
-------------    ------------------     ----------------------------------------
--20-Jun-2019    Abdi            Created

--******************************************************************************


SELECT TO_CHAR(COUNT(*),'999,999,999') nbr_rows_before FROM address_neighborhood;

--*******************************************
--ver 1: SDO_RELATE 
--runtime: 51 sec?
--********************************************
--DROP TABLE ADDRESS_NEIGHBORHOOD_ABDI;
--CREATE TABLE ADDRESS_NEIGHBORHOOD_ABDI AS 
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
 
--51 seconds (with union bad address  


select count(distinct id_addr), count(*) from ADDRESS_NEIGHBORHOOD_ABDI a where a.nbhd_name != 'Not in Neigborhood';--40,334
select * from ADDRESS_NEIGHBORHOOD_ABDI;

select * from address id where id.id_addr = 1000002049;
select count(*) from address; --4,072,989  



--******************************************
--find relationship between objects 
--******************************************
--drop table test_sdo_relate;
--create table test_sdo_relate as 
with temp_addr
as(select a.id_addr, a.geo_location 
  from address a 
  where a.code_addr_stat = 'C'
)
,temp_valid_nbr
as(select 
    a.id_addr
    , jb.nbhd_name
    , SDO_GEOM.RELATE(a.geo_location, 'determine', jb.Geom, 0.005) as relationship
  from temp_addr a
       , qrydbo.pd_stg_geo_nbhd jb
  --where SDO_RELATE(a.geo_location, jb.Geom, 'mask=inside') = 'TRUE' --A.geo_location (point) is INSIDE jb.geom spatial object 
)
select 
    
    relationship  
    --, count(*) as cnt_all 
    --, count(distinct id_addr) as cnt_unique 
from temp_valid_nbr
where relationship = 'INSIDE' 
--group by relationship
;


--*******************************************
--ver 2: SDO_INSIDE
--runtime: xx sec?
--********************************************
--DROP TABLE ADDRESS_NEIGHBORHOOD_ABDI;
--CREATE TABLE ADDRESS_NEIGHBORHOOD_ABDI AS 
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
 
--51 seconds (with union bad address  
--06 seconds (without union - no bad address)

select count(distinct id_addr), count(*) from ADDRESS_NEIGHBORHOOD_ABDI a where a.nbhd_name != 'Not in Neigborhood';--40336
select count(distinct id_addr), count(*) from ADDRESS_NEIGHBORHOOD_ABDI a where a.nbhd_name = 'Not in Neigborhood';--40336

select * from address id where id.id_addr = 1000002049;





--helpers



/*+ ORDERED */


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
              WHERE id_addr = 1014045807
;


--helpers
SELECT *
FROM decode_geo_type;

SELECT *
FROM q_individual WHERE id_psoft = '2104185'
;

SELECT nbhd_name 
FROM qrydbo.pd_stg_geo_nbhd
;

SELECT *
FROM address_geo