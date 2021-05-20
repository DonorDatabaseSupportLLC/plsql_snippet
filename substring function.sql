--substring (fx)
  
--SUBSTR( source_string      --string to search
--				, start_position   --position of First character of the string to return.  Default to 1
--				, [ length ] )     --number of characters
 SELECT 
			substr('Dinner starts in one hour.', 8, 6)    AS  string_1   --will return 'starts'
			, substr('Dinner starts in one hour.', 8)     AS  string_2   --will return 'starts in one hour.'
			, substr('Dinner starts in one hour.', 1, 6)  AS  string_3   --will return 'Dinner'
			, substr('Dinner starts in one hour.', 0, 6)  AS  string_4   --will return 'Dinner'
			, substr('Dinner starts in one hour.', -4, 3) AS  string_5   --will return 'our'
			, substr('Dinner starts in one hour.', -9, 3) AS  string_6   --will return 'one'
			, substr('Dinner starts in one hour.', -9, 2) AS  string_7   --will return 'on'
			, substr('Dinner starts in one hour.',0)     AS  string_8    --will return 'Dinner starts in one hour.'
FROM dual
;
 
--function examples using 
SELECT substr(string_in
        	, instr(string_in,'~',1,8) + 1
                , (instr(string_in,'~',1,9)-instr(string_in,'~',1,8)) - 1) string_out

--Instr f(x)
--INSTR( string, substring [, start_position [, th_appearance ] ] )
  -- string: The string to search.
  -- substring: The substring to search for in string. 
	-- start_position: The position in string where the search will start.
	-- nth_appearance: The nth appearance of substring. If omitted, it defaults to 1.
SELECT INSTR('Take the first four characters', 'a', 1, 1)      AS FOUND_1
			, INSTR('Take the first four characters', 'a', 1, 2)     AS FOUND_2
			, INSTR('Take the first four characters', 'four', 1, 1)  AS MCHARS
			, INSTR('Take the first four characters', 'a', -1, 1)    AS REV_SRCH
			, INSTR('Take the first four characters', 'a', -1, 2)    AS REV_TWO
FROM DUAL;

 
SELECT SUBSTR('abc,def,ghi', 1 ,INSTR('abc,def,ghi', ',', 1, 1)-1)
FROM DUAL;


SELECT SUBSTR('abc,def,ghi', INSTR('abc,def,ghi',',', 1, 1)+ 1,
INSTR('abc,def,ghi',',',1,2)-INSTR('abc,def,ghi',',',1,1)-1)
FROM DUAL;

--substring and Instr f(x)
SELECT
substr('raj rahul vir',0,instr('RAJ rahul vir',' ')) "first_name",
substr('raj rahul vir',instr('raj rahul vir',' ')+1, instr('raj rahul vir',' ',1,2)-instr('raj rahul vir',' ')) "MIDDLE NAME",
substr('raj rahul vir',instr('raj rahul vir',' ',1,2))"LAST NAME"
FROM DUAL;


--helper
 SELECT substr(string_in,instr(string_in,'~',1,5)+1,(instr(string_in,'~',1,6)-instr(string_in,'~',1,5))-1) string_out
 FROM   dual;

