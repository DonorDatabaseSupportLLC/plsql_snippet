CREATE OR REPLACE PROCEDURE qryadm.qstackerrel_mh
   ( param1 IN varchar2,
     param2 IN varchar2,
     include_living_spouse_in IN varchar2 default 'N',
     exclude_dead_and_bad_in IN VARCHAR2 DEFAULT 'Y')
AUTHID current_user
   IS
--
-- To modify this template, edit file PROC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the procedure
--
-- MODIFICATION HISTORY
-- Person           Date            Comments
-- ---------   ------  -------------------------------------------
-- Jim Fairweather  apr 25, 2007    retype in after disaster

   table_in varchar2(100) := ' '||user || '.'|| param1||' ';
   table_out varchar2(100) := ' '||user || '.'|| param2||' ';
   vstacker_1 varchar2(32245) :=
   'create table '|| table_out ||' as
   select
     c.id_demo
--   , i.name_label
     , i.name_last
     , i.name_first
--   , i.name_salut
   , c.id_spouse
--   , namer.label(c.id_spouse) name2_label
     , namer.last(c.id_spouse) name2_last
     , namer.first(c.id_spouse) name2_first
--   , namer.salutation(c.id_spouse) name2_salut
--   , case when c.id_spouse = 0
--          then i.name_label
--          when i.name_label_comb is null
--          then i.name_label
--          else i.name_label_comb
--          end name_label_comb
-- ADDED s.mmf_name - to pull single Addressee in ET_RE_SALUTATION table, when couple does not exists.
   , COALESCE( s.couple_address ,s2.couple_address,s.mmf_name, namer.label_punctuation(namer.comb(i.id_demo)) ) couple_addressee
   , COALESCE( s.couple_salutation,s.mmf_salutation,s2.couple_salutation,s2.mmf_salutation) couple_salutation
   , i.id_pref_addr
  , i.code_addr_type
  , i.code_addr_stat
  , i.attention
  , i.street_1
  , i.street_2
  , i.street_3
  , i.city
  , i.state
  , i.code_country
  , addr.country_desc(i.code_country) country
  , i.zip_code
  , i.zip_ext
  , i.code_carrier_rt
  , i.code_post_net
  , i.code_line_of_travel
  , i.code_lot_sort_order
  , i.onecode_acs_non_presort
  , i.foreign_postal
  , i_info.id_hh(i.id_demo) id_household
  , c.id_rel
  from
    q_individual i join
    (
     select
       case when b.id_demo = 0
            then b.id_spouse
            else b.id_demo
            end id_demo
     , case when b.id_demo != 0
            then b.id_spouse
            else 0
            end id_spouse
     , b.id_rel
     from
       (
        select
          distinct
        a.id_household
        , a.id_rel
        , max(case when a.id_household = a.id_demo
                   then a.id_demo
                   else 0
                   end) id_demo
        , max(case when a.id_household != a.id_demo
                   then a.id_demo
                   else 0
                   end) id_spouse
        from
          (
           select
             nvl(i.id_household,greatest(i.id_demo,nvl(i.id_spouse,0))) id_household
           , i.id_demo
           , id.id_rel
           from
             q_individual i join '
             || table_in || ' s '||
           ' on i.id_demo = s.id_demo
             join q_id id on s.id_demo = id.id_demo ';
   vstacker_2 varchar2(32245) :=
            ') a
       where a.id_household is not null
       group by
         a.id_household , a.id_rel
       ) b
   union all
   select
     a.id_demo
   , 0
   , a.id_rel
   from
     (
      select
        nvl(i.id_household,greatest(i.id_demo,nvl(i.id_spouse,0))) id_household
      , i.id_demo
      , id.id_rel
      from
        q_individual i join '
        || table_in || ' s ' ||
     ' on i.id_demo = s.id_demo
      join q_id id on s.id_demo = id.id_demo';
   vstacker_3 varchar2(32245) :=
            '
       ) a
       where a.id_household is null
       ) c on c.id_demo = i.id_demo
       left join mmf_xref_upload m ON c.id_demo = m.id_demo
       left JOIN et_re_salutation@prod s ON m.id_mmf = s.id_mmf
                                   and m.id_mmf not in (''7059'',''362419'',''65748'',''183699'',''544369'',''26605'',''469145'',
                                                       ''511534'',''135809'',''374386'',''511533'',''436070'',''321561'',''341539'',
                                                       ''198011'',''420091'',''529386'',''358018'',''532065'',''532412'',''301367'',
                                                       ''529765'',''266643'',''375033'',''525307'',''545415'',''271891'',''529365'',
                                                       ''279078'')
       left join mmf_xref_upload m2 ON c.id_spouse = m2.id_demo
       left JOIN et_re_salutation@prod s2 ON m2.id_mmf = s2.id_mmf
                                   and m2.id_mmf not in (''7059'',''362419'',''65748'',''183699'',''544369'',''26605'',''469145'',
                                                       ''511534'',''135809'',''374386'',''511533'',''436070'',''321561'',''341539'',
                                                       ''198011'',''420091'',''529386'',''358018'',''532065'',''532412'',''301367'',
                                                       ''529765'',''266643'',''375033'',''525307'',''545415'',''271891'',''529365'',
                                                       ''279078'')
where not exists (select ''x'' from pic_part pp where pp.id_demo = i.id_demo)
  union
  select
    o.id_demo
--  , o.name_label
    , o.name_last
    , null       --name_first
--  , name_salut
    , 0
--  , null       --name2_label
    , null       --name2_last
    , null       --name2_first
--  , null       --name2_salut
--  , o.name_label  --name_label_comb
   , o.name_label   --nvl(s.couple_address,s.mmf_name) couple_addressee
   , nvl(s.couple_salutation,s.mmf_salutation) couple_salutation
  , o.id_pref_addr
  , o.code_addr_type
  , o.code_addr_stat
  , o.attention
  , o.street_1
  , o.street_2
  , o.street_3
  , o.city
  , o.state
  , o.code_country
  , addr.country_desc(o.code_country) country
  , o.zip_code
  , o.zip_ext
  , o.code_carrier_rt
  , o.code_post_net
  , o.code_line_of_travel
  , o.code_lot_sort_order
  , o.onecode_acs_non_presort
  , o.foreign_postal
  , o.id_demo
  , id.id_rel
  from
    q_organization o join'
    || table_in ||' s '||
    ' on o.id_demo = s.id_demo
    join q_id id on o.id_demo = id.id_demo
    left join mmf_xref_upload m ON o.id_demo = m.id_demo
    left JOIN et_re_salutation@prod s ON m.id_mmf = s.id_mmf
                                   and m.id_mmf not in (''7059'',''362419'',''65748'',''183699'',''544369'',''26605'',''469145'',
                                                       ''511534'',''135809'',''374386'',''511533'',''436070'',''321561'',''341539'',
                                                       ''198011'',''420091'',''529386'',''358018'',''532065'',''532412'',''301367'',
                                                       ''529765'',''266643'',''375033'',''525307'',''545415'',''271891'',''529365'',
                                                       ''279078'')
    where not exists (select ''x'' from pic_part pp where pp.id_demo = o.id_demo)'
  ;
  vliving_spouse varchar2(32245) :=
    ' union
      select
        nvl(i.id_household,greatest(i.id_demo,nvl(i.id_spouse,0))) id_household
      , i.id_spouse
      , id.id_rel
      from
        q_individual i,
        q_id id,
        q_individual ii, '
        || table_in ||' t '||
      ' where
          i.id_demo = t.id_demo
        and id.id_demo = i.id_demo
        and i.id_spouse = ii.id_demo
        and ii.year_death is null
        and not exists (select ''x'' from pic_part pp where pp.id_demo = ii.id_demo)
        and ii.code_anon = '||'''0'''
   ;
     vstacker_bad_indv varchar2(32245) :=
    ' and not exists (select ''x'' from group_part gp
                      where gp.id_demo = i.id_demo
                      and gp.nbr_group in (58)
                      )
      AND NOT EXISTS (SELECT ''x'' FROM subscription sub
                        WHERE 1=1
                        AND sub.code_unit = ''UNIV''
                        AND ( (sub.code_subscript_type = ''A'' AND sub.code_channel = ''A'')
                               OR
                              (sub.code_subscript_type = ''A'' AND sub.code_channel = ''M'')
                             )
                        AND sub.code_subscript_opt_type = ''OUT''
                        AND sub.id_demo = i.id_demo
                        --AND NOT EXISTS (SELECT ''x'' FROM subscription sub1
                        --                WHERE sub1.code_unit = sub.code_unit
                        --                AND sub1.code_subscript_type = sub.code_subscript_type
                        --                AND sub1.code_channel = sub.code_channel
                        --                AND sub1.code_subscript_opt_type = ''IN''
                        --                AND sub1.id_demo = sub.id_demo
                        --                )
                        )
      and i.year_death is null
      and i.code_anon in (''0'',''1'')
      and i.code_addr_stat = ''C''

      '
   ;
     vstacker_bad_spouse varchar2(32245) :=
    ' and not exists (select ''x'' from group_part gp
                      where gp.id_demo = ii.id_demo
                      and gp.nbr_group = 58
                      )
      AND NOT EXISTS (SELECT ''x'' FROM subscription sub
                        WHERE 1=1
                        AND sub.code_unit = ''UNIV''
                        AND ( (sub.code_subscript_type = ''A'' AND sub.code_channel = ''A'')
                               OR
                              (sub.code_subscript_type = ''A'' AND sub.code_channel = ''M'')
                             )
                        AND sub.code_subscript_opt_type = ''OUT''
                        AND sub.id_demo = ii.id_demo
                        --AND NOT EXISTS (SELECT ''x'' FROM subscription sub1
                        --               WHERE sub1.code_unit = sub.code_unit
                        --                AND sub1.code_subscript_type = sub.code_subscript_type
                        --                AND sub1.code_channel = sub.code_channel
                       --                 AND sub1.code_subscript_opt_type = ''IN''
                       --                 AND sub1.id_demo = sub.id_demo
                       --                 )
                        )
      and not exists (select ''x'' from group_part gp2
                      where gp2.id_demo = i.id_demo
                      and gp2.nbr_group = 58
                      )
      AND NOT EXISTS (SELECT ''x'' FROM subscription sub
                        WHERE 1=1
                        AND sub.code_unit = ''UNIV''
                        AND ( (sub.code_subscript_type = ''A'' AND sub.code_channel = ''A'')
                               OR
                              (sub.code_subscript_type = ''A'' AND sub.code_channel = ''M'')
                             )
                        AND sub.code_subscript_opt_type = ''OUT''
                        AND sub.id_demo = i.id_demo
                        --AND NOT EXISTS (SELECT ''x'' FROM subscription sub1
                        --                WHERE sub1.code_unit = sub.code_unit
                        --                AND sub1.code_subscript_type = sub.code_subscript_type
                        --                AND sub1.code_channel = sub.code_channel
                        --                AND sub1.code_subscript_opt_type = ''IN''
                        --                AND sub1.id_demo = sub.id_demo
                        --                )
                        )
      and ( (ii.id_demo = ii.id_household and ii.code_addr_stat = ''C'')
            or
            ii.id_demo != ii.id_household
          )
      '
   ;
     vstacker_bad_org varchar2(32245) :=
    ' and not exists (select ''x'' from group_part gp
                      where gp.id_demo = o.id_demo
                      and gp.nbr_group in (58)
                      )
      AND NOT EXISTS (SELECT ''x'' FROM subscription sub
                        WHERE 1=1
                        AND sub.code_unit = ''UNIV''
                        AND ( (sub.code_subscript_type = ''A'' AND sub.code_channel = ''A'')
                               OR
                              (sub.code_subscript_type = ''A'' AND sub.code_channel = ''M'')
                             )
                        AND sub.code_subscript_opt_type = ''OUT''
                        AND sub.id_demo = o.id_demo
                        --AND NOT EXISTS (SELECT ''x'' FROM subscription sub1
                        --                WHERE sub1.code_unit = sub.code_unit
                        --                AND sub1.code_subscript_type = sub.code_subscript_type
                        --                AND sub1.code_channel = sub.code_channel
                       --                 AND sub1.code_subscript_opt_type = ''IN''
                       --                 AND sub1.id_demo = sub.id_demo
                       --                 )
                        )
      and o.year_oob is null
      and o.code_anon in (''0'',''1'')
      and o.code_addr_stat = ''C''

      '
   ;

cursor stacker_cur is
select
  table_name
from
  user_tables
where
  table_name = upper(param2)
  ;
BEGIN
  for rec in stacker_cur loop
    execute immediate 'drop table '|| param2;
  end loop;

 if include_living_spouse_in = 'N' AND exclude_dead_and_bad_in = 'Y'
    then
 EXECUTE IMMEDIATE vstacker_1||vstacker_bad_indv||vstacker_2||vstacker_bad_indv||vstacker_3||vstacker_bad_org;

 ELSIF include_living_spouse_in = 'N' AND exclude_dead_and_bad_in = 'N'
    THEN
 execute immediate vstacker_1||vstacker_2||vstacker_3;

 ELSIF include_living_spouse_in  = 'Y' AND exclude_dead_and_bad_in = 'N'
    THEN
 EXECUTE IMMEDIATE vstacker_1||vliving_spouse||vstacker_2||vstacker_3;

 else

 execute immediate vstacker_1||vstacker_bad_indv||vliving_spouse||vstacker_bad_spouse||vstacker_2||vstacker_bad_indv||vstacker_3||vstacker_bad_org;

 end if;

 exception
   when others then
        raise ;

END; -- Procedure
