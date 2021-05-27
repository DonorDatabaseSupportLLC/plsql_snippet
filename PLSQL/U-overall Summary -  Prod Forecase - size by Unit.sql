/*

SELECT des.desc_eis_size
       , des.display_order
       , count(DISTINCT id_rel_receipt) AS donors
       , to_char(sum(total),'$999,999,999,999') AS amount
FROM (
SELECT id_rel_receipt
       , sum(amt_fund) total
       , count(id_gift) AS total_num
FROM q_production p
WHERE code_recipient != 'S'
AND p.code_unit = 'CH'
AND p.year_fiscal = 2015
--AND p.date_tran <= '31-may-2015'
GROUP BY id_rel_receipt
) s 
JOIN decode_eis_size des ON s.total BETWEEN des.amt_range_min AND des.amt_range_max
GROUP BY des.desc_eis_size
       , des.display_order
ORDER BY 2
;*/

--Production Forecast
WITH temp_totals AS
(SELECT id_rel_receipt
       , sum(amt_fund) total
       , count(id_gift) AS total_num
FROM q_production p
WHERE code_recipient != 'S'
AND p.code_unit = 'CH'
AND p.year_fiscal = 2015
GROUP BY id_rel_receipt
)
    SELECT CASE WHEN total >= 5000000   THEN '1 $5M+'
                WHEN total >= 1000000   THEN '2 $1M   - $5M'
                WHEN total >= 50000     THEN '3 $50k  - $1M'
                WHEN total >= .01       THEN '4 <$50k'
                ELSE ''
            END sort_size
    , to_char(sum(total),'$999,999,999.99') total
    , to_char(count(total), '999,999,999') AS total#
FROM temp_totals
GROUP BY   CASE WHEN total >= 5000000   THEN '1 $5M+'
                WHEN total >= 1000000   THEN '2 $1M   - $5M'
                WHEN total >= 50000     THEN '3 $50k  - $1M'
                WHEN total >= .01       THEN '4 <$50k'
                ELSE ''
          END 
UNION ALL
SELECT 'xxx     Total' AS Sort_size
      , to_char(sum(total),'$999,999,999.99') AS total
      , to_char(count(total), '999,999,999') AS total#
FROM temp_totals
GROUP BY 'xxx   Total'
ORDER BY 1
