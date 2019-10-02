exec sp_executesql @stmt=N'begin try
select (row_number() over (order by counter_name))%2 as l1
,       * 
from sys.dm_os_performance_counters 
where (object_name like ''%Broker Statistics%'') 
order by counter_name
end try
begin catch
select -100 as l1
,       ERROR_NUMBER() as object_name
,       ERROR_SEVERITY() as counter_name
,       ERROR_STATE() as instance_name
,       ERROR_MESSAGE() as cntr_value
,       0 as cntr_type
end catch',@params=N''
go
exec sp_executesql @stmt=N'begin try
select (row_number() over (order by counter_name))%2 as l1
,       * 
from sys.dm_os_performance_counters 
where (object_name like ''%Broker Transport%'') 
order by counter_name
end try
begin catch
select -100 as l1
,       ERROR_NUMBER() as object_name
,       ERROR_SEVERITY() as counter_name
,       ERROR_STATE() as instance_name
,       ERROR_MESSAGE() as cntr_value
,       0 as cntr_type
end catch',@params=N''
go
exec sp_executesql @stmt=N'begin try
select (row_number() over (order by t1.connection_id))%2 as l1
,       convert(varchar(100), t1.connection_id) as [ConnectionId_Str]
,       * 
from sys.dm_broker_connections t1 
order by t1.connection_id
end try
begin catch
select -100 as l1
,       ERROR_NUMBER() as ConnectionId_Str
,       ERROR_SEVERITY() as connection_id
,       ERROR_STATE() as state
,       ERROR_MESSAGE() as connect_time
,       0 as login_time, 0 as last_activity_time, 0 as is_accept, 0 as login_state, 0 as receives_posted, 0 as is_receive_flow_controlled, 0 as total_bytes_sent, 0 as total_bytes_recived, 0 as total_fragments_sent, 0 as total_fragments_recived, 0 as total_sends, 0 as total_receives
end catch',@params=N''
go