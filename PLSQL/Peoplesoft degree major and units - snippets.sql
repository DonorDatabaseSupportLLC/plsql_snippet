
--audit degree list: specific UNIT
SELECT  SUBSTR(acad_plan, -2, 2)     AS code_unit
        , SUBSTR(acad_plan, -5, 3)   AS code_degree
        , SUBSTR(acad_plan, 2, 3)    AS code_major
				, acad_plan
        , CASE WHEN LOWER(acad_plan) LIKE '%min%' THEN 'Y' ELSE NULL END AS is_minor
FROM cs_ps_acad_plan@dw  
WHERE substr(acad_plan, -2,2) = '08'
;
SELECT * FROM decode_clg s WHERE s.code_unit = '08';


--1. major, degree, units in Peoplesofts: specific person   
WITH peoplesoft AS 
    ( SELECT emplid 
        , SUBSTR(acad_plan, -2, 2)    AS code_unit
        , SUBSTR(acad_plan, -5, 3)    AS code_degree
        , SUBSTR(acad_plan, 2, 3)     AS code_major
        , CASE WHEN LOWER(acad_plan) LIKE '%min%' THEN 'Y' ELSE NULL END AS is_minor
        , to_char (degr_status_date, 'YYYY') AS year_grad 
				, acad_plan
     FROM CS_PS_ACAD_DEGR_PLAN@dw d 
     WHERE d.emplid = '2947539'
    )
SELECT i.id_demo
       , i.name_label
       , ps.emplID
			 , ps.code_unit
			 , ps.acad_plan
			 , ps.year_grad
       , ps.code_major
       , mm.desc_major_minor_long
       , ps.is_minor
       , ps.code_degree 
       , dd.desc_degree
       --, ps.code_unit
       , u.desc_clg
FROM peoplesoft ps 
			LEFT JOIN decode_major_minor mm ON mm.code_major_minor = ps.code_major
			LEFT JOIN decode_degree dd ON dd.code_degree = ps.code_degree
			LEFT JOIN decode_clg u ON u.code_unit = ps.code_unit
			JOIN q_individual i ON i.id_psoft = ps.emplid
--WHERE ps.code_unit = xx
;


-- **************************************************************************** 
-- peoplesoft degree offered with academic plan
-- **************************************************************************** 
-- future update: 
--  include subplan (see acad_subplan) 
--          acad subplan (emphasis/speciality)
--          SELECT *  FROM CS_PS_ACAD_SUBPLAN@dw d  WHERE d.emplid = '4850311'; 
-- understand : COMPLETION_TERM field (when graduated) and decode tables to explain numeric terms.   
--****************************************************************************         
 SELECT DISTINCT d.acad_plan
 				, deg.acad_plan_type 
				, deg.descrshort
				, deg.descr 
				, deg.eff_status 
				, deg.institution 
				, deg.TRNSCR_PRINT_FL
				, deg.TRNSCR_DESCR
				, deg.degree 
				, deg.acad_prog
 				, d.acad_career
				, req_term
				, stdnt_degr
				, completion_term
				, d.effdt
 FROM CS_PS_ACAD_PLAN@dw d 
 			JOIN cs_ps_acad_plan_tbl@dw deg ON deg.acad_plan = d.acad_plan
 WHERE d.emplid = '5261440'
 AND completion_term > '0'
; 


SELECT * FROM decode_clg c WHERE code_clg = 'FAN';--30 

--degrees only 
SELECT * FROM cs_ps_acad_plan_tbl@dw;



-----1. major, degree, units in Peoplesofts: DMS FORMAT   
WITH peoplesoft AS 
    ( SELECT SUBSTR(acad_plan, -2, 2)    AS code_unit
						, SUBSTR(acad_plan, -5, 3)  AS code_degree
						, SUBSTR(acad_plan, 2, 3)  AS code_major
						, to_char (effdt, 'YYYY') AS year_grad 
     FROM cs_ps_acad_plan_tbl@dw d  --cs_ps_acad_plan_tbl  --CS_PS_ACAD_DEGR_PLAN 
		 WHERE SUBSTR(acad_plan, 1,4) = '0468'
    )
SELECT DISTINCT 
			  ps.code_major
       , mm.desc_major_minor_long
       , ps.code_degree 
       , dd.desc_degree
       , ps.code_unit
       , u.desc_clg
FROM peoplesoft ps 
LEFT JOIN decode_major_minor mm ON mm.code_major_minor = ps.code_major
LEFT JOIN decode_degree dd ON dd.code_degree = ps.code_degree
LEFT JOIN decode_clg u ON u.code_unit = ps.code_unit
;

--query specific degree
SELECT DISTINCT acad_plan, substr(acad_plan, 5, 3) degreee
FROM cs_ps_acad_plan@dw
WHERE substr(acad_plan, -2,2) = '14'
;

--acad plan (major)
 SELECT DISTINCT ACAD_PLAN 
 FROM CS_PS_ACAD_PLAN@dw d 
 WHERE d.emplid = '4850311'; --2266MIN41
 
 --acad subplan (emphasis/speciality)
 SELECT * 
 FROM CS_PS_ACAD_SUBPLAN@dw d 
 WHERE d.emplid = '4850311';  



--query q_acad_plan from mike's schema
SELECT * 
FROM "M-MCNA".q_academic_subplan 
WHERE code_clg_query = 'NUR'
and code_degree in ('602','621');


---check individuals at Peoplesoft
 SELECT * FROM CS_PS_ACAD_DEGR@dw d WHERE d.emplid = '4850311'; --6/10/1978
 SELECT * FROM CS_PS_ACAD_PLAN_TBL@dw d WHERE d.acad_plan IN ('0736MIN41', '2266MIN41'); --check
 SELECT DISTINCT ACAD_PLAN FROM CS_PS_ACAD_PLAN@dw d WHERE d.emplid = '4850311'; --2266MIN41
 SELECT * FROM CS_PS_ACAD_SUBPLAN@dw d WHERE d.emplid = '4850311';  

---------------- helpers --------------------------------------------------------------------------

select DISTINCT CODE_MAJOR_MINOR 
from clg_query  
where CODE_CLG_QUERY = 'UMD' 
AND code_unit = '41' 
AND code_major_minor = 2266;  

 SELECT * FROM all_views@dw d 
 WHERE lower (d.view_name) LIKE '%acad%plan%'; 



 SELECT * FROM CS_PS_ACAD_DEGR@dw d WHERE d.emplid = '1195276'; --6/10/1978. One line per student
 
 SELECT * FROM CS_PS_ACAD_PLAN@dw d WHERE d.emplid = '1195276';
 
 SELECT * FROM 
 
 SELECT * FROM CS_PS_ACAD_PLAN_TBL@dw d WHERE d.acad_plan = '1195276'; --academic plan inof 
 
 SELECT * FROM CS_PS_ACAD_SUBPLAN@dw d WHERE d.emplid = '1195276';  
 
SELECT * FROM decode_major_minor mm 
WHERE mm.code_major_minor IN ( 812, 996);

SELECT * FROM q_academic a 
WHERE a.code_major = 2266;
