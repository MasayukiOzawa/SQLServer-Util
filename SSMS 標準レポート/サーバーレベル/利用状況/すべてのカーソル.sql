exec sp_executesql @stmt=N'
                begin try
                select  (dense_rank() over (order by c.session_id))%2 as l1
                ,	(row_number() over(partition by c.session_id order by c.name))%2 as l2
                ,	c.session_id
                ,	c.properties
                ,	c.name as name
                ,	c.creation_time
                ,	c.is_open
                ,	c.worker_time / 1000 as worker_time
                ,	c.reads
                ,	c.writes
                ,	c.dormant_duration
                ,	s.login_name
                ,	case when sql_handle IS NULL then '' ''
                else (select top 1 substring(text,(statement_start_offset+2)/2,(case when statement_end_offset = -1 then len(convert(nvarchar(MAX),text))*2 else statement_end_offset	end - statement_start_offset) /2  ) from sys.dm_exec_sql_text(sql_handle))
                end as sql_statement
                FROM    sys.dm_exec_cursors(null) c
                left outer join sys.dm_exec_sessions s on c.session_id = s.session_id
                order by c.session_id,c.name
                end try
                begin catch
                select -100 as l1
                ,	ERROR_NUMBER() AS l2
                ,	ERROR_SEVERITY() AS session_id
                ,	ERROR_STATE() as properties
                ,	ERROR_MESSAGE() AS name
                ,	1 as creation_time, 1 as is_open,1 as worker_time,1 as reads, 1 as writes,1 as dormant_duration,1 as login_name,1 as sql_statement
                end catch
              ',@params=N''