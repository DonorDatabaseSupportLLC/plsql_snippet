CREATE OR REPLACE FUNCTION qryadm.ltd_rel_giving_range
   (
    --id_demo_in     IN q_individual.id_demo%TYPE DEFAULT NULL ,
    amt_fund_in    IN VARCHAR2 DEFAULT NULL
   )
  RETURN  VARCHAR2
IS
 amt_fund_out                  VARCHAR2(400) ;

BEGIN
SELECT amt_range
INTO amt_fund_out
FROM(
		 SELECT -- id_demo,
     			   CASE WHEN amt_fund_in >=  100000000 THEN '(A)$100,000,000+'
                  WHEN amt_fund_in  >=  50000000 THEN '(B)$50,000,000 - $99,999,999'
                  WHEN amt_fund_in  >=  25000000 THEN '(C)$25,000,000 - $49,999,999'
                  WHEN amt_fund_in  >=  10000000 THEN '(D)$10,000,000 - $24,999,999'
                  WHEN amt_fund_in  >=   5000000 THEN '(E)$5,000,000  - $9,999,999'
                  WHEN amt_fund_in  >=   2500000 THEN '(F)$2,500,000  - $4,999,999'
                  WHEN amt_fund_in  >=   1000000 THEN '(G)$1,000,000  - $2,499,999'
                  WHEN amt_fund_in  >=    500000 THEN '(H)$500,000    - $999,999'
                  WHEN amt_fund_in  >=    250000 THEN '(I)$250,000    - $499,999'
                  WHEN amt_fund_in  >=    100000 THEN '(J)$100,000    - $249,999'
                  WHEN amt_fund_in  >=     50000 THEN '(K)$50,000     - $99,999'
                  WHEN amt_fund_in  >=     10000 THEN '(L)$10,000     - $49,999'
                  WHEN amt_fund_in  >          0 THEN '(M)Below $10,000'
                  ELSE NULL
				END AS amt_range
         /*, case when amt_fund_in >= 10000 then 1
              when amt_fund_in >=    1000 then 2
              when amt_fund_in >=     500 then 3
              when amt_fund_in >        0 then 4
             end as donation_sort
           , case when amt_fund_in >= 10000 then '(A)$10,000+'
                  when amt_fund_in >=  1000 then '(B)$1,000-$10,000'
                  when amt_fund_in >=   500 then '(C)$500-$999'
                  when amt_fund_in >      0 then '(D)Up to $499'
             end as amt_range
        */
		FROM dual
	);

RETURN nvl(amt_fund_out, '0') ;
EXCEPTION WHEN OTHERS THEN
  RAISE;

END ltd_rel_giving_range;
