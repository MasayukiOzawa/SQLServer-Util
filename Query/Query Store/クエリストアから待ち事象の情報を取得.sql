DECLARE @time int = -1

SELECT
	SWITCHOFFSET(rsi.start_time, DATEPART(tz, SYSDATETIMEOFFSET())) AS start_time,
	SWITCHOFFSET(rsi.end_time, DATEPART(tz, SYSDATETIMEOFFSET())) AS end_time,
	SWITCHOFFSET(rs.first_execution_time, DATEPART(tz, SYSDATETIMEOFFSET())) AS first_execution_time_local,
    SWITCHOFFSET(rs.last_execution_time, DATEPART(tz, SYSDATETIMEOFFSET())) AS last_execution_time_local, 
	sq.query_id,
	rs.plan_id,
	sq.query_text_id,
	rs.runtime_stats_id,
	rs.runtime_stats_interval_id,
	rs.execution_type_desc,
	ws.wait_category_desc,
	rs.count_executions,
	sp.count_compiles,
	rs.avg_duration / 1000 AS avg_duration_ms,
	rs.max_duration / 1000 AS max_duration_ms,
	rs.avg_cpu_time / 1000 AS avg_cpu_time_ms,
	rs.max_cpu_time / 1000 AS max_cpu_time_ms,
	ws.total_query_wait_time_ms,
	ws.avg_query_wait_time_ms,
	ws.last_query_wait_time_ms,
	rs.max_dop,
	rs.last_dop,
	st.query_sql_text,
	CAST(sp.query_plan AS xml) AS query_plan,
	sq.query_hash,
	sp.query_plan_hash
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
		ON ws.plan_id = rs.plan_id
		   AND ws.runtime_stats_interval_id = rs.runtime_stats_interval_id
WHERE 
	rs.last_execution_time >= DATEADD(hh,@time,CAST(SYSDATETIMEOFFSET() AS datetimeoffset))
ORDER BY 
	query_id ASC,
	SWITCHOFFSET(rsi.start_time, DATEPART(tz, SYSDATETIMEOFFSET())) DESC
