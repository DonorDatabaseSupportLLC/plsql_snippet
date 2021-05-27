 
SELECT *
FROM (
        SELECT DISTINCT  s.*
               , tt.total         AS total_mid
               , tt.year_fiscal   AS year_mid
               , t.total          AS total_commit
               , t.year_fiscal    AS year_commit
        from t201600215c s 
             LEFT join t201600215a t on  s.id_rel = t.id_rel
             LEFT join t201600215aa tt on  s.id_rel = tt.id_rel
    ) 
--pivot for Money-in-the door giving
 pivot (
        SUM ( total_mid ) FOR  year_mid IN ('2010'    AS fy2010_mid
                                             , '2011' AS fy2011_mid
                                             , '2012' AS fy2012_mid
                                             , '2013' AS fy2013_mid
                                             , '2014' AS fy2014_mid
                                             , '2015' AS fy2015_mid
                                           )
       ) 
--pivot for Commitments giving 
pivot ( 
        SUM ( total_commit ) FOR  year_commit IN ( '2010'     AS fy2010_commit
                                                     , '2011' AS fy2011_commit
                                                     , '2012' AS fy2012_commit
                                                     , '2013' AS fy2013_commit
                                                     , '2014' AS fy2014_commit
                                                     , '2015' AS fy2015_commit
                                                   ) 
      )                             
;
