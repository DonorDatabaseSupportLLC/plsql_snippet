--v1.  source: https://stackoverflow.com/questions/23585667/percentile-disc-vs-percentile-cont/23586227
drop table test_percent_disc_cont ;
create table test_percent_disc_cont as 
select 'TEST' as item,  'E' as region,  3 as week, 137 as forecastQty from dual 
union 
select 'TEST' as item,  'E' as region,  2 as week, 190 as forecastQty from dual 
union 
select 'TEST' as item,  'E' as region,  1 as week, 232 as forecastQty from dual 
union 
select 'TEST' as item,  'E' as region,  4 as week, 400  as forecastQty from dual 
;

select * from test_percent_disc_cont;


--percent_cont and Percent_disc
select t.*
       , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY forecastqty) OVER (PARTITION BY ITEM, region) AS PERCENTILE_CONT 
       , MEDIAN(forecastqty)OVER (PARTITION BY ITEM, region)                                       AS MEDIAN 
       , PERCENTILE_DISC(0.5)WITHIN GROUP ( ORDER BY forecastqty) OVER (PARTITION BY ITEM, region) AS PERCENTILE_DISC
from test_percent_disc_cont t 
; 

--v2. source: https://riptutorial.com/sql/example/27457/percentile-disc-and-percentile-cont

