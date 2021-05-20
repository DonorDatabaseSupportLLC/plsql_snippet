--helpers
SELECT distinct e.patient_id, pa.account_id --e.*, pa.* 
FROM afsphi.encounter_v@prod2 e
			LEFT JOIN afsphi.patient_account@prod2 pa ON e.account_id = pa.account_id 
																					AND e.patient_id = pa.patient_id 
																					--AND upper(pa.guar_rel_desc) = 'SELF'
WHERE ROWNUM <= 400
--AND e.encounter_id = '09F44D8D5C4F3795E053A461658029D4'
AND pa.patient_id IN ( '09F41DC934722785E053A4616580C977','09F41DC934722785E053A4616580C977')
;
SELECT * 
FROM afsphi.patient_account@prod2 e 
WHERE 1=1 
AND e.patient_id IN( '09F41DC934722785E053A4616580C977','09F41DC934722785E053A4616580C977')
--AND e.ACCOUNT_ID = 1451014
;