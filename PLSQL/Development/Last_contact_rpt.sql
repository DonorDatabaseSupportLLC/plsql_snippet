
--last gift dates: 
--SELECT last_gift.dates(last_gift.rel_prod(600505000, 1, '1', 'PHA')) AS last_gift_date_pha FROM dual; --12/21/2016
--SELECT last_gift.dates(last_gift.rel_prod(600505000, 2, '1', 'PHA')) AS last_gift_date_pha FROM dual; --12/17/2015

-- Purpose: build contact report package -->>> functions
--last contact report (substantive): date, manager, desc, unit 
--last contact report (All): date, manager, desc, unit 
--All count contact report
--All count contact Report (substantive

--512/17: fix issue blob not showing 
--512/17: use largest Gift date as sample 
 

---start copy template
FUNCTION contact_dt_substantive
    (id_demo_in                  IN             q_id.id_demo%TYPE
     , unit_in                   IN             decode_unit.code_unit%TYPE)
RETURN date
IS
--VARIABLES
    dates                                         DATE;
--CURSORS
CURSOR last_contact_dt_cur IS
SELECT  x.id_house
         , MAX(x.date_contact) date_last_contact 
FROM(
      SELECT id.id_household AS id_house
              , cr.code_unit
              , cr.code_contact_type
              , cr.code_contact_purpose
              , cr.code_qualify
              , cr.date_contact
              , cr.desc_contact
      FROM contact_reports cr 
           JOIN q_id ID ON ID.id_demo = cr.id_demo
      WHERE cr.code_unit = unit_in
        AND cr.flag_substantive = 'Y'
        AND id.id_demo = open_pledge_balance.
    )x 
GROUP BY x.id_house;
--RECORD TYPES
--PL/SQL TABLE TYPES
--RECORDS
--PL/SQL TABLES
BEGIN
 dates := '' 
 FOR rec IN last_contact_dt_cur LOOP
  dates := rec.date_last_contact;
 END LOOP;
RETURN dates;
END contact_dt_substantive;


--end template

    
;
