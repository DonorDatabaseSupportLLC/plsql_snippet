PROMPT *********************** GP SNIPPETS *************************************

--********************************************
--1. patient record
--********************************************
SELECT * 
FROM afsphi.gp_individual@prod2 e 
WHERE 1=1  
AND e.name_first = 'Xxxxxxxxxxxxxxxxx'
AND e.name_last  = 'Xxxxxxxxxxxxxxxxx'
--AND e.id_gp = 'xxx'
; 

SELECT * 
FROM afsphi.gp_individual@prod2 e 
WHERE e.id_gp = ''
; 

--********************************************
--2. patient visits/encounters
--********************************************
SELECT * 
from afsphi.encounter_v@prod2 e 
WHERE e.patient_id = 'xxxx'
AND e.appointment_status != 'SCHEDULED'
;


--********************************************
--3. patient and their visits
--********************************************
SELECT DISTINCT
			 i.id_gp
			 , i.name_first
       , i.name_last 
       , e.patient_id
       , e.account_id AS id_guarantor 
       , i.code_gp_indv_type
       , MAX(CASE WHEN e.appointment_status = 'COMPLETED' THEN e.contact_date ELSE NULL END) last_contact 
FROM afsphi.gp_individual@prod2 i 
		JOIN afsphi.encounter_v@prod2 e ON e.patient_id = i.id_gp 
WHERE  1=1 
AND i.id_gp = 'xxxxx'
GROUP BY i.id_gp
         , i.name_first
         , i.name_last 
         , e.patient_id
         , e.account_id 
         , i.code_gp_indv_type
;

--********************************************
--4. guarantor  
--********************************************
SELECT DISTINCT
			 i.id_gp
			 , i.name_first
       , i.name_last 
      -- , e.patient_id
       , e.account_id AS id_guarantor 
       , i.code_gp_indv_type
FROM afsphi.gp_individual@prod2 i 
		JOIN afsphi.encounter_v@prod2 e ON e.account_id = i.id_gp
WHERE i.id_gp = 'xxxx'
;




--providers concatenation 
--counts visits - distinct visits --Define visit??? once per day or per Dr. 
--1A.  number of visits --excluding upcoming Dr. Appointment
WITH temp_visit_appt AS 
(
 SELECT e.patient_id as id_gp
       , count(*) AS total_appt
       , max(contact_date) AS recent_appt_date
    FROM afsphi.encounter_v@prod2 e 
         JOIN (SELECT DISTINCT id_gp 
               FROM t201801399a 
              )a ON e.patient_id = a.id_gp
WHERE nvl(e.appointment_status,'N') != 'SCHEDULED'   
--1B. provider not needed if Criteria in 'Table A' does not include specific providers   
AND e.provider_id in ('3368','908210','322016','152603','49360','518829','200900',
                        '201388','201935','18443','18150','41624','48949','181384',
                        '1243','206012','224519','200067'
                      ) 
GROUP BY e.patient_id 
),
--2. getting distinct provider name/ID
temp_providers as 
(
select distinct 
    a.id_gp
    , a.provider_id
    , a.provider_name
from t201801399a a 
) 
SELECT ww.*
FROM(
        SELECT distinct a.id_gp
                     , a.id_demo
                     --include rest of data here 
                     , tv.total_appt
                     , tv.recent_appt_date
--3. Concatenate Providers names 
                     , (SELECT listagg(tp.provider_name||' ('||tp.provider_id||')','; ') 
                                within group (order by tp.provider_id asc, rownum) 
                        FROM temp_providers tp 
                        WHERE tp.id_gp = a.id_gp 
                       ) as provider_list
        from t201801399a a  
            JOIN temp_visit_appt tv ON a.id_gp = tv.id_gp
--4. Not sure if you need this GROUP BY 
        group by a.id_gp
                     , a.id_demo
                     , tv.total_appt
                     , tv.recent_appt_date
            )ww
;


--Demographic table one line per patient/grantor
SELECT * 
FROM afsphi.gp_individual@prod2 e  --ID: id_gp 
WHERE e.id_gp in ('09F41DCBC4992785E053A4616580C977', '1800505' )
AND e.code_gp_indv_type = 'G'  --Guarantor  --'P' Patient 
;


--encounters : Dr. Visit
SELECT e.* --DISTINCT e.patient_id, e.account_id
FROM afsphi.encounter_v@prod2 e    --ID: patient_id 
WHERE e.account_id in ('1800505')
AND e.provider_id in (SELECT DISTINCT trim(provider_id) as  provider_id FROM t201801833_providers)
;


--patient and guarantor and Relationship -  table 
SELECT distinct guar_rel, guar_rel_desc
FROM afsphi.patient_account@prod2 pa 
--WHERE pa.patient_id IN('2850801', '3078863', '09F41DCB1A632785E053A4616580C977')
WHERE guar_rel is not null 
; 


--wealth screening 
SELECT *  
FROM afsphi.gp_wealth_screen@prod2 ;


---gp score??
SELECT * FROM afsphi.gp_score@prod2 ;


SELECT * FROM decode_gp_indv_type@prod;
--P	Patient
--G	Guarantor





--helpers 

  







