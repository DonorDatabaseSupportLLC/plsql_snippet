CREATE OR REPLACE PROCEDURE "RADIUS_ADDR_FINDER"
(zip_code_in  IN varchar2,
 radius_in    IN number,
 table_ids    IN varchar2
)

AUTHID current_user
   IS
--
-- Purpose: Find zip code of certain radius
--
-- MODIFICATION HISTORY
-----------------------------------------------------------------------------
-- Person           Date          Comments
-----------------------------------------------------------------------------
-- Abdi Jibril     1-May-2019      Created/New
--
-----------------------------------------------------------------------------

table_out varchar2(100) := ' '||user || '.'|| table_ids||' ';
vquery1 varchar2(32245) :=
'Create table '|| table_out || ' as
with temp_point_a
as(select w.*
   from(
      select geo_location
      from cbsa_county
      where primaryrecord = ''P''
      and zipcode =  '|| ''''||zip_code_in||'''' ||
      '
     )w
  where rownum = 1
)
select /*+ ordered no_index(a2 zip_code) */
     distinct a2.id_addr
from address a2
     join q_individual i
          on i.id_demo = a2.id_demo
          and i.id_pref_addr = a2.id_addr
where 1=1
and a2.code_addr_stat = ''C''
and a2.code_country = ''USA''
and trim(a2.zip_code) is not null
and a2.geo_location is not null
and lower(a2.error_string) = ''no error''
and i.year_death is null
and sdo_within_distance (a2.geo_location
                         , (select a1.geo_location from temp_point_a a1)
                         , ''distance=' ||' '||radius_in||' ' ||'unit=mile''
                         ) = ''TRUE''
union
select /*+ ordered no_index(a2 zip_code) */
     distinct a2.id_addr
from address a2
     join q_organization i
          on i.id_demo = a2.id_demo
          and i.id_pref_addr = a2.id_addr
where 1=1
and a2.code_addr_stat = ''C''
and a2.code_country = ''USA''
and trim(a2.zip_code) is not null
and a2.geo_location is not null
and lower(a2.error_string) = ''no error''
and i.year_oob is null
and sdo_within_distance (a2.geo_location
                         , (select a1.geo_location from temp_point_a a1)
                         , ''distance=' ||' '||radius_in||' ' ||'unit=mile''
                         ) = ''TRUE''
              '
  ;

cursor addr_zipcode
    is
      select table_name
      from user_tables
      where table_name = upper(table_ids);

BEGIN

  --if table already exists, drop it
  for rec in addr_zipcode loop
      if rec.table_name is not null then
            execute immediate 'DROP TABLE '||rec.table_name;
      end if;
  end loop;

-- if table does not exist, create
execute immediate vquery1;

EXCEPTION
    WHEN others THEN
        raise ;
END radius_addr_finder
;
