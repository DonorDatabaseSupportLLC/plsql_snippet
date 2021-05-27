--regexp - split comma separated columns into two 

--Split: WORKS WELL
--
SELECT t.*
       , trim(regexp_substr(t.team_member_list, '[^;]+', 1, lines.column_value)) team_member_list
FROM t201901516a t
, TABLE (CAST (MULTISET
        (SELECT LEVEL FROM dual
          CONNECT BY regexp_substr(t.team_member_list , '[^;]+', 1, LEVEL) IS NOT NULL
        ) AS sys.odciNumberList )) lines
--WHERE t.id_demo = 600493890
ORDER BY id_demo, lines.column_value
;



--split : DOES NOT WORK 
select id_demo
       , trim(TEAM_MEMBER_LIST) TEAM_MEMBER_LIST 
from t201901516a 
     ,  xmltable(('"'
                || REPLACE(TEAM_MEMBER_LIST, ';', '","')
                || '"'))
where id_demo = 600493890
;

/*  DID NOT TEST    
SELECT t.id,
  2      trim(regexp_substr(t.text, '[^,]+', 1, lines.column_value)) text
  3  FROM t,
  4    TABLE (CAST (MULTISET
  5    (SELECT LEVEL FROM dual
  6            CONNECT BY LEVEL <= regexp_count(t.text, ',')+1
  7    ) AS sys.odciNumberList ) ) lines
  8  ORDER BY id, lines.column_value
  9  
  */


--Source page
--https://lalitkumarb.wordpress.com/2015/03/04/split-comma-delimited-strings-in-a-table-in-oracle/