exec sp_executesql @stmt=N'begin try
select top 10 c.name as name
,	c.properties
,	c.creation_time
,	c.is_open
,	c.worker_time / 1000 as worker_time
,	c.reads
,	c.writes
,	c.dormant_duration
,	c.session_id
,	s.login_name
,	case when sql_handle IS NULL
		then ''-- ''
		else ( select top 1 substring(text,statement_start_offset/2,(case when statement_end_offset = -1 	then len(convert(nvarchar(MAX),text))*2 + 2	else statement_end_offset	end - statement_start_offset) /2  ) from sys.dm_exec_sql_text(sql_handle))
	end as sql_statement
from sys.dm_exec_cursors(null) c 
left outer join sys.dm_exec_sessions s on c.session_id = s.session_id 
where c.worker_time > 0 
order by c.worker_time DESC
end try
begin catch
select 1 as name,1 as properties,1 as creation_time,1 as is_open
,	-100 as worker_time
,	1 as reads,1 as writes
,	ERROR_NUMBER() as dormant_duration
,	ERROR_SEVERITY() as session_id
,	ERROR_STATE() as login_name
,	ERROR_MESSAGE() as sql_statement
end catch',@params=N''
go
exec sp_executesql @stmt=N'begin try
select top 10 c.name as name
,	c.properties
,	c.creation_time
,	c.is_open
,	c.worker_time / 1000 as worker_time
,	c.reads
,	c.writes
,	c.dormant_duration
,	c.session_id
,	s.login_name
,	case when sql_handle IS NULL
		then ''-- ''
		else ( select top 1 substring(text,statement_start_offset/2,(case when statement_end_offset = -1 	then len(convert(nvarchar(MAX),text))*2 + 2	else statement_end_offset	end - statement_start_offset) /2  ) from sys.dm_exec_sql_text(sql_handle))
	end as sql_statement
from sys.dm_exec_cursors(null) c 
left outer join sys.dm_exec_sessions s on c.session_id = s.session_id 
where (c.reads + c.writes) > 0 
order by (c.reads + c.writes) DESC
end try
begin catch
select 1 as name,1 as properties,1 as creation_time,1 as is_open
,	-100 as worker_time
,	1 as reads,1 as writes
,	ERROR_NUMBER() as dormant_duration
,	ERROR_SEVERITY() as session_id
,	ERROR_STATE() as login_name
,	ERROR_MESSAGE() as sql_statement
end catch',@params=N''
go
exec sp_executesql @stmt=N'begin try
select top 10  c.name  as name
,	c.properties
,	c.creation_time
,	c.is_open
,	c.worker_time / 1000 as worker_time
,	c.reads
,	c.writes
,	c.dormant_duration
,	c.session_id
,	s.login_name
,	case when sql_handle IS NULL
		then ''--''
		else ( select top 1 substring(text,statement_start_offset/2,(case when statement_end_offset = -1 	then len(convert(nvarchar(MAX),text))*2 + 2	else statement_end_offset	end - statement_start_offset) /2  ) from sys.dm_exec_sql_text(sql_handle))
	end as sql_statement
from sys.dm_exec_cursors(null) c 
left outer join sys.dm_exec_sessions s on c.session_id = s.session_id 
order by c.dormant_duration DESC
end try
begin catch
select 1 as name,1 as properties,1 as creation_time,1 as is_open
,	-100 as worker_time
,	1 as reads,1 as writes
,	ERROR_NUMBER() as dormant_duration
,	ERROR_SEVERITY() as session_id
,	ERROR_STATE() as login_name
,	ERROR_MESSAGE() as sql_statement
end catch',@params=N''
go
exec sp_executesql @stmt=N'begin try
select top 10 c.name as name
,	c.properties
,	c.creation_time
,	c.is_open
,	c.worker_time / 1000 as worker_time
,	c.reads
,	c.writes
,	c.dormant_duration
,	c.session_id
,	s.login_name
,	case when sql_handle IS NULL
		then ''-- ''
		else ( select top 1 substring(text,statement_start_offset/2,(case when statement_end_offset = -1 	then len(convert(nvarchar(MAX),text))*2 + 2	else statement_end_offset	end - statement_start_offset) /2  ) from sys.dm_exec_sql_text(sql_handle))
	end as sql_statement
from sys.dm_exec_cursors(null) c 
left outer join sys.dm_exec_sessions s on c.session_id = s.session_id 
order  by c.creation_time
end try
begin catch
select 1 as name,1 as properties,1 as creation_time,1 as is_open
,	-100 as worker_time
,	1 as reads,1 as writes
,	ERROR_NUMBER() as dormant_duration
,	ERROR_SEVERITY() as session_id
,	ERROR_STATE() as login_name
,	ERROR_MESSAGE() as sql_statement
end catch',@params=N''
go
