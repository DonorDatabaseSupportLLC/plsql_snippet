WITH temp_a AS 
(
    SELECT DISTINCT id_gp
    FROM t201800987a
 ) 
SELECT a.id_gp
       , count(*) AS total_appt
       , max(contact_date) AS recent_appt_date
FROM afsphi.encounter_v@prod2 e 
       JOIN temp_a a ON e.patient_id = a.id_gp
WHERE e.appointment_status != 'SCHEDULED'
GROUP BY a.id_gp
UNION 
SELECT a.id_gp
       , count(*) AS total_appt
       , max(contact_date) AS recent_appt_date
FROM afsphi.encounter_v@prod2 e 
       JOIN temp_a a ON e.account_id = a.id_gp
WHERE e.appointment_status != 'SCHEDULED'  --contact_date - includes their Dr. scheduled appt. so exclude that. 
GROUP BY a.id_gp
;