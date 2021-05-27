CREATE OR REPLACE PROCEDURE aijibril.gir_abdi
   ( param1 IN varchar2,
     param2 IN varchar2 )
AUTHID current_user
   IS
--
-- To modify this template, edit file PROC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the procedure
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  -------------------------------------------
--  QTeam      1-Feb-2017  Initial build for new GIR for QTeam
-- variable_name                 datatype;
   -- Declare program variables as shown above
   table_in varchar2(100) := ' '||user || '.'|| param1||' ';
   table_out varchar2(100) := ' '||user || '.'|| param2||' ';
   vquery1 varchar2(32245) :=
   'create table '|| table_out ||' as
with
-- ********************************************************** 
         --1. Expectancy info  --
-- **********************************************************
temp_exp as
(
select
  a.id_demo
, sum(case when e.code_exp_type not in ('||'''PL'''||','||'''MT'''||','||'''MR'''||')
                and
                e.code_anon < '||'''2'''||'
           then e.amt_fund
           else 0
           end) total_deferred
, sum(case when e.code_exp_type not in ('||'''PL'''||','||'''MT'''||','||'''MR'''||')
                and
                e.code_anon < '||'''2'''||'
           then e.amt_fund_out
           else 0
           end) total_deferred_out
, sum(case when e.code_exp_type = '||'''PL'''||'
                and
                e.code_anon < '||'''2'''||'
           then e.amt_fund
           else 0
           end) total_pledges
, sum(case when e.code_exp_type = '||'''PL'''||'
                and
                e.code_anon < '||'''2'''||'
           then e.amt_fund_out
           else 0
           end) total_pledges_out
from q_expectancy_id e
join '|| table_in ||' a on a.id_demo = e.id_demo
where e.code_recipient != '||'''S'''||'
group by
  a.id_demo
)
, temp_id_hh as
(
select
  j.id_demo
, i_info.id_hh(j.id_demo) id_house
from
  '|| table_in ||' j
)
-- ********************************************************** 
         --2. Academic info  --
-- **********************************************************
, temp_acad as
(
select
  c.id_demo
, dc.desc_campus||''(''||c.code_campus||'')'' as Desc_campus
, cc.code_clg||''(''|| c.code_unit ||'')'' as code_clg
, dmm.desc_major_minor_long ||''(''|| c.code_major||'')'' as desc_major_minor
, dd.desc_degree ||''(''||c.code_degree||'')'' as desc_degree
, c.year_grad
, c.year_reunion
, rank() over(partition by c.id_demo
              order by c.year_grad desc, rownum
              ) rank_grad_year
from
  (
    select
      distinct
      a.id_demo
    , b.code_campus
    , b.code_unit
    , b.code_major
    , b.code_degree
    , b.year_grad
    , b.year_reunion
    from q_academic b
      join '|| table_in ||' a on a.id_demo = b.id_demo
  ) c
JOIN decode_major_minor dmm on dmm.code_major_minor = c.code_major
JOIN decode_campus  dc on dc.code_campus = c.code_campus
JOIN decode_degree dd on dd.code_degree = c.code_degree
JOIN decode_clg cc on cc.code_unit = c.code_unit
)
-- ********************************************************** 
               --3. Gift info  --
-- **********************************************************
, temp_gift as
(
select
  c.*
, rank() over(partition by c.id_house
              order by c.amt_clg desc, rownum
              ) rank_clg_total_gifts
from
  (
    select
      b.id_house
    , b.code_clg
    , sum(case when b.code_exp_type not in ('||'''MT'''||','||'''MR'''||')
                 then 1
                 else 0
                 end) nbr_gifts
    , max(case when b.code_exp_type not in ('||'''MT'''||','||'''MR'''||')
               then b.date_tran
               else null
               end) date_lgift
    , sum(b.amt_fund) amt_clg
    from
        (
          select
          distinct
          i_info.id_hh(a.id_demo) id_house
        , p.id_gift
        , p.nbr_fund
        , p.code_pmt_form
        , p.code_clg
        , p.date_tran
        , p.code_exp_type
        , p.amt_fund
        from q_production_id p
          join '|| table_in ||' a on p.id_demo in (a.id_demo,i_info.id_spouse(a.id_demo))
        and p.code_anon < '||'''2'''||'
        and p.code_recipient != '||'''S'''||'
        ) b
    group by
      b.id_house
    , b.code_clg
  ) c
)
select
  g.id_demo
, i_info.id_hh(g.id_demo) id_household
, i.name_last
, (select n.name_last from names n where n.id_demo = g.id_demo and n.code_name_type = '||'''M'''||' and n.code_name_stat = '||'''C'''||') name_maiden
, i.name_first
, i.name_middle
, case when g.id_demo  < 900000000
       then i.name_label
       else null
       end name_label
, i.id_spouse
, namer.first(i.id_spouse) name_first_spouse
, namer.middle(i.id_spouse) name_middle_spouse
, namer.last(i.id_spouse) name_last_spouse
, namer.label(i.id_spouse) name_label_spouse
, i_info.age2(i.id_spouse) age_spouse
, i_info.date_death(i.id_spouse) date_death_spouse
, i.name_label_comb
, '||''' '''||' name_org
, '||''' '''||' desc_org_type
, i.code_sex code_gender
, i.flag_alumni
, i.code_staff
--, substr(i.code_maa_type,1,1) maa_stat
, i.code_member_status maa_stat
, i.code_anon code_anon_donor
, i.id_pref_empl id_employer
, i_info.employment(g.id_demo) name_employer
, i.code_job_title
, (select djt.desc_job_title from decode_job_title djt where djt.code_job_title = i.code_job_title) desc_job_title
, nvl(prospect.name_mgr(g.id_demo),'||'''NO PRIMARY MGR'''||') contact_manager
, i.attention
, i.street_1
, i.street_2
, i.street_3
, i.city
, i.state
, addr.country_desc(i.code_country) country
, geo_fun.id_addr_cbsa(i.id_pref_addr) code_cbsa
, geo_fun.geo_desc(geo_fun.id_addr_cbsa(i.id_pref_addr)) desc_cbsa
, i.zip_code
, i.zip_ext
, i.nbr_area_code
, i.nbr_phone
, i.nbr_ext
, i_info.age2(i.id_demo) age
, i_info.date_death(g.id_demo) date_death
, i.code_addr_stat
, i.code_addr_type
, i.code_phn_type
, CASE WHEN i.code_email_stat IN ('||'''C'''||','||'''Q'''||')
       THEN '||'''Y'''||'
       ELSE '||'''N'''||'
       END email_addr_exists
, CASE WHEN (select ii.code_email_stat
             from q_individual ii
             where ii.id_demo = i.id_spouse) IN ('||'''C'''||','||'''Q'''||')
       THEN '||'''Y'''||'
       ELSE '||'''N'''||'
       END email_addr_exists_spouse';

-- ********************************************************** 
         -- INDIVIDUAL output fields  --
-- **********************************************************
vquery2 varchar2(32245) := '
, d1.code_clg g1_code_clg
, d1.date_lgift g1_date_lgift
, d1.nbr_gifts g1_nbr_gifts
, d1.amt_clg g1_amt_clg
, d2.code_clg g2_code_clg
, d2.date_lgift g2_date_lgift
, d2.nbr_gifts g2_nbr_gifts
, d2.amt_clg g2_amt_clg
, d3.code_clg g3_code_clg
, d3.date_lgift g3_date_lgift
, d3.nbr_gifts g3_nbr_gifts
, d3.amt_clg g3_amt_clg
, d4.code_clg g4_code_clg
, d4.date_lgift g4_date_lgift
, d4.nbr_gifts g4_nbr_gifts
, d4.amt_clg g4_amt_clg
, d5.code_clg g5_code_clg
, d5.date_lgift g5_date_lgift
, d5.nbr_gifts g5_nbr_gifts
, d5.amt_clg g5_amt_clg
, ltd_prod.indv(g.id_demo,'||'''1'''||') amt_ltd
, ltd_prod.hh(g.id_demo,'||'''1'''||') amt_ltd_house
, a.total_deferred amt_ltd_def
, a.total_deferred_out amt_ltd_def_out
, a.total_pledges amt_pledge
, a.total_pledges_out amt_pledge_out
, substr(clubs.hh_max_mgc_seq(g.id_demo,1),1) code_club1
, substr(clubs.hh_max_mgc_seq(g.id_demo,2),2) code_club2
, substr(clubs.hh_max_mgc_seq(g.id_demo,3),3) code_club3

, c1.code_clg d1_code_clg
, c1.year_grad d1_year_grad
, c1.year_reunion d1_year_reunion
, c1.desc_campus d1_desc_campus
, c1.desc_major_minor d1_desc_major
, c1.desc_degree d1_desc_degree

, c2.code_clg d2_code_clg
, c2.year_grad d2_year_grad
, c2.year_reunion d2_year_reunion
, c2.desc_campus d2_desc_campus
, c2.desc_major_minor d2_desc_major
, c2.desc_degree d2_desc_degree

, c3.code_clg d3_code_clg
, c3.year_grad d3_year_grad
, c3.year_reunion d3_year_reunion
, c3.desc_campus d3_desc_campus
, c3.desc_major_minor d3_desc_major
, c3.desc_degree d3_desc_degree

, c4.code_clg d4_code_clg
, c4.year_grad d4_year_grad
, c4.year_reunion d4_year_reunion
, c4.desc_campus d4_desc_campus
, c4.desc_major_minor d4_desc_major
, c4.desc_degree d4_desc_degree

, c5.code_clg d5_code_clg
, c5.year_grad d5_year_grad
, c5.year_reunion d5_year_reunion
, c5.desc_campus d5_desc_campus
, c5.desc_major_minor d5_desc_major
, c5.desc_degree d5_desc_degree

from q_individual i
    join temp_id_hh g on g.id_demo = i.id_demo
    left join temp_exp a on g.id_demo = a.id_demo
    left join temp_acad c1 on g.id_demo = c1.id_demo and c1.rank_grad_year = 1
    left join temp_acad c2 on g.id_demo = c2.id_demo and c2.rank_grad_year = 2
    left join temp_acad c3 on g.id_demo = c3.id_demo and c3.rank_grad_year = 3
    left join temp_acad c4 on g.id_demo = c4.id_demo and c4.rank_grad_year = 4
    left join temp_acad c5 on g.id_demo = c5.id_demo and c5.rank_grad_year = 5
    left join temp_gift d1 on g.id_house = d1.id_house and d1.rank_clg_total_gifts = 1
    left join temp_gift d2 on g.id_house = d2.id_house and d2.rank_clg_total_gifts = 2
    left join temp_gift d3 on g.id_house = d3.id_house and d3.rank_clg_total_gifts = 3
    left join temp_gift d4 on g.id_house = d4.id_house and d4.rank_clg_total_gifts = 4
    left join temp_gift d5 on g.id_house = d5.id_house and d5.rank_clg_total_gifts = 5'
;
-- ********************************************************** 
         -- ORGANIZATION output fields  --
-- **********************************************************
vquery3 varchar2(32245)  := '
union all
select
  g.id_demo
, i_info.id_hh(g.id_demo) id_household
, o.name_last
, '||''' '''||' name_maiden
, '||''' '''||' name_first
, '||''' '''||' name_middle
, '||''' '''||' name_label
, 0 id_spouse
, '||''' '''||' name_first_spouse
, '||''' '''||' name_middle_spouse
, '||''' '''||' name_last_spouse
, '||''' '''||' name_label_spouse
, 0 age_spouse
, '||''' '''||' date_death_spouse
, o.name_label_comb
, o.name_label name_org
, o_info.desc_org_type(g.id_demo) desc_org_type
, '||''' '''||' code_gender
, o.flag_alumni
, '||''' '''||' code_staff
, '||''' '''||' maa_stat
, o.code_anon code_anon_donor
, 0 id_employer
, '||''' '''||' name_employer
, '||''' '''||' code_job_title
, '||''' '''||' desc_job_title
, nvl(prospect.name_mgr(g.id_demo),'||'''NO PRIMARY MGR'''||') contact_manager
, o.attention
, o.street_1
, o.street_2
, o.street_3
, o.city
, o.state
, addr.country_desc(o.code_country) country
, geo_fun.id_addr_cbsa(o.id_pref_addr) code_cbsa
, geo_fun.geo_desc(geo_fun.id_addr_cbsa(o.id_pref_addr)) cbsa
, o.zip_code
, o.zip_ext
, o.nbr_area_code
, o.nbr_phone
, o.nbr_ext
, 0 age
, i_info.date_death(o.id_demo) date_death
, o.code_addr_stat
, o.code_addr_type
, o.code_phn_type
, '||''' '''||' email_addr_exists
, '||''' '''||'email_addr_exists_spouse';

vquery4 varchar2(32245) := '
, d1.code_clg g1_code_clg
, d1.date_lgift g1_date_lgift
, d1.nbr_gifts g1_nbr_gifts
, d1.amt_clg g1_amt_clg
, d2.code_clg g2_code_clg
, d2.date_lgift g2_date_lgift
, d2.nbr_gifts g2_nbr_gifts
, d2.amt_clg g2_amt_clg
, d3.code_clg g3_code_clg
, d3.date_lgift g3_date_lgift
, d3.nbr_gifts g3_nbr_gifts
, d3.amt_clg g3_amt_clg
, d4.code_clg g4_code_clg
, d4.date_lgift g4_date_lgift
, d4.nbr_gifts g4_nbr_gifts
, d4.amt_clg g4_amt_clg
, d5.code_clg g5_code_clg
, d5.date_lgift g5_date_lgift
, d5.nbr_gifts g5_nbr_gifts
, d5.amt_clg g5_amt_clg
, ltd_prod.indv(g.id_demo,'||'''1'''||') amt_ltd
, ltd_prod.hh(g.id_demo,'||'''1'''||') amt_ltd_house
, a.total_deferred amt_ltd_def
, a.total_deferred_out amt_ltd_def_out
, a.total_pledges amt_pledge
, a.total_pledges_out amt_pledge_out
, substr(clubs.hh_max_mgc_seq(g.id_demo,1),1) code_club1
, substr(clubs.hh_max_mgc_seq(g.id_demo,2),2) code_club2
, substr(clubs.hh_max_mgc_seq(g.id_demo,3),3) code_club3
, '||''' '''||' d1_code_clg
, 0 d1_year_grad
, 0 d1_year_reunion
, '||''' '''||' d1_desc_campus
, '||''' '''||' d1_desc_major
, '||''' '''||' d1_desc_degree
, '||''' '''||' d2_code_clg
, 0 d2_year_grad
, 0 d2_year_reunion
, '||''' '''||' d2_desc_campus
, '||''' '''||' d2_desc_major
, '||''' '''||' d2_desc_degree
, '||''' '''||' d3_code_clg
, 0 d3_year_grad
, 0 d3_year_reunion
, '||''' '''||' d3_desc_campus
, '||''' '''||' d3_desc_major
, '||''' '''||' d3_desc_degree
, '||''' '''||' d4_code_clg
, 0 d4_year_grad
, 0 d4_year_reunion
, '||''' '''||' d4_desc_campus
, '||''' '''||' d4_desc_major
, '||''' '''||' d4_desc_degree
, '||''' '''||' d5_code_clg
, 0 d5_year_grad
, 0 d5_year_reunion
, '||''' '''||' d5_desc_campus
, '||''' '''||' d5_desc_major
, '||''' '''||' d5_desc_degree
from q_organization o
join temp_id_hh g on g.id_demo = o.id_demo
left join temp_exp a on g.id_demo = a.id_demo
left join temp_gift d1 on g.id_house = d1.id_house and d1.rank_clg_total_gifts = 1
left join temp_gift d2 on g.id_house = d2.id_house and d2.rank_clg_total_gifts = 2
left join temp_gift d3 on g.id_house = d3.id_house and d3.rank_clg_total_gifts = 3
left join temp_gift d4 on g.id_house = d4.id_house and d4.rank_clg_total_gifts = 4
left join temp_gift d5 on g.id_house = d5.id_house and d5.rank_clg_total_gifts = 5'
;
cursor gir_cur is
select
  table_name
from
  user_tables
where
  table_name = upper(param2)
  ;
BEGIN
/*dbms_output.put_line('query1: '||vquery1);
dbms_output.put_line('query2: '||vquery2);
dbms_output.put_line('query3: '||vquery3);
dbms_output.put_line('query4: '||vquery4);*/

  for rec in gir_cur loop
    execute immediate 'DROP TABLE '||table_out;
  end loop;

--  execute immediate vquery1||vquery2;
execute immediate vquery1||vquery2||vquery3||vquery4;

EXCEPTION
    WHEN OTHERS THEN
        raise ;
END; -- Procedure
