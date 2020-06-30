DROP TABLE IF EXISTS dump_session_wait
GO

SELECT
    *
INTO dump_session_wait
FROM
(
SELECT
    GETDATE() AS collect_date,
    es.session_id,
    es.host_name,
    es.program_name,
    er.blocking_session_id,
    er.wait_type,
    er.last_wait_type,
    er.wait_resource,
    er.wait_time,
    es.login_name,
    es.status,
    es.cpu_time AS session_cpu_time,
    er.cpu_time AS request_cpu_time,
    es.memory_usage,
    er.granted_query_memory,
    es.total_scheduled_time,
    es.total_elapsed_time AS session_total_elapsed_time,
    er.total_elapsed_time AS request_total_elapsed_time,
    es.reads AS session_reads,
    er.reads AS request_reads,
    es.writes AS session_writes,
    er.writes AS request_writes,
    es.logical_reads AS session_logical_reads,
    er.logical_reads AS request_logical_reads,
    er.dop,
    er.query_hash,
    st.text,
    SUBSTRING(st.text, (er.statement_start_offset/2) + 1,  
    ((CASE statement_end_offset   
    WHEN -1 THEN DATALENGTH(ST.text)  
    ELSE er.statement_end_offset END   
        - er.statement_start_offset)/2) + 1) AS statement_text,
    er.query_plan_hash,
    es.login_time,
    er.start_time,
    es.last_request_start_time,
    es.last_request_end_time,
    (
        SELECT wait_type, waiting_tasks_count,wait_time_ms, max_wait_time_ms, signal_wait_time_ms 
        FROM sys.dm_exec_session_wait_stats WHERE session_id = es.session_id FOR JSON AUTO
    ) AS wait_info
FROM
    sys.dm_exec_sessions AS es
    INNER JOIN sys.dm_exec_requests AS er
        ON er.session_id = es.session_id
    OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) AS st
WHERE
    es.session_id <> @@SPID
    AND
    es.is_user_process = 1
) AS T

CREATE CLUSTERED COLUMNSTORE INDEX CCIX_session_wait_dump ON dump_session_wait
CREATE INDEX CIX_session_wait_dump_collect_date ON dump_session_wait (collect_date) WITH (DATA_COMPRESSION=PAGE)
CREATE INDEX NCIX_session_wait_dump_program_name ON dump_session_wait (program_name) WITH (DATA_COMPRESSION=PAGE)


