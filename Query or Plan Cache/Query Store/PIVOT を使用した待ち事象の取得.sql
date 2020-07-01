DECLARE @query_id int = 7205;
DECLARE @time int = -1

SELECT
    *
FROM
(
SELECT
    rs.first_execution_time,
    rs.last_execution_time,
    rs.plan_id,
    sp.query_id,
    rs.avg_duration,
    rs.max_duration,
    ws.wait_category_desc,
    ws.execution_type_desc,
    ws.total_query_wait_time_ms
    --ws.avg_query_wait_time_ms
    --ws.last_query_wait_time_ms
    --ws.min_query_wait_time_ms
    --ws.max_query_wait_time_ms
    --ws.stdev_query_wait_time_ms
FROM 
    sys.query_store_runtime_stats rs
    INNER JOIN sys.query_store_runtime_stats_interval rsi
         ON rs.runtime_stats_interval_id = rsi.runtime_stats_interval_id
    INNER JOIN sys.query_store_plan sp
        ON sp.plan_id = rs.plan_id
         AND sp.query_id = @query_id
    INNER JOIN sys.query_store_wait_stats AS ws
        ON ws.plan_id = rs.plan_id
        AND ws.runtime_stats_interval_id = rs.runtime_stats_interval_id
        AND ws.execution_type_desc = 'Aborted'
WHERE
    rs.last_execution_time >= DATEADD(hh,@time,CAST(SYSDATETIMEOFFSET() AS datetimeoffset))
) AS T
PIVOT
(
    MAX(total_query_wait_time_ms)
    FOR wait_category_desc IN ([Unknown], [CPU], [Worker Thread], [Lock], [Latch], [Buffer Latch], [Buffer IO], [Compilation], [SQL CLR], [Mirroring], [Transaction], [Idle], [Preemptive], [Service Broker], [Tran Log IO], [Network IO], [Parallelism], [Memory], [User Wait], [Tracing])
) AS PVT
