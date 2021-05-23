-- 最新の集計期間については、キャッシュの関係で同一時間軸が 2 レコード出力される可能性があるため、最新の情報については集計が完了したタイミングでの取得を検討

DECLARE @time int = -5 -- 直近 1 時間の情報を取得する場合は -1

DECLARE @start_time datetimeoffset = '2021-05-23 13:30:00.0000000 +09:00'
DECLARE @end_time datetimeoffset = '2021-05-23 14:00:00.0000000 +09:00'

DECLARE @query_id int = 2840
DECLARE @cpu_time_max int= (SELECT interval_length_minutes FROM sys.database_query_store_options)* 60 *1000 * (SELECT COUNT(*) FROM sys.dm_os_schedulers WHERE status = 'VISIBLE ONLINE')

SELECT TOP 300
    SWITCHOFFSET(rsi.start_time, DATEPART(tz, SYSDATETIMEOFFSET())) AS start_time,
    SWITCHOFFSET(rsi.end_time, DATEPART(tz, SYSDATETIMEOFFSET())) AS end_time,
    SWITCHOFFSET(rs.first_execution_time, DATEPART(tz, SYSDATETIMEOFFSET())) AS first_execution_time_local,
    SWITCHOFFSET(rs.last_execution_time, DATEPART(tz, SYSDATETIMEOFFSET())) AS last_execution_time_local, 
    sq.query_hash,
    sp.query_plan_hash,
    sq.query_id,
    rs.plan_id,
    sq.query_text_id,
    rs.runtime_stats_id,
    rs.runtime_stats_interval_id,
    rs.execution_type_desc,
    rs.count_executions,
    sp.count_compiles,
    ws.wait_category_desc,
    ws.total_query_wait_time_ms,
    ws.avg_query_wait_time_ms,
    ws.last_query_wait_time_ms,
    rs.avg_duration / 1000 AS avg_duration_ms,
    rs.min_duration / 1000 AS min_duration_ms,
    rs.max_duration / 1000 AS max_duration_ms,
    CAST((rs.avg_duration * rs.count_executions / 1000) AS BIGINT) AS total_duration_ms,
    rs.avg_cpu_time / 1000 AS avg_cpu_time_ms,
    rs.min_cpu_time / 1000 AS min_cpu_time_ms,
    rs.max_cpu_time / 1000 AS max_cpu_time_ms,
    CAST((rs.avg_cpu_time * rs.count_executions / 1000) AS BIGINT) AS total_cpu_time_ms,
    CAST((rs.avg_cpu_time * rs.count_executions / 1000 / @cpu_time_max * 100) AS numeric(6,3)) AS cpu_usage_percent,
    rs.avg_logical_io_reads,
    rs.min_logical_io_reads,
    rs.max_logical_io_reads,
    rs.avg_logical_io_writes,
    rs.min_logical_io_writes,
    rs.max_logical_io_writes,
    rs.avg_log_bytes_used,
    rs.min_log_bytes_used,
    rs.max_log_bytes_used,
    rs.avg_rowcount,
    rs.min_rowcount,
    rs.max_rowcount,
    rs.max_dop,
    rs.last_dop,
    st.query_sql_text,
    CAST(sp.query_plan AS xml) AS query_plan
FROM 
    sys.query_store_runtime_stats rs
    INNER JOIN sys.query_store_runtime_stats_interval rsi
        ON rs.runtime_stats_interval_id = rsi.runtime_stats_interval_id
    INNER JOIN sys.query_store_plan sp
        ON sp.plan_id = rs.plan_id
    INNER JOIN sys.query_store_query sq
        ON sp.query_id = sq.query_id
    INNER JOIN sys.query_store_query_text st
        ON st.query_text_id = sq.query_text_id
    LEFT JOIN sys.query_store_wait_stats AS ws
        ON ws.plan_id = rs.plan_id AND ws.runtime_stats_interval_id = rs.runtime_stats_interval_id AND rs.execution_type = ws.execution_type
WHERE    
    rs.last_execution_time >= DATEADD(hh,@time,CAST(SYSDATETIMEOFFSET() AS datetimeoffset))
    -- AND rsi.start_time >= @start_time AND rsi.end_time <= @end_time
    -- AND rs.execution_type <> 0 -- Aborted しているクエリを取得する場合
    -- AND sq.query_id = @query_id
ORDER BY 
    -- total_cpu_time_ms DESC,
    -- query_id ASC,
    SWITCHOFFSET(rsi.start_time, DATEPART(tz, SYSDATETIMEOFFSET())) DESC