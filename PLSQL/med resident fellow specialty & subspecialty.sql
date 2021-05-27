-- 4 yr MD/Resident/Fellowship with  a)specialty b)subspecialty c)residency info
drop table txxxxxxxxxa; 
create table txxxxxxxxxa as 
with temp_pool as 
(
    select distinct 
           a.id_demo 
           , a.code_degree 
           , dd.desc_degree 
           , ms.code_unit_spec 
           , us.desc_unit as specialty 
           , ms.code_unit_sub_spec
           , ub.desc_unit as sub_specialty  
           , a.year_grad 
           , decode(mr.code_med_resident_type, 'R','Y','N') is_med_residency 
           , decode(mr.code_med_resident_type, 'F','Y','N') is_med_fellowship 
    from q_academic a 
         left join med_specialty ms on ms.id_demo = a.id_demo 
         left join decode_unit us on us.code_unit = ms.code_unit_spec and us.code_unit_type = 'SPEC'
         left join decode_unit ub on ub.code_unit = ms.code_unit_sub_spec  and ub.code_unit_type = 'SSPC'
         left join med_resident md on md.id_demo = a.id_demo 
         left join decode_med_resident mr on mr.code_med_resident = md.code_med_resident 
         join decode_degree dd on dd.code_degree = a.code_degree 
    where a.code_clg_query = 'MED'
    and a.code_degree IN ('RES','FEL', '402'/*,'602'*/)
    and a.year_grad = 2014
  ),
temp_unique as 
(select distinct 
        p.id_demo
        , nvl2(ad.id_demo,'Y','N') has_current_mn_addr
 from temp_pool p 
      left join address ad on ad.id_demo = p.id_demo 
                           and ad.code_addr_stat = 'C'
),
temp_specialty as 
( select id_demo 
           , listagg(specialty, '; ')within group (order by specialty asc)as  specialty_list 
    from(select distinct 
                id_demo
                , specialty 
         from temp_pool 
         where specialty is not null 
        ) 
    group by id_demo              
),
temp_sub_specialty as 
(select id_demo 
           , listagg(sub_specialty, '; ')within group (order by sub_specialty asc)as sub_specialty_list 
    from(select distinct 
                id_demo 
                , sub_specialty 
         from temp_pool 
         where sub_specialty is not null 
        ) 
    group by id_demo 
),
temp_degree as 
( select id_demo 
         , year_grad 
         , listagg(desc_degree||'('||code_degree||')', '; ')within group (order by null) as degree_list 
   from(select distinct 
                id_demo 
                , code_degree 
                , desc_degree  
                , year_grad
         from temp_pool 
        ) 
    group by id_demo
             , year_grad
   )
select distinct
        tu.id_demo 
        , i.id_psoft as emplID 
        , namer.indv_addressee(i.id_demo) as addressee 
        , tp5.degree_list
        , tp5.year_grad 
        , tp1.is_med_residency
        , tp2.is_med_fellowship 
        , tp3.specialty_list  
        , tp4.sub_specialty_list  
        , tu.has_current_mn_addr
from temp_unique tu 
      join q_individual i on i.id_demo = tu.id_demo 
      left join temp_pool tp1 on tp1.id_demo = tu.id_demo and tp1.is_med_residency = 'Y'
      left join temp_pool tp2 on tp2.id_demo = tu.id_demo and tp2.is_med_fellowship = 'Y'
      left join temp_specialty tp3 on tp3.id_demo = tu.id_demo 
      left join temp_sub_specialty tp4 on tp4.id_demo = tu.id_demo
      join temp_degree tp5 on tp5.id_demo = tu.id_demo 
where i.year_death is null 
;

select count(*),count(distinct id_demo) cnt_uniqe from txxxxxxxxxa;--523
select id_demo, count(*) from txxxxxxxxxa group by id_demo having count(*)>1;
select * from txxxxxxxxxa;

