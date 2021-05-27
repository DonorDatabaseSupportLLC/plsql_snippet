--https://docs.oracle.com/en/database/oracle/oracle-database/12.2/dwhsg/sql-analysis-reporting-data-warehouses.html#GUID-6A8D63AC-5E88-47A8-B5A6-9318173F0206
--Oracle 12.2g


--LISTAGG : 
--will not error out if limit reached 
--On Overflow Truncate: 
--With Count: will truncate with the counts being truncated.
--without Count 
SELECT country_region
	 			, LISTAGG(s.name_first||' - '|| s.name_last || ' - '||i.name_label, ';' ON OVERFLOW TRUNCATE WITH COUNT) --without Count
   									WITHIN GROUP (ORDER BY s.cust_id) AS customer_names
FROM q_individual i 
WHERE i.state = 'MT'
and i.code_addr_stat = 'C'
; 


--old pivot 
SELECT * 
FROM(
		SELECT product, channel, amount_sold
    FROM sales_view
   )S 
PIVOT(SUM(amount_sold) FOR CHANNEL IN (3  AS DIRECT_SALES
																			, 4 AS INTERNET_SALES
                                      , 5 AS CATALOG_SALES
                                      , 9 AS TELESALES
                                      ))
ORDER BY product
;

--12.2 Pivoting on Multiple Columns
SELECT *
FROM
     (SELECT product, channel, quarter, quantity_sold
      FROM sales_view
     ) PIVOT (SUM(quantity_sold) FOR (channel, quarter) IN ((5, '02') AS CATALOG_Q2,
                                                           (4, '01') AS INTERNET_Q1,
                                                           (4, '04') AS INTERNET_Q4,
                                                           (2, '02') AS PARTNERS_Q2,
                                                           (9, '03') AS TELE_Q3
                                                           ))
     ;
     
--12.2  Pivoting: Multiple Aggregates   
SELECT *
FROM
     (SELECT product, channel, amount_sold, quantity_sold
      FROM sales_view
     ) PIVOT (SUM(amount_sold)      AS sums 
              , SUM(quantity_sold)  AS sumq
              FOR channel IN (5, 4, 2, 9)
               )
ORDER BY product
;

