 
SELECT TO_CHAR(COUNT(*),'999,999,999') nbr_rows_before FROM batchman.qt_portfolio_mgmt_giving;

--grant select on batchman.qt_portfolio_mgmt_giving to tableau;
--DROP TABLE batchman.qt_portfolio_mgmt_giving;
--CREATE TABLE batchman.qt_portfolio_mgmt_giving AS 
declare
  type ntt is table of batchman.qt_portfolio_mgmt_giving%rowtype;
  l_rows  ntt;
  l_own   varchar2(30) := 'batchman';
  l_tab   varchar2(30) := 'qt_portfolio_mgmt_giving';
  cursor l_cur is
with temp_dates as 
     (select dt
           , add_months(dt,-60) as five_year_prior
           , add_months(dt,-36) as three_year_prior
           , add_months(dt,-24) as two_year_prior
           , add_months(dt,-12) as one_year_prior
           , add_months(dt,-6) as six_month_prior
           , add_months(dt,-3) as three_month_prior
     from 
     (select to_date(sysdate) as dt from dual)
     )
,temp_cor_units as 
    (select count (distinct du.code_unit) as cor_units 
    from decode_unit du 
        join prospect_v pv on pv.code_unit = du.code_unit
    where du.code_unit_type = 'COR' 
        and du.flag_prospect = 'Y'
        and pv.code_team_member_status = 'A'
        and pv.code_team_member <> 'V'
    )
 select * from temp_cor_units
;
/*
begin
  execute immediate 'truncate table ' || l_own || '.' || l_tab;
  open l_cur;
  loop
    fetch l_cur bulk collect into l_rows limit 1000;
      forall i in 1..l_rows.count
        insert into batchman.qt_portfolio_mgmt_giving values l_rows(i);
      exit when l_rows.count < 1000;
  end loop;
  commit;
  close l_cur;
end;
*/
/ 

SELECT TO_CHAR(COUNT(*),'999,999,999') nbr_rows_after FROM batchman.qt_portfolio_mgmt_giving;

PROMPT *******************************************
PROMPT *******************************************
PROMPT **        BUILD FOR QRYP USE ONLY        **
PROMPT *******************************************
PROMPT *******************************************
