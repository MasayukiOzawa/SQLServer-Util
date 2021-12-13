-- drop table  batch_rec
-- truncate table batch_rec
insert into batch_rec
select 
	getdate() as collect_date,
	counter_name, 
	cntr_value
from 
	sys.dm_os_performance_counters 
where 
	object_name like '%Batch%' and instance_name = 'CPU Time:Requests' 

waitfor delay '00:00:01'
go 100