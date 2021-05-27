SELECT *
FROM (SELECT s.*
           , ta.nbr_fund     AS fund 
           , ta.total        AS amt_given_fund 
           , tb.key_value    AS subcorridor
           , tb.amt_ltd_rel  AS amt_given_subcorridor
           , acad.clg_year_major_list(s.id_demo) AS Academic_info
      FROM t201603516e_qstckr s 
      LEFT JOIN t201603516a ta  ON ta.id_rel = s.id_rel 
      LEFT JOIN q_donor_ltd tb  ON tb.id_demo = s.id_demo 
                               AND tb.code_key_value = 'SCO'
                               AND tb.key_value IN ('3', '5', '15', '16', '40')
) 
pivot (sum(amt_given_fund) FOR fund IN ('13456'   AS fund_13456
                                         ,'20301'  AS fund_20301
                                         , '13451' AS fund_13451
                                         , '20198' AS fund_20198 
                                         , '13413' AS fund_13413
                                         , '13420' AS fund_13420
                                         , '13830' AS fund_13830 
                                         , '11773' AS fund_11773
                                         , '11753' AS fund_11753
                                      )
      )
pivot (sum(amt_given_subcorridor) FOR subcorridor IN ('40'    AS sub_corridor_40
                                                       , '16' AS sub_corridor_16
                                                       , '3'  AS sub_corridor_3
                                                       , '15' AS sub_corridor_15
                                                       , '5'  AS sub_corridor_5
                                                     )
      )
 ; 
