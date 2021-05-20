-- Companion script for Practical Oracle SQL, Apress 2020
 -- by Kim Berg Hansen, https://www.kibeha.dk
 
PROMPT **************************************************************
PROMPT Chapter 11: Analytic Partitions, Ordering & Windows
PROMPT **************************************************************
--Best Practices for Running total.  Running total for fiscal year, months.  Remove partition by to see all running total 
drop table t_analytical_windows;
create table t_analytical_windows as  
select p.id_rel_receipt 
       , p.nbr_fund 
       , substr(f.desc_fund, 1, 50) fund_name_short 
       , to_char(p.date_tran,'Mon') as months 
       , year_fiscal 
       , p.amt_fund 
       , sum(p.amt_fund) over(partition by p.year_fiscal        
                                  order by year_fiscal  asc                     
                                           , extract(month from p.date_tran) asc 
                                           , p.amt_fund desc 
                                   rows between unbounded preceding and current row  --default 
                              ) as fy_running
  from q_production  p
  left join fund f on f.nbr_fund = p.nbr_fund 
 where p.id_rel_receipt = 930304023
   and p.year_fiscal between 2012 and 2021
 order by year_fiscal 
         , extract(month from p.date_tran)
         , p.amt_fund desc
         , p.nbr_fund 
;

select * from t_analytical_windows;              


PROMPT ***********************************************
PROMPT ch12_answering_top_n_questions
PROMPT ***********************************************
--same as row_number()
select *
from t_analytical_windows
where year_fiscal = 2012
order by amt_fund desc 
fetch first 3 rows with ties; 


-- row_number()  --same result as : fetch first 5 rows with ties; 
-- rank()        --same result as : row_number(); 
-- dense_rank()  --same as: rank(), except that it gives you 6 since two ties (counted as one) exists
select w.*
from(select
         year_fiscal 
         , p.months
         , p.amt_fund 
         , row_number()over(order by amt_fund desc) as rn
         , rank()      over(order by amt_fund desc) as rnk
         , dense_rank()over(order by amt_fund desc) as dr
   from t_analytical_windows p
  where year_fiscal = 2012
  order by amt_fund desc
 )w
where 1=1 
--and rn <= 5 
--and rnk <= 5 
and dr <= 5
;  


PROMPT ***********************************************
PROMPT Ch17_up_and_down_patterns.sql
PROMPT ***********************************************
 