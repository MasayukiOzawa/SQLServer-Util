--sp_query_store_flush_db 


SELECT
	SWITCHOFFSET(rsi.start_time, DATEPART(tz, SYSDATETIMEOFFSET())) AS start_time,
	SWITCHOFFSET(rsi.end_time, DATEPART(tz, SYSDATETIMEOFFSET())) AS end_time,
	SWITCHOFFSET(rs.first_execution_time, DATEPART(tz, SYSDATETIMEOFFSET())) AS first_execution_time_local,
    SWITCHOFFSET(rs.last_execution_time, DATEPART(tz, SYSDATETIMEOFFSET())) AS last_execution_time_local, 
	st.query_sql_text,
	sq.query_hash,
	rs.* 
FROM 
	sys.query_store_runtime_stats rs
	INNER JOIN
	sys.query_store_runtime_stats_interval rsi
	ON
	rs.runtime_stats_interval_id = rsi.runtime_stats_interval_id
	INNER JOIN
	sys.query_store_plan sp
	ON
	sp.plan_id = rs.plan_id
	INNER JOIN
	sys.query_store_query sq
	ON
	sp.query_id = sq.query_id
	INNER JOIN
	sys.query_store_query_text st
	ON
	st.query_text_id = sq.query_text_id
WHERE 
	rs.last_execution_time >= DATEADD(hh,-1,CAST(SYSDATETIMEOFFSET() AS datetimeoffset))
	AND
	rs.avg_duration  >= 5000000
ORDER BY 
	SWITCHOFFSET(rsi.start_time, DATEPART(tz, SYSDATETIMEOFFSET())) DESC
