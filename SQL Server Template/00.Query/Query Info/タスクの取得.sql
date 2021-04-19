SELECT
    t.session_id,
    t.exec_context_id,
    t.request_id,
    th.os_thread_id,
    s.host_name,
    s.program_name,
    s.login_name,
    t.scheduler_id,
    th.os_thread_id,
    FORMAT(os_thread_id,'X') AS os_thread_id_hex,
    r.start_time,
    s.last_request_start_time,
    s.last_request_end_time,
    r.command AS rquest_command,
    r.status AS requst_status,
    t.task_state,
    w.state AS worker_state,
    r.blocking_session_id AS request_blocking_session_id,
    r.wait_type AS request_wait_type,
    r.last_wait_type AS request_last_wait_type,
    r.wait_resource AS rquest_wait_resource,
    r.wait_time AS request_wait_time,
    r.total_elapsed_time,
    wt.blocking_session_id AS waiting_tasks_blocking_session_id,
    wt.blocking_exec_context_id AS waiting_tasks_blocking_exec_context_id,
    wt.wait_type AS waiting_tasks_wait_type,
    wt.wait_duration_ms AS waiting_tasks_duration_ms,
    wt.resource_description AS waiting_tasks_resource_description,
    w.last_wait_type AS worker_last_wait_type,
    s.open_transaction_count,
    r.cpu_time,
    r.dop,
    th.kernel_time,
    th.usermode_time,
    t.context_switches_count,
    r.reads,
    r.writes,
    r.logical_reads,
    t.pending_io_byte_count,
    t.pending_io_byte_average,
    w.worker_migration_count,
    w.is_preemptive,
    w.quantum_used,
    th.started_by_sqlservr,
    r.sql_handle,
    r.plan_handle,
    txt.text,
    p.query_plan
FROM
    sys.dm_os_tasks AS t
    LEFT JOIN sys.dm_exec_requests AS r on r.session_id = t.session_id
    LEFT JOIN sys.dm_exec_sessions AS s on s.session_id = t.session_id
    LEFT JOIN sys.dm_os_waiting_tasks AS wt ON wt.waiting_task_address = t.task_address AND wt.session_id = t.session_id
    LEFT JOIN sys.dm_os_workers AS w ON w.worker_address = t.worker_address
    LEFT JOIN sys.dm_os_threads AS th ON th.thread_address = w.thread_address
    OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS txt
    OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) AS p
WHERE
    s.is_user_process = 1
    AND t.session_id <> @@SPID
ORDER BY
    t.session_id ASC,
    t.exec_context_id ASC,
    t.request_id ASC,
    wt.blocking_session_id ASC,
    wt.blocking_exec_context_id ASC
GO
