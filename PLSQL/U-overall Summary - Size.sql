

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
--AND p.code_unit = 'C'
AND p.year_fiscal = 2015
--AND p.date_tran <= '31-may-2015'
GROUP BY id_rel_receipt
) s 
JOIN decode_eis_size des ON s.total BETWEEN des.amt_range_min AND des.amt_range_max
GROUP BY des.desc_eis_size
       , des.display_order
ORDER BY 2
;

--Production Forecast
WITH temp_totals AS
(SELECT id_rel_receipt
       , sum(amt_fund) total
       , count(id_gift) AS total_num
FROM q_production p
WHERE code_recipient != 'S'
--AND p.code_unit = 'DES'
AND p.year_fiscal = 2015
GROUP BY id_rel_receipt
)
SELECT CASE WHEN total >= 5000000   THEN '1 $5M+'
            WHEN total >= 1000000   THEN '2 $1M   - $5M'
            WHEN total >= 250000    THEN '3 $250k - $1M'
            WHEN total >= 100000    THEN '4 $100K - $250K' 
            WHEN total >= 10000     THEN '5 $10K  - $100K'  
            WHEN total >= 1000      THEN '6 $1K   - $10k' 
            WHEN total >= 500       THEN '7 $500  - $1k'
            WHEN total >= 100      THEN  '8 $100  - $500K'
            WHEN total >= .01       THEN '9 <$100'
            ELSE ''
            END sort_size
    , to_char(sum(total),'$999,999,999') total
    , to_char(count(total), '999,999,999') AS total#
FROM temp_totals
GROUP BY  CASE WHEN total >= 5000000   THEN '1 $5M+'
            WHEN total >= 1000000   THEN '2 $1M   - $5M'
            WHEN total >= 250000    THEN '3 $250k - $1M'
            WHEN total >= 100000    THEN '4 $100K - $250K' 
            WHEN total >= 10000     THEN '5 $10K  - $100K'  
            WHEN total >= 1000      THEN '6 $1K   - $10k' 
            WHEN total >= 500       THEN '7 $500  - $1k'
            WHEN total >= 100      THEN  '8 $100  - $500K'
            WHEN total >= .01       THEN '9 <$100'
            ELSE ''
          END 
UNION ALL
SELECT 'xxx     Total' AS Sort_size
      , to_char(sum(total),'$999,999,999') AS total
      , to_char(count(total), '999,999,999') AS total#
FROM temp_totals
GROUP BY 'xxx   Total'
ORDER BY 1
