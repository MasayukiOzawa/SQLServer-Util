SET NOCOUNT ON

WHILE(0=0)
BEGIN

INSERT INTO dump_os_task
SELECT *
FROM
(
SELECT
    getdate() AS collect_date,
    ot.session_id,
    oth.os_thread_id,
    ot.request_id,
    ot.scheduler_id,
    ot.exec_context_id,
    es.status AS session_status,
    er.status AS request_status,
    ow.state,
    ot.task_state,
    CASE ow.return_code
        WHEN 0  THEN 'SUCCESS'
        WHEN 3 THEN 'DEADLOCK'
        WHEN 4 THEN 'PREMATURE_WAKEUP'
        WHEN 258 THEN 'TIMEOUT'
        ELSE ''
    END AS return_code,
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
    -- qp.query_plan,
    oth.creation_time,
    es.login_time,
    es.last_request_start_time,
    es.last_request_end_time,
    es.login_name,
    er.wait_time,
    owt.wait_duration_ms,
    er.wait_type AS request_wait_type,
    er.last_wait_type AS request_last_wait_type,
    er.wait_resource AS request_wait_resource,
    ow.last_wait_type AS worker_last_wait_type,
    owt.wait_type AS waiting_task_wait_type,
    owt.resource_description AS waiting_task_resource_description,
    er.blocking_session_id AS request_blocking_session_id,
    owt.blocking_session_id AS waiting_tasks_blocking_session_id,
    owt.blocking_exec_context_id,
    ot.context_switches_count,
    ow.context_switch_count,
    oth.kernel_time,
    oth.usermode_time,
    es.total_scheduled_time,
    er.cpu_time,
    es.total_elapsed_time AS session_total_elapsed_time,
    er.total_elapsed_time AS request_total_elapsed_time,
    oth.stack_bytes_committed,
    oth.stack_bytes_used,
    ot.pending_io_count AS task_pending_io_count,
    ow.pending_io_count AS worker_pending_io_count,
    ot.pending_io_byte_count AS task_pending_io_byte_count,
    ow.pending_io_byte_count AS worker_pending_io_byte_count,
    ot.pending_io_byte_average AS task_pending_io_byte_average,
    ow.pending_io_byte_average AS worker_pending_io_byte_average
from 
    sys.dm_os_tasks AS ot
    INNER JOIN sys.dm_exec_sessions AS es
        on es.session_id = ot.session_id
        and es.is_user_process = 1
    INNER JOIN  sys.dm_os_workers AS ow
        on ow.task_address = ot.task_address
    INNER JOIN sys.dm_os_threads AS oth
        on oth.thread_address = ow.thread_address
    INNER JOIN sys.dm_os_waiting_tasks AS owt
        on owt.waiting_task_address = ot.task_address
    INNER JOIN sys.dm_exec_requests AS er
        on er.session_id = ot.session_id
    OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) AS st
    OUTER APPLY sys.dm_exec_query_plan(er.plan_handle) AS qp
WHERE
    ot.session_id <> @@SPID
) AS T

WAITFOR DELAY '00:00:01'

END
