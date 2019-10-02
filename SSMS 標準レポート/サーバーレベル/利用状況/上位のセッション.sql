exec sp_executesql @stmt=N'
                begin try
                select top 10  s.session_id
                ,       s.login_time
                ,       s.host_name
                ,       s.program_name
                ,       s.cpu_time as cpu_time
                ,       s.memory_usage * 8 as memory_usage
                ,       s.total_scheduled_time as total_scheduled_time
                ,       s.total_elapsed_time as total_elapsed_time
                ,       s.last_request_end_time
                ,       s.reads
                ,       s.writes
                ,       count(c.connection_id) as conn_count
                from sys.dm_exec_sessions s
                left outer join sys.dm_exec_connections c  on ( s.session_id = c.session_id )
                left outer join sys.dm_exec_requests r  on ( r.session_id = c.session_id )
                where (s.is_user_process= 1) and s.cpu_time > 0
                group by s.session_id, s.login_time, s.host_name, s.cpu_time, s.memory_usage, s.total_scheduled_time, s.total_elapsed_time, s.last_request_end_time, s.reads, s.writes, s.program_name order by s.cpu_time desc
                end try
                begin catch
                select 1 as session_id,1 as login_time,1 as host_name,1 as program_name
                ,       -100 as cpu_time
                ,       1 as memory_usage,1 as total_scheduled_time,1 as total_elasped_time
                ,       ERROR_NUMBER() as last_request_end_time
                ,       ERROR_SEVERITY()  as reads
                ,       ERROR_STATE() as writes
                ,       ERROR_MESSAGE() as conn_count
                end catch
              ',@params=N''
go
exec sp_executesql @stmt=N'
                begin try
                select top 10 s.session_id
                ,       s.login_time
                ,       s.host_name
                ,       s.program_name
                ,       s.cpu_time as cpu_time
                ,       s.memory_usage * 8 as memory_usage
                ,       s.total_scheduled_time as total_scheduled_time
                ,       s.total_elapsed_time as total_elapsed_time
                ,       s.last_request_end_time
                ,       s.reads
                ,       s.writes
                ,       count(c.connection_id) as conn_count
                from sys.dm_exec_sessions s
                left outer join sys.dm_exec_connections c  on ( s.session_id = c.session_id )
                left outer join sys.dm_exec_requests r  on ( r.session_id = c.session_id )
                where (s.is_user_process= 1)
                group by s.session_id, s.login_time, s.host_name, s.cpu_time, s.memory_usage, s.total_scheduled_time, s.total_elapsed_time, s.last_request_end_time, s.reads, s.writes, s.program_name
                order by s.memory_usage desc
                end try
                begin catch
                select 1 as session_id, 1 as login_time, 1 as host_name, 1 as program_name
                ,       -100 as cpu_time
                ,       1 as memory_usage,1 as total_scheduled_time,1 as total_elasped_time
                ,       ERROR_NUMBER() as last_request_end_time
                ,       ERROR_SEVERITY()  as reads
                ,       ERROR_STATE() as writes
                ,       ERROR_MESSAGE() as conn_count
                end catch
              ',@params=N''
go
exec sp_executesql @stmt=N'
                begin try
                select top 10 s.session_id
                ,       s.login_time
                ,       s.host_name
                ,       s.program_name
                ,       s.cpu_time as cpu_time
                ,       s.memory_usage * 8 as memory_usage
                ,       s.total_scheduled_time as total_scheduled_time
                ,       s.total_elapsed_time as total_elapsed_time
                ,       s.last_request_end_time
                ,       s.reads
                ,       s.writes
                ,       count(c.connection_id) as conn_count
                from sys.dm_exec_sessions s
                left outer join sys.dm_exec_connections c  on ( s.session_id = c.session_id )
                left outer join sys.dm_exec_requests r  on ( r.session_id = c.session_id )
                where (s.is_user_process= 1)
                group by s.session_id, s.login_time, s.host_name, s.cpu_time, s.memory_usage, s.total_scheduled_time, s.total_elapsed_time, s.last_request_end_time, s.reads, s.writes, s.program_name
                order by s.writes desc
                end try
                begin catch
                select 1 as session_id, 1 as login_time, 1 as host_name, 1 as program_name
                ,       -100 as cpu_time
                ,       1 as memory_usage,1 as total_scheduled_time,1 as total_elasped_time
                ,       ERROR_NUMBER() as last_request_end_time
                ,       ERROR_SEVERITY()  as reads
                ,       ERROR_STATE() as writes
                ,       ERROR_MESSAGE() as conn_count
                end catch
              ',@params=N''
go
exec sp_executesql @stmt=N'
                begin try
                select top 10 s.session_id
                ,       s.login_time
                ,       s.host_name
                ,       s.program_name
                ,       s.cpu_time as cpu_time
                ,       s.memory_usage * 8 as memory_usage
                ,       s.total_scheduled_time as total_scheduled_time
                ,       s.total_elapsed_time as total_elapsed_time
                ,       s.last_request_end_time
                ,       s.reads
                ,       s.writes
                ,       count(c.connection_id) as conn_count
                from sys.dm_exec_sessions s
                left outer join sys.dm_exec_connections c  on ( s.session_id = c.session_id )
                left outer join sys.dm_exec_requests r  on ( r.session_id = c.session_id )
                where (s.is_user_process= 1)
                group by s.session_id, s.login_time, s.host_name, s.cpu_time, s.memory_usage, s.total_scheduled_time, s.total_elapsed_time, s.last_request_end_time, s.reads, s.writes, s.program_name
                order by s.login_time asc
                end try
                begin catch
                select 1 as session_id, 1 as login_time, 1 as host_name, 1 as program_name
                ,       -100 as cpu_time
                ,       1 as memory_usage,1 as total_scheduled_time,1 as total_elasped_time
                ,       ERROR_NUMBER() as last_request_end_time
                ,       ERROR_SEVERITY()  as reads
                ,       ERROR_STATE() as writes
                ,       ERROR_MESSAGE() as conn_count
                end catch
              ',@params=N''
go
exec sp_executesql @stmt=N'
                begin try
                select top 10 s.session_id
                ,       s.login_time
                ,       s.host_name
                ,       s.program_name
                ,       s.cpu_time as cpu_time
                ,       s.memory_usage * 8 as memory_usage
                ,       s.total_scheduled_time as total_scheduled_time
                ,       s.total_elapsed_time as total_elapsed_time
                ,       s.last_request_end_time
                ,       s.reads
                ,       s.writes
                ,       count(c.connection_id) as conn_count
                from sys.dm_exec_sessions s
                left outer join sys.dm_exec_connections c  on ( s.session_id = c.session_id )
                left outer join sys.dm_exec_requests r  on ( r.session_id = c.session_id )
                where (s.is_user_process= 1)
                group by s.session_id, s.login_time, s.host_name, s.cpu_time, s.memory_usage, s.total_scheduled_time, s.total_elapsed_time, s.last_request_end_time, s.reads, s.writes, s.program_name
                order by s.reads  desc
                end try
                begin catch
                select 1 as session_id, 1 as login_time, 1 as host_name, 1 as program_name
                ,       -100 as cpu_time
                ,       1 as memory_usage,1 as total_scheduled_time,1 as total_elasped_time
                ,       ERROR_NUMBER() as last_request_end_time
                ,       ERROR_SEVERITY()  as reads
                ,       ERROR_STATE() as writes
                ,       ERROR_MESSAGE() as conn_count
                end catch
              ',@params=N''
go
