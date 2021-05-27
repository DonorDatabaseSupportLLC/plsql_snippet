    DECLARE 
		id_demo_in       q_individual.id_demo%TYPE ; 
     year_fiscal_in  q_production.year_fiscal%TYPE; 
     code_anon_in    q_individual.code_anon%TYPE DEFAULT 0 ; 
     clg_in          q_academic.code_clg%TYPE DEFAULT '%'; 
	
		BEGIN 
		CURSOR consec_org IS
        SELECT
            t.year_fiscal,
            COUNT(PRIOR t.year_fiscal)+1 conseq
        FROM
            (
            SELECT DISTINCT
                p.year_fiscal
            FROM
                q_production_id p
            WHERE
                p.id_demo = id_demo_in AND
                p.year_fiscal <= year_fiscal_in AND
                p.code_anon <= code_anon_in AND
                p.code_clg LIKE (NVL(UPPER(clg_in),'%')) AND
                p.code_recipient <> 'S'
            UNION
            SELECT DISTINCT
                p.year_fiscal
            FROM
                q_receipted_id p
            WHERE
                p.id_demo = id_demo_in AND
                p.year_fiscal <= year_fiscal_in AND
                p.code_anon <= code_anon_in AND
                p.code_clg LIKE (NVL(UPPER(clg_in),'%')) AND
                p.code_recipient <> 'S'
            ORDER BY year_fiscal
            ) t
        GROUP BY t.year_fiscal
        CONNECT BY t.year_fiscal = PRIOR t.year_fiscal+1
				;
				SYS.DBMS_OUTPUT.put_line('Hi there genius!');
		EXCEPTION
     when NO_DATA_FOUND then
     raise_application_error(-20000,
     'Hey, This is in the exception-handling section!');

		END; 