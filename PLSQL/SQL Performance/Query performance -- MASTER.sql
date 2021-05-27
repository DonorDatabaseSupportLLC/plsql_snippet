PROMPT **************** Understanding Oracle Query Execution Plan **************** 
--add this to tables
Analyze table q_individual compute statistics;
create unique index idx_prod_id on product (id) compute statistics;
Analyze table q_individual compute statistics;
--1. Oracle Full Table Scan (FTS)
 explain plan for select * from q_individual; --rule based optimizer used (consider using cbo) since no stat exists
select * from table(dbms_xplan.display);
Analyze table q_individual compute statistics;
 explain plan for select * from product; 
 
--2. Index Unique Scan
create unique index idx_prod_id on product (id) compute statistics;
explain plan for select id from product where id = 100;
select * from table(dbms_xplan.display);

--3.  Table Access by Index RowID 
explain plan for select * from product where id = 100;
select * from table(dbms_xplan.display);

--x. Index Range Scan
explain plan for select id from product where id <10 
select * from table(dbms_xplan.display);

--x. Index Fast Full Scan
explain plan for select id from product where id>10;
select * from table(dbms_xplan.display);



