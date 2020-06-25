SET NOCOUNT ON

WHILE(0=0)
BEGIN

INSERT INTO session_wait_dump
SELECT
    *
FROM
(
    SELECT
        GETDATE() AS collect_date,
        s.session_id,
        s.host_name,
        s.program_name,
        r.wait_type,
        r.last_wait_type,
        r.wait_resource,
        r.wait_time,
        s.login_name,
        s.status,
        s.cpu_time AS session_cpu_time,
        r.cpu_time AS request_cpu_time,
        s.memory_usage,
        r.granted_query_memory,
        s.total_scheduled_time,
        s.total_elapsed_time AS session_total_elapsed_time,
        r.total_elapsed_time AS request_total_elapsed_time,
        s.reads AS session_reads,
        r.reads AS request_reads,
        s.writes AS session_writes,
        r.writes AS request_writes,
        s.logical_reads AS session_logical_reads,
        r.logical_reads AS request_logical_reads,
        r.dop,
        r.query_hash,
        r.query_plan_hash,
        s.login_time,
        r.start_time,
        s.last_request_start_time,
        s.last_request_end_time,
        (
            SELECT wait_type, waiting_tasks_count,wait_time_ms, max_wait_time_ms, signal_wait_time_ms 
            FROM sys.dm_exec_session_wait_stats WHERE session_id = s.session_id FOR JSON AUTO
        ) AS wait_info
    FROM
        sys.dm_exec_sessions AS s
        LEFT JOIN sys.dm_exec_requests AS r
            ON r.session_id = s.session_id
    WHERE
        s.session_id <> @@SPID
        AND
        s.is_user_process = 1
) AS T
WAITFOR DELAY '00:00:01'
END