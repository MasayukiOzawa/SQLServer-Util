exec sp_executesql @stmt=N'
                begin try
                select (dense_rank() over(order by login_name,nt_user_name))%2 as row_num
                ,       (row_number() over(order by login_name,nt_user_name,sessions.session_id))%2 as session_num
                ,       login_name
                ,       nt_user_name
                ,       sessions.session_id as session_id
                ,       count(distinct connections.connection_id) as connection_count
                ,       count(distinct convert(char,sessions.session_id)+''_''+convert(char,requests.request_id)) as request_count
                ,       count(distinct cursors.cursor_id) as cursor_count
                ,       case when sum(requests.open_tran) is null
                then 0
                else  sum(requests.open_tran) end as transaction_count
                ,       sessions.cpu_time+0.0 as cpu_time
                ,       sessions.memory_usage * 8 as memory_usage
                ,       sessions.reads as reads
                ,       sessions.writes as writes
                ,       sessions.last_request_start_time as last_request_start_time
                ,       sessions.last_request_end_time as last_request_end_time
                from sys.dm_exec_sessions sessions
                left outer join sys.dm_exec_connections connections on sessions.session_id = connections.session_id
                left outer join master..sysprocesses requests on sessions.session_id = requests.spid
                left outer join sys.dm_exec_cursors(null) cursors on sessions.session_id = cursors.session_id
                where (sessions.is_user_process = 1 and requests.dbid = DB_ID())
                group by sessions.login_name,sessions.nt_user_name,sessions.session_id,sessions.cpu_time,sessions.memory_usage,sessions.reads,sessions.writes,sessions.last_request_start_time,sessions.last_request_end_time
                end try
                begin catch
                select  1 as  login_name,1 as session_id,1 as connection_count,1 as request_count,1 as cursor_count,1 as transaction_count,1 as cpu_time,1 as memory_usage,1 as reads
                ,       ERROR_NUMBER() as writes
                ,       ERROR_SEVERITY() as last_request_start_time
                ,       ERROR_STATE() as last_request_end_time
                ,       ERROR_MESSAGE() as nt_user_name
                ,       -100 as row_num
                end catch
              ',@params=N''