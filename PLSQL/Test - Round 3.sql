--create table re_gains_into_test as 
--select * from re_gains_into_test;
drop table prospect_diff;
create table prospect_diff as
with temp_prod
as (
    select distinct id.id_demo_master as id_prospect_master
                    , p.id_demo_mgr
                    , p.manager_name
                  
                    --, count (distinct id.id_demo_master) as nbr_pros_prod
    from q_prospect p 
    join q_id@test id 
         on id.id_demo = p.id_prospect_master
    where p.code_stage in (3,4,5)
    /*group by p.id_demo_mgr
           , p.manager_name*/
    order by 2
    )
, temp_re 
as (
    select distinct id.id_demo_master as id_prospect_master
                    , x2.id_demo as id_demo_mgr
                    , namer.label(x2.id_demo) as manager_name
                  
    from dbo_re7.RECORDs@test r 
    join dbo_re7.constit_solicitors@test cs 
         on cs.constit_id = r.id
    join mmf_xref_upload x 
         on x.id_mmf = r.constituent_id
    join q_id@test id 
         on id.id_demo = x.id_demo
    join dbo_re7.records@test r2 
         on r2.id = cs.solicitor_id
    join mmf_xref_upload x2 
         on x2.id_mmf = r2.constituent_id
    where cs.solicitor_type in (18443, 18905)
    and not exists (select 'x' from temp_prod t 
                    where t.id_prospect_master = id.id_demo_master
                    and t.id_demo_mgr = x2.id_demo
                    )
    order by 2
    )
, temp_test
as (
    select distinct p.id_prospect_master 
                    , p.id_demo_mgr
                    , p.manager_name
                  
                    --, count (distinct p.id_prospect_master) as nbr_pros_test
    from q_prospect@test p 
    /*group by p.id_demo_mgr
           , p.manager_name*/
    order by 2
    )
select t.id_demo_mgr
       , t.manager_name
       , count(distinct p.id_prospect_master) as nbr_pros_dms
       , count(distinct r.id_prospect_master) as nbr_pros_re_remainder
       , count(distinct t.id_prospect_master) as nbr_pros_test
       , count(distinct t.id_prospect_master) - count(distinct p.id_prospect_master) - count(distinct r.id_prospect_master) as diff
       /*, nvl(p.nbr_pros_prod,0) as nbr_pros_prod
       , nvl(r.nbr_pros_re,0) as nbr_pros_re
       , t.nbr_pros_test
       , t.nbr_pros_test - nvl(p.nbr_pros_prod,0) -nvl(r.nbr_pros_re,0) as diff*/
from temp_test t 
full outer join temp_prod p 
     on p.id_demo_mgr = t.id_demo_mgr
full outer join temp_re r
     on r.id_demo_mgr = t.id_demo_mgr
group by t.id_demo_mgr
       , t.manager_name
order by 6
;
--table to use for the Med Health Test
select * from prospect_diff d
WHERE NOT EXISTS (SELECT 'x' FROM RE_medHealth_mgr re 
              WHERE re.id_demo_mgr = d.id_demo_mgr
              ) 

/

PROMPT ********************* LOSSES *********************
--Find missing entities from production (net negative)
select id_demo_master
from(
    select id.id_demo_master
    from q_prospect p
                join q_id@test id on p.id_prospect_master = id.id_demo
    where code_stage in (3,4,5)
    and id_demo_mgr = 400008043

    union
    select id.id_demo_master as id_prospect_master
        from dbo_re7.RECORDs@test r 
        join dbo_re7.constit_solicitors@test cs 
             on cs.constit_id = r.id
        join mmf_xref_upload x 
             on x.id_mmf = r.constituent_id
        join q_id@test id 
             on id.id_demo = x.id_demo
        join dbo_re7.records@test r2 
             on r2.id = cs.solicitor_id
        join mmf_xref_upload x2 
             on x2.id_mmf = r2.constituent_id
        where cs.solicitor_type in (18443, 18905)
        and x2.id_demo = 400008043
    )
minus
select id_prospect_master from q_prospect@test
where id_demo_mgr = 400008043 
;

--helpers to diagnose the disparity
select * from q_prospect where id_prospect_master = 100085107 AND id_demo_mgr= 140612427;
select * from q_prospect@test where id_prospect_master = 100085107  AND id_demo_mgr= 140612427;
select * from manager_assign where id_prospect_master = 100085107  AND id_demo_mgr= 140612427;
select * from manager_assign_history@prod2 where id_prospect_master = 100085107  AND id_demo_mgr= 140612427;




PROMPT ******************* GAINS *************************

select distinct id_prospect_master from q_prospect@test
where id_demo_mgr = 400008043
minus
select id_demo_master
from(
    select id.id_demo_master
    from q_prospect p
                join q_id@test id on p.id_prospect_master = id.id_demo
    where code_stage in (3,4,5)
    and id_demo_mgr = 400008043
    union
    select id.id_demo_master as id_prospect_master
        from dbo_re7.RECORDs@test r 
        join dbo_re7.constit_solicitors@test cs 
             on cs.constit_id = r.id
        join mmf_xref_upload x 
             on x.id_mmf = r.constituent_id
        join q_id@test id 
             on id.id_demo = x.id_demo
        join dbo_re7.records@test r2 
             on r2.id = cs.solicitor_id
        join mmf_xref_upload x2 
             on x2.id_mmf = r2.constituent_id
        where cs.solicitor_type in (18443, 18905)
        and x2.id_demo = 400008043
    )
;


--helpers to diagnose the disparity
select * from q_prospect where id_prospect_master in( 500227568) AND id_demo_mgr= 140590872;
select * from q_prospect@test where id_prospect_master in( 500227568) AND id_demo_mgr= 140590872;
select * from manager_assign where id_prospect_master in( 500227568) AND id_demo_mgr= 140590872;
select * from manager_assign_history@prod2 where id_prospect_master in( 500227568) AND id_demo_mgr= 140590872;












--used this snippit with the above temp tables to determine if there were any managers in production/re who are NOT in the test instance
--returned no results
select distinct p.id_demo_mgr 
from(
     select p.id_demo_mgr
     from temp_prod p 
     union
     select r.id_demo_mgr
     from temp_re r 
     ) p 
where not exists (select 'x' from temp_test t 
                  where t.id_demo_mgr = p.id_demo_mgr
                  )
/

--RE Med Health Managers
CREATE TABLE RE_medHealth_mgr AS 
select DISTINCT      x2.id_demo as id_demo_mgr
                    , namer.label(x2.id_demo) as manager_name
    from dbo_re7.RECORDs@test r 
    join dbo_re7.constit_solicitors@test cs 
         on cs.constit_id = r.id
    join mmf_xref_upload x 
         on x.id_mmf = r.constituent_id
    join q_id@test id 
         on id.id_demo = x.id_demo
    join dbo_re7.records@test r2 
         on r2.id = cs.solicitor_id
    join mmf_xref_upload x2 
         on x2.id_mmf = r2.constituent_id
    where cs.solicitor_type in (18443, 18905)
    /
    
    SELECT * FROM RE_medHealth_mgr;
    
    -- code helper
    SELECT *FROM decode_stage@test;
    SELECT * from discovery_vq@test v WHERE v.id_prospect_master = 800474905;
   
   
