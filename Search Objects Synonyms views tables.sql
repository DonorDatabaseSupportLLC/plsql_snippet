--search objects
SELECT * FROM ALL_OBJECTS@prod t 
WHERE LOWER (t.OBJECT_NAME) LIKE '%med%residen%';

--search synonyms
SELECT * FROM ALL_SYNONYMS@prod t 
WHERE LOWER (t.SYNONYM_NAME) LIKE '%med_%resident%';

SELECT * FROM ALL_views@prod t 
WHERE LOWER (t.view_name) LIKE '%residen%';

--search table
SELECT * FROM ALL_TABLES@prod t 
WHERE LOWER (t.TABLE_NAME) LIKE '%residen%';
