DECLARE @spid int = 209
DECLARE @program_name sysname = N'SQLQueryStress'
SELECT
    ot.session_id,
    ot.exec_context_id,
    (SELECT DATEADD(SECOND, -1 * (ms_ticks - ow.start_quantum) / 1000, GETDATE()) FROM sys.dm_os_sys_info) AS worker_running_start_time,
    (SELECT DATEADD(SECOND, -1 * (ms_ticks - ow.wait_started_ms_ticks) / 1000, GETDATE()) FROM sys.dm_os_sys_info) AS wait_start_time,
    ot.task_state,
    ow.state,
    er.wait_type,
    er.wait_resource,
    ow.last_wait_type,
    er.last_wait_type,
    er.wait_time, -- ms
    ot.context_switches_count AS tasks_context_switches_count,
    ow.context_switch_count AS worker_context_switch_count,
    ow.start_quantum,
    ow.wait_started_ms_ticks
FROM
    sys.dm_os_tasks AS ot
    INNER JOIN sys.dm_os_workers AS ow
        ON ow.worker_address = ot.worker_address
    INNER JOIN sys.dm_exec_requests AS er
        ON er.session_id = ot.session_id
    LEFT JOIN sys.dm_exec_sessions AS es
        ON es.session_id = ot.session_id
WHERE
    ot.session_id = @spid
    OR es.program_name = @program_name
ORDER BY
    ot.task_state DESC
;
SELECT 
    wait_type,
    waiting_tasks_count, 
    wait_time_ms,
    signal_wait_time_ms,
    max_wait_time_ms,
    wait_time_ms / waiting_tasks_count AS avg_wait_time_ms
FROM 
    sys.dm_exec_session_wait_stats
WHERE 
    session_id = @spid
SELECT * FROM sys.dm_os_waiting_tasks WHERE session_id = @spid

;

select 
    wt.session_id,
    wt.wait_type,
    wt.exec_context_id, 
    wt.wait_duration_ms,
    ws.max_wait_time_ms
from 
    sys.dm_os_waiting_tasks  AS wt
    INNER JOIN sys.dm_exec_sessions AS es
        On es.session_id = wt.session_id
            AND es.is_user_process = 1
    INNER JOIN sys.dm_os_wait_Stats AS ws
        On ws.wait_type = wt.wait_type
ORDER BY
    wt.wait_type ASC, wt.session_id ASC
