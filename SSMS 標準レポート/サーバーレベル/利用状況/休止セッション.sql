exec sp_executesql @stmt=N'
                begin try
                select count(distinct s.session_id) as session_cnt
                from sys.dm_exec_sessions s
                where is_user_process = 1
                end try
                begin catch
                select top 0 0 as session_cnt
                end catch
              ',@params=N''
go
exec sp_executesql @stmt=N'
                begin try
                select count(distinct s.login_name) as Count
                from sys.dm_exec_sessions s
                where s.is_user_process = 1
                --and last_request_end_time is not null
                --and last_request_start_time <= last_request_end_time
                and status = ''sleeping''
                and datediff(mi,last_request_end_time,getdate()) >= 60
                end try
                begin catch
                select top 0 0 as Count
                end catch
              ',@params=N''
go
exec sp_executesql @stmt=N'
                begin try
                declare @d1 datetime;
                set @d1 = getdate();

                select top 10  s.login_name
                ,	(datediff(mi,min(s.last_request_end_time),@d1))/60 	as duration
                ,	min(s.last_request_end_time) as oldest_time
                ,	(select count(*)
                from  sys.dm_exec_sessions s2
                where s2.login_name = s.login_name
                and	is_user_process = 1	) as TotalSessions
                ,	count(*) as DormantSessions , sum(case when datediff(mi,s.last_request_end_time, @d1) >= 60 then 1 else 0 end) as DormantSessionshr
                from  sys.dm_exec_sessions s
                where s.is_user_process = 1 and status = ''sleeping''
                --and		s.last_request_end_time is not null
                --and		s.last_request_start_time <= s.last_request_end_time
                group by s.login_name
                order by DormantSessions desc,TotalSessions desc
                end try
                begin catch
                select 0 as login_name
                ,	ERROR_NUMBER() as duration
                ,	ERROR_SEVERITY() as oldest_time
                ,	ERROR_STATE() as TotalSessions
                ,	ERROR_MESSAGE() as DormantSessions
                ,	-100 as DormantSessionshr
                end catch
              ',@params=N''
go
exec sp_executesql @stmt=N'
                begin try
                select count(distinct s.session_id) as session_count
                from sys.dm_exec_sessions s
                where status = ''sleeping'' and datediff(mi,last_request_end_time,getdate()) >= 60
                --where s.is_user_process = 1
                --and last_request_end_time is not null
                --and last_request_start_time <=  last_request_end_time
                --and datediff(hh,last_request_end_time,getdate()) >= 1
                end try
                begin catch
                select top 0 0 as session_count
                end catch
              ',@params=N''
go
exec sp_executesql @stmt=N'
                begin try
                declare @d1 datetime;
                declare @tab_s_id table(session_id smallint);
                set @d1 = getdate();

                insert into @tab_s_id
                select top 10  session_id
                from sys.dm_exec_sessions
                where is_user_process = 1
                and status = ''sleeping''
                --and		last_request_end_time is not null
                --and		last_request_start_time < last_request_end_time
                order by last_request_end_time

                select s.session_id
                ,	s.login_time
                ,	s.host_name
                ,	s.host_process_id
                ,	s.program_name
                ,	s.login_name
                ,	s.is_user_process
                ,	s.last_request_end_time
                ,	(datediff(mi,s.last_request_end_time,@d1))/60 as session_duration
                ,	count(c.connection_id) as connection_id
                ,   s.cpu_time
                ,	s.memory_usage * 8 as memory_usage
                from  @tab_s_id tt
                left outer join sys.dm_exec_sessions s on (tt.session_id = s.session_id)
                left outer join sys.dm_exec_connections c on (s.session_id = c.session_id)
                group by s.session_id
                ,	s.login_time
                ,	s.host_name
                ,	s.host_process_id
                ,	s.program_name
                ,	s.login_name
                ,	s.is_user_process
                ,	s.last_request_end_time
                ,	s.cpu_time
                ,	s.memory_usage
                order by last_request_end_time
                end try
                begin catch
                select -100 as session_id
                ,	ERROR_NUMBER() as login_time
                ,	ERROR_SEVERITY() as host_name
                ,	ERROR_STATE() as host_process_id
                ,	ERROR_MESSAGE() as program_name
                ,	0 as login_name, 0 as is_user_process, 0 as last_request_end_time, 0 as session_duration, 0 as connection_id,  0 as cpu_time, 0 as memory_usage
                end catch
              ',@params=N''
go
