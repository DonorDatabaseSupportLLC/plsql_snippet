
--Giving Increase/increase from previous fiscal year
with temp_amt_fy 
as(
    select a.id_rel
           , year_fiscal 
           , sum(amt_fund) total 
    from(select distinct 
               p.id_rel
             , p.nbr_fund
             , p.id_gift
             , p.code_pmt_form
             , p.code_exp_type
             , p.amt_fund
             , p.year_fiscal 
         from q_production_id p
         where 1=1
         and p.year_fiscal >= 2010
         and p.code_unit = 'UMD' 
         and p.nbr_fund  in ('1272', '1364', '1714', '1898', '2252', 
                             '3387', '3645', '3786', '4253', '5861', '21619',
                             '6033', '7451', '7776', '8248', '20837', '22185'
                             )
         and p.code_recipient != 'S'
         and p.code_anon in ('0','1')
       ) a 
    group by id_rel, year_fiscal
)
, temp_increase_pool 
as(
    select distinct 
           af.*
           , total 
             - 
             lag(total) over (partition by id_rel order by year_fiscal desc)  as amt_change
    from temp_amt_fy af
    order by year_fiscal desc 
  )
select ip.*
      , case when amt_change is not null 
             then (case when amt_change > 0
                        then 'increased'
                        when amt_change = 0 
                        then 'No change'
                        when amt_change < 0
                        then 'decreased'
                        end)
             else 'first year'
             end year_year_giving
from temp_increase_pool ip 
where id_rel = 930333783
; 
    
