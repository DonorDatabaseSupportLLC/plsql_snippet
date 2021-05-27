CREATE OR REPLACE PROCEDURE radius_zip_finder
             (zip_code_in  IN varchar2,
             	radius_in    IN number,
              table_zip    IN varchar2
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
-- Abdi Jibril 		1-Jan-2019      Created/New
--
-----------------------------------------------------------------------------

table_out varchar2(100) := ' '||user || '.'|| table_zip||' ';
vquery1 varchar2(32245) :=
'Create table '|| table_out || ' as
with
	 temp_point_a as(select w.*
   								 from(
                        select ad.id_addr, ad.geo_location
                        from address ad
                        where ad.code_addr_stat = ''C''
                        and trim(ad.zip_code) =  '|| ''''||zip_code_in||'''' ||
                        'and ad.geo_location is not null
                        and lower(ad.error_string) = ''no error''
                       )w
                   where rownum = 1
                  )
  select /*+ ordered no_index(a2 zip_code) */
       distinct a2.zip_code
  from address a2
  where 1=1
  and a2.code_addr_stat = ''C''
  and a2.code_country = ''USA''
  and trim(a2.zip_code) is not null
  and a2.geo_location is not null
  and lower(a2.error_string) = ''no error''
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
      where table_name = upper(table_zip);

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
END radius_zip_finder
;
