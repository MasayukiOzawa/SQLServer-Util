DECLARE @session_id int = 84
select
    ot.session_id,
    oth.os_thread_id,
    ot.request_id,
    ot.scheduler_id,
    ot.exec_context_id,
    es.host_name,
    es.program_name,
    er.query_hash,
    st.text,
    SUBSTRING(st.text, (er.statement_start_offset/2) + 1,  
    ((CASE statement_end_offset   
    WHEN -1 THEN DATALENGTH(ST.text)  
    ELSE er.statement_end_offset END   
        - er.statement_start_offset)/2) + 1) AS statement_text,
    er.query_plan_hash,
    qp.query_plan,
    oth.creation_time,
    es.login_time,
    es.last_request_start_time,
    es.last_request_end_time,
    es.login_name,
    es.status AS session_status,
    er.status AS request_status,
    ow.state,
    ot.task_state,
    er.wait_time,
    owt.wait_duration_ms,
    er.wait_type,
    er.last_wait_type,
    er.wait_resource,
    ow.last_wait_type,
    owt.wait_type,
    owt.resource_description,
    er.blocking_session_id as request_blocking_session_id,
    owt.blocking_session_id as waiting_tasks_blocking_session_id,
    owt.blocking_exec_context_id,
    ot.context_switches_count,
    ow.context_switch_count,
    oth.kernel_time,
    oth.usermode_time,
    es.total_scheduled_time,
    er.cpu_time,
    es.total_elapsed_time,
    er.total_elapsed_time,
    ot.pending_io_count as task_pending_io_count,
    ow.pending_io_count as worker_pending_io_count,
    ot.pending_io_byte_count as task_pending_io_byte_count,
    ow.pending_io_byte_count as worker_pending_io_byte_count,
    ot.pending_io_byte_average AS task_pending_io_byte_average,
    ow.pending_io_byte_average AS worker_pending_io_byte_average
from 
    sys.dm_os_tasks as ot
    inner join sys.dm_exec_sessions as es
        on es.session_id = ot.session_id
        and es.is_user_process = 1
    left join  sys.dm_os_workers as ow
        on ow.task_address = ot.task_address
    left join sys.dm_os_threads as oth
        on oth.thread_address = ow.thread_address
    left join sys.dm_os_waiting_tasks as owt
        on owt.waiting_task_address = ot.task_address
    left join sys.dm_exec_requests as er
        on er.session_id = ot.session_id
    outer apply sys.dm_exec_sql_text(er.sql_handle) as st
    outer apply sys.dm_exec_query_plan(er.plan_handle) as qp
where
    ot.session_id <> @@SPID
order by
    ot.session_id asc,
    ot.exec_context_id asc,
    owt.blocking_session_id asc,
    owt.blocking_exec_context_id asc
