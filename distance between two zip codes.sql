with temp_alums                                     
as(
    select geo_location as geo                                           --1. Search field: temp_alums.geo_Location 
    from cbsa_county
    where zipcode in ('55118')   
    and primaryrecord = 'P'
)
, temp_events                                                            --2. Query window --reference point  
as(select geo_location as geo
   from cbsa_county
   where zipcode in ('98104')   
   and primaryrecord = 'P'
)
select /* Leading(a2) */
    mdsys.sdo_geom.sdo_distance(a1.geo, a2.geo, 0.0000000005, 'unit=mile') as distance_miles
from temp_alums a1 
     , temp_events a2 
;