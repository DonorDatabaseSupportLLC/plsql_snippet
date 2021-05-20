 --range decode 
drop table t203000001a;
create table t203000001a as 
select id_demo 
from q_id where id_demo = 140614357 
;
 
select * from t203000001a;

--SMC estacker 
EXEC estacker_et_confirm('t203000001a','t203000001_et','203000001.1','[]');

SELECT * FROM email_segments@prod WHERE id_list = '203000001.1';--xx
SELECT count(*) FROM t203000001_et;-- 

EXEC email_segments_load.upload@prod('203000001.1','Test email','CSE','D','CSE',NULL,'P');

--Look at the status - Once "Complete" it should be in ExactTarget and ready for you.
SELECT * FROM afsdms.email_segments_status@prod WHERE id_list IN ('203000001.1'); --203000001_1_20107_13470114 

--Should be blank
SELECT * FROM email_segments@prod WHERE id_list = '203000001.1';  


