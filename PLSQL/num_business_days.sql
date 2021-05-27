CREATE OR REPLACE FUNCTION qryadm.num_business_days
			( date_begin DATE,
			  date_end DATE
			)
return number

is
l_work_days binary_integer;

BEGIN
WITH dif AS
(
SELECT CASE WHEN NVL(date_end - date_begin, 0) > 0 THEN FLOOR (date_end - date_begin) /*+ 1*/ END days
FROM dual
)
SELECT
			--days - COUNT(CASE WHEN TO_CHAR(date_begin + LEVEL,'DY') NOT IN ('SAT','SUN') THEN 1 END) work_ends
			days - COUNT(CASE WHEN TO_CHAR(date_begin + LEVEL,'DY') IN ('SAT','SUN') THEN 1 END) work_days
INTO l_work_days
FROM dif
CONNECT BY LEVEL <= days
;

RETURN l_work_days;
END num_business_days
;
