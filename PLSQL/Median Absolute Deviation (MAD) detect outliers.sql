--Using Median Absolute Deviation (MAD) to detect data outliers  
--Source: https://towardsdatascience.com/using-sql-to-detect-outliers-aff676bb2c1a

DROP TABLE Kids_Weight;
CREATE TABLE Kids_Weight (Name varchar(20)
                          , Age int 
                          , Weight float
                          );
INSERT INTO Kids_Weight VALUES
('Albert',3,17)

;


select * from Kids_Weight; --7


--MAD final
WITH MedianTab (MedianWt)
AS(
   SELECT 
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Weight) OVER () as MedianWeight
   FROM Kids_Weight
)--select * from MedianTab; --15
, DispersionTab (AbsDispersion)
AS(
   SELECT 
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY (Abs(Weight - MedianWt)))OVER () as AbsDispersion
   FROM MedianTab 
       JOIN Kids_Weight  ON 1=1
)--select * from DispersionTab; --2.5
SELECT DISTINCT 
     s.*
     , ABS((s.Weight - m.MedianWt) / d.AbsDispersion) as deviation 
FROM Kids_Weight s
     , DispersionTab d
     , MedianTab m    
;
--******************************************************************************************
--End 
--******************************************************************************************


--MAD calculation 
--source: https://stackoverflow.com/questions/4065507/evaluating-the-mean-absolute-deviation-of-a-set-of-numbers-in-oracle
SELECT w.name 
      , median(ABS(w.weight - w.median_var))
FROM(
      SELECT name
         , age 
         , weight 
         , median(weight) OVER(partition by name) AS median_var
      FROM Kids_Weight
  )w
GROUP BY name
;

--ver 2 
select median(abs(weight - median_var)) as mad
from(
      select 
           weight
           , median(weight) over() as median_var
      from Kids_Weight
   );


--MAD calculation 
--Source: https://stackoverflow.com/questions/4065507/evaluating-the-mean-absolute-deviation-of-a-set-of-numbers-in-oracle

SELECT  id, MEDIAN(ABS(value - med))
FROM    (
        SELECT  id, value, MEDIAN(value) OVER(PARTITION BY id) AS med
        FROM   mytable
        )
GROUP BY  id




--MAD Cal (SQL Server)
--Source: https://www.mssqltips.com/sqlservertip/4443/calculating-median-absolute-deviation-with-tsql-code-in-sql-server/
--******************************************************************************************
--End 
--******************************************************************************************