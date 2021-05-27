
select y.code_unit
       , y.year_fiscal
       , d.desc_eis_type as type 
       , d.display_order
       --, sum(y.donors) as donor_count
       , count(distinct y.id_rel) as donor_count
       , to_char(sum(y.total),'$999,999,999') as total
from(
    SELECT s.code_unit
         , s.year_fiscal
         , s.code_eis_type
         , d.eis_type_rollup
         , d.desc_eis_type
         --, count(distinct s.id_rel) as donors
         , s.id_rel
         , SUM(s.amt_fund) total
    FROM(
         SELECT g.id_rel_receipt id_rel
                , g.amt_fund
                , x.rpt_clg code_unit
                --, g.code_dept
                , g.year_fiscal
                , CASE WHEN code_recipient IN ('U','F') THEN 'F' ELSE code_recipient END code_recipient
                , CASE WHEN code_exp_type = 'G' THEN code_pmt_form ELSE code_exp_type END code_eis_type
                FROM q_production g
                JOIN q_clg_xref x
                     ON x.orginal_clg = g.code_unit
                JOIN decode_eis_use u
                     ON u.code_eis_use = g.code_use
                WHERE /* g.code_unit = 'CH' 
                AND */ g.year_fiscal = 2015
                AND g.code_recipient IN ('U','F')
         ) s
    left join decode_eis_type d 
         on d.code_eis_type = s.code_eis_type
    /* WHERE  s.code_unit = 'CH' */
    GROUP BY s.code_unit
           , s.year_fiscal
           , s.code_eis_type
           , d.eis_type_rollup
           , d.desc_eis_type
           , s.id_rel
     ) y 
join decode_eis_type d 
     on d.code_eis_type = y.eis_type_rollup
group by y.code_unit
       , y.year_fiscal
       , d.desc_eis_type
       , d.flag_deferred
       , d.display_order
order by d.flag_deferred, d.display_order
;

select * from decode_eis_type;
select * from decode_type;
