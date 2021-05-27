exec qryadm.radius_addr_finder('53703', 100, 't999999999_aa') ;
select *from t999999999_aa;
 

drop table t999999999_bb; 
create table t999999999_bb as 
select w.id_demo, i.state, i.city, i.zip_code, ad.geo_location --1. Search field: temp_alums.geo_Location 
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
       join t999999999_aa aa
            on aa.id_addr = ad.id_addr 
    where 1=1 
    and ad.geo_location is not null 
    and i.year_death is null 
    and i.code_addr_stat = 'C'
    and i.code_anon in ('0','1')
    and lower(ad.error_string) = 'no error' 
;

select * from t999999999_bb;--192
select * from t999999999_a;--190