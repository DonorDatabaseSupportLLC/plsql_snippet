AND (EXISTS (SELECT 'x' FROM academic a
             WHERE i.id_demo = a.id_demo
               AND a.code_clg = 'UMM'
            )
    OR
    EXISTS (SELECT 'x' FROM q_production_id p
            WHERE p.id_rel = i.id_rel
              AND p.code_clg = 'UMM'
            )
    OR
    EXISTS (SELECT 'x' FROM prospect_v qp
            WHERE qp.id_prospect_master = id.id_demo_master
            AND qp.code_unit = 'UMM'
            )
    )
--excluding PIC
AND NOT EXISTS (SELECT 'x' FROM patient_part pp
                WHERE i.id_demo = pp.id_demo
                  and pp.code_patient in (2,3)
                )
