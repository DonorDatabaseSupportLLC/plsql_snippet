drop table test_pool;
create table test_pool AS
SELECT DISTINCT gp.id_demo 
FROM group_part  gp
    JOIN q_individual i ON gp.id_demo = i.id_demo
WHERE gp.nbr_group = 12434 
AND i.year_death IS NULL
AND i.code_anon IN ('0','1')
;
select COUNT(*) from test_pool; --1083  



--***************************************************
--option 1:
--***************************************************
drop table test_eoo;
create table test_eoo as
select p.id_demo
from test_pool p
join q_individual i on i.id_demo = p.id_demo  
where i.email_addr is not null
and not exists (select 'x' from all_subscription_v asv
                where 1=1
                and asv.id_demo = i.id_demo 
                and asv.code_unit = '24'
                and asv.code_channel = 'E'                  --M = Mail  --E = Email  --P = Phone
                and asv.code_subscript_type IN ('P')        --E = Event  --P = Publication  --S = Solicitation  --V = Survey
                --AND asv.code_subscription IN ('xxx')      --Use if specific subscription code is needed
								and asv.code_subscription is null           --Use for general subscription level
                and asv.code_subscript_opt_type = 'OUT'
                and not exists (select 'x' from all_subscription_v asv2
                                where 1=1
                                  and asv.id_demo = asv2.id_demo
                                  and asv.code_unit = asv2.code_unit
                                  and asv.code_channel = asv2.code_channel
                                  and asv.code_subscript_type = asv2.code_subscript_type
                                  and asv.code_subscription = asv2.code_subscription
                                  and asv2.code_subscript_opt_type = 'IN'
                                  )
                )   
and not exists (select 'x' from all_subscription_v asv
                where 1=1
                and asv.id_demo = i.id_demo 
                and asv.code_unit = '24'
                and asv.code_channel = 'E'                    --M = Mail  --E = Email  --P = Phone
                and asv.code_subscript_type IN ('E') 					--E = Event  --P = Publication  --S = Solicitation  --V = Survey
                --AND asv.code_subscription IN ('xxx')     	  --Use if specific subscription code is needed
								and asv.code_subscription is null             --Use for general subscription level
                and asv.code_subscript_opt_type = 'OUT'
                and not exists (select 'x' from all_subscription_v asv2
                                where 1=1
                                  and asv.id_demo = asv2.id_demo
                                  and asv.code_unit = asv2.code_unit
                                  and asv.code_channel = asv2.code_channel
                                  and asv.code_subscript_type = asv2.code_subscript_type
                                  and asv.code_subscription = asv2.code_subscription
                                  and asv2.code_subscript_opt_type = 'IN'
                                  )
                )  
and not exists (select 'x' from all_subscription_v asv
                where 1=1
                and asv.id_demo = i.id_demo 
                and asv.code_unit = '24'
                and asv.code_channel = 'E'                    --M = Mail  --E = Email  --P = Phone
                and asv.code_subscript_type IN ('S') 					--E = Event  --P = Publication  --S = Solicitation  --V = Survey
                --AND asv.code_subscription IN ('xxx')     		--Use if specific subscription code is needed
								and asv.code_subscription is null             --Use for general subscription level
                and asv.code_subscript_opt_type = 'OUT'
                and not exists (select 'x' from all_subscription_v asv2
                                where 1=1
                                  and asv.id_demo = asv2.id_demo
                                  and asv.code_unit = asv2.code_unit
                                  and asv.code_channel = asv2.code_channel
                                  and asv.code_subscript_type = asv2.code_subscript_type
                                  and asv.code_subscription = asv2.code_subscription
                                  and asv2.code_subscript_opt_type = 'IN'
                                  )
                )  
and not exists (select 'x' from all_subscription_v asv
                where 1=1
                and asv.id_demo = i.id_demo 
                and asv.code_unit = '24'
                and asv.code_channel = 'E'                --M = Mail  --E = Email  --P = Phone
                and asv.code_subscript_type IN ('V') 	    --E = Event  --P = Publication  --S = Solicitation  --V = Survey
                --AND asv.code_subscription IN ('xxx')    --Use if specific subscription code is needed
								and asv.code_subscription is null         --Use for general subscription level
                and asv.code_subscript_opt_type = 'OUT'
                and not exists (select 'x' from all_subscription_v asv2
                                where 1=1
                                  and asv.id_demo = asv2.id_demo
                                  and asv.code_unit = asv2.code_unit
                                  and asv.code_channel = asv2.code_channel
                                  and asv.code_subscript_type = asv2.code_subscript_type
                                  and asv.code_subscription = asv2.code_subscription
                                  and asv2.code_subscript_opt_type = 'IN'
                                  )
                )   
; 

SELECT COUNT(*) FROM test_eoo;--493.  Time lapse: 11.3 seconds

--***************************************************
--option 2: Best option. Faster and efficient
--***************************************************
drop table test_eoo_all;
create table test_eoo_all as
select p.id_demo
from test_pool p
join q_individual i on i.id_demo = p.id_demo  
where i.email_addr is not null
and not exists (select 'x' from all_subscription_v asv
                where 1=1
                and asv.id_demo = i.id_demo 
                and asv.code_unit = '24'
                and asv.code_channel = 'E'                       --M = Mail  --E = Email  --P = Phone
                and asv.code_subscript_type IN ('P','E','S','V') --E = Event  --P = Publication  --S = Solicitation  --V = Survey
                --AND asv.code_subscription IN ('xxx')     			 --Use if specific subscription code is needed
								and asv.code_subscription is null              --Use for general subscription level
                and asv.code_subscript_opt_type = 'OUT'
                and not exists (select 'x' from all_subscription_v asv2
                                where 1=1
                                  and asv.id_demo = asv2.id_demo
                                  and asv.code_unit = asv2.code_unit
                                  and asv.code_channel = asv2.code_channel
                                  and asv.code_subscript_type = asv2.code_subscript_type
                                  and asv.code_subscription = asv2.code_subscription
                                  and asv2.code_subscript_opt_type = 'IN'
                                  )
                )   
;
SELECT COUNT(*) FROM test_eoo_all;--493  --Time lapses: 4 seconds 