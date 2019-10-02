exec sp_executesql @stmt=N'
                begin try
                declare @yield_count  table(
                scheduler_id varbinary(8)
                ,       yield_count int
                );

                insert into @yield_count (scheduler_id, yield_count)
                select scheduler_id, yield_count from sys.dm_os_schedulers

                select 1 as l1
                ,       1 as dummy1
                ,       1 as dummy2
                ,       s.scheduler_id
                ,       case when s.work_queue_count > 0
                then case when s.yield_count = y.yield_count
                then ''Hung''
                else ''Active''
                end
                else  ''Idle''
                end  as status
                from sys.dm_os_schedulers s
                join @yield_count y on s.scheduler_id = y.scheduler_id
                end try
                begin catch
                select -100 as l1
                ,       ERROR_NUMBER() as dummy1
                ,       ERROR_SEVERITY() as dummy2
                ,       ERROR_STATE() as scheduler_id
                ,       ERROR_MESSAGE() as status
                end catch
              ',@params=N''
go
exec sp_executesql @stmt=N'
                begin try
                declare @yield_count table (
                scheduler_id varbinary(8)
                ,       yield_count int
                );
                declare @scheduler_health_table  table (
                rank_no int identity
                ,       status varchar(10) collate database_default
                ,       scheduler_id int
                ,       cpu_id smallint
                ,       is_online smallint
                ,       preemptive_switches_count int
                ,       context_switches_count int
                ,       idle_switches_count int
                ,       current_tasks_count int
                ,       runnable_tasks_count int
                ,       current_workers_count int
                ,       active_workers_count int
                ,       work_queue_count bigint
                ,       pending_disk_io int
                ,       load_factor int
                ,       is_preemptive bit
                ,       is_fiber bit
                ,       context_switch_count int
                ,       io_count int
                ,       state varchar(20) collate database_default
                ,       memory int
                ,       worker_address varbinary(8)
                ,       task_address varbinary(8)
                ,       spid int
                ,       proc_status varchar(20) collate database_default
                ,       hostname nvarchar(128) collate database_default
                ,       program_name nvarchar(128) collate database_default
                ,       text1 varchar(5000) collate database_default
                ,       task_ctx int
                ,       task_io int
                ,       worker_address_string varchar(18) collate database_default
                ,       task_address_string varchar(18)   collate database_default
                );

                insert into @yield_count (scheduler_id, yield_count)
                select scheduler_id, yield_count from sys.dm_os_schedulers ;

                insert into @scheduler_health_table
                select case when S.work_queue_count = 0 then ''Idle''
                else case when S.yield_count = Y.yield_count then ''Hung''
                else ''Active''
                end
                end as status
                ,   S.scheduler_id
                ,   S.cpu_id,is_online,S.preemptive_switches_count
                ,   S.context_switches_count
                ,       S.idle_switches_count
                ,       S.current_tasks_count
                ,   S.runnable_tasks_count
                ,       S.current_workers_count
                ,       S.active_workers_count
                ,       S.work_queue_count
                ,       S.pending_disk_io_count
                ,       S.load_factor
                ,       W.is_preemptive
                ,       W.is_fiber
                ,       W.context_switch_count
                ,       W.pending_io_count
                ,       W.state
                ,       M.max_pages_in_bytes as memory
                ,       W.worker_address
                ,       W.task_address
                ,       T.session_id
                ,       req.status as req_status
                ,       sessions.host_name
                ,       sessions.program_name
                ,       case when req.sql_handle is not null then ( select top 1 SUBSTRING(t2.text, (req.statement_start_offset + 2) / 2, ( (case when req.statement_end_offset = -1 then (len(convert(nvarchar(MAX),t2.text)) * 2) else req.statement_end_offset end)  - req.statement_start_offset) / 2)       from sys.dm_exec_sql_text(req.sql_handle) t2 ) else '''' end  as text1
                ,       T.context_switches_count as task_ctx
                ,       T.pending_io_count as task_io
                ,       master.dbo.fn_varbintohexstr(W.worker_address)
                ,       master.dbo.fn_varbintohexstr(W.task_address)
                from sys.dm_os_schedulers S
                join @yield_count Y on (S.scheduler_id = Y.scheduler_id)
                left outer join sys.dm_os_workers W  on (S.scheduler_address = W.scheduler_address)
                left outer join sys.dm_os_memory_objects M on(W.memory_object_address = M.memory_object_address)
                left outer join sys.dm_os_tasks T on (W.task_address = T.task_address)
                left outer join sys.dm_exec_sessions sessions on (T.session_id  = sessions.session_id)
                left outer join sys.dm_exec_requests req on (req.task_address = W.task_address);

                select (dense_rank() over(order by status, scheduler_id, cpu_id))%2 as l1
                ,       (dense_rank() over(order by status, scheduler_id, cpu_id,worker_address_string))%2 as l2
                ,       (dense_rank() over(order by status, scheduler_id, cpu_id,worker_address_string,spid))%2 as l3
                ,       *
                from @scheduler_health_table
                order by status, scheduler_id, cpu_id
                end try
                begin catch
                select -100 as l1
                ,       1 as l2,1 as l3,1 as rank_no, 1 as status, 1 as scheduler_id,1 as cpu_id,1 as is_online,1 as preemptive_switches_count,1 as context_switches_count,1 as idle_switches_count,1 as current_tasks_count,1 as runnable_tasks_count,1 as current_workers_count,1 as active_workers_count,1 as work_queue_count,1 as pending_disk_io,1 as load_factor,1 as is_preemptive,1 as is_fiber,1 as context_switch_count, 1 as io_count,1 as state,1 as memory,1 as worker_address,1 as task_address, 1 as spid,1 as proc_status,1 as hostname, 1 as program_name,1 as text1
                ,       ERROR_NUMBER() as task_ctx
                ,       ERROR_SEVERITY() as task_io
                ,       ERROR_STATE() as worker_address_string
                ,       ERROR_MESSAGE() as task_address_string
                end catch
              ',@params=N''