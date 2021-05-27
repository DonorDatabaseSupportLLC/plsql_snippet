FUNCTION rel_clg --CALCULATES THE RELATED GIVING GIFT TOTAL FOR A SPECIFIC COLLEGE.
                 (
    id_demo     IN q_receipted_id.id_demo%TYPE
   ,code_clg    IN q_receipted_id.code_clg%TYPE
   ,code_anon   IN q_receipted_id.code_anon%TYPE DEFAULT global_constants.std_anon
   ,add_spa     IN q_receipted_id.code_recipient%TYPE DEFAULT NULL)
    RETURN q_receipted_id.amt_gift%TYPE
IS
    --RECORDS
   
    --VARIABLES
    total           gift.amt_gift%TYPE := 0;
--CURSOR
    CURSOR ltd_cur
    IS
    SELECT DISTINCT id.id_rel
            , rcpt.id_gift
            , rcpt.nbr_fund
            , rcpt.code_pmt_form
            , rcpt.code_exp_type
            , rcpt.amt_fund
            , rcpt.id_expectancy
    FROM q_receipted_id rcpt
        JOIN q_id id ON id.id_rel = rcpt.id_rel
    WHERE id.id_demo =  rel_clg.id_demo
    AND rcpt.code_anon <= rel_clg.code_anon
    AND rcpt.code_clg = rel_clg.code_clg
    AND rcpt.code_recipient IN (global_constants.std_u
                                ,global_constants.std_f
                                ,global_constants.std_m
                                ,rel_clg.add_spa);

BEGIN
    total := 0;
    FOR  i in ltd_cur 
    LOOP
        total := total + i.amt_fund;
    END LOOP;
    RETURN total;
EXCEPTION
    WHEN OTHERS
    THEN RAISE;
        
END rel_clg;