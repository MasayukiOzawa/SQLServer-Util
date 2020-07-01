--sp_query_store_flush_db
 
SELECT
	SWITCHOFFSET(rsi.start_time, DATEPART(tz, SYSDATETIMEOFFSET())) AS start_time,
	SWITCHOFFSET(rsi.end_time, DATEPART(tz, SYSDATETIMEOFFSET())) AS end_time,
	SWITCHOFFSET(rs.first_execution_time, DATEPART(tz, SYSDATETIMEOFFSET())) AS first_execution_time_local,
	SWITCHOFFSET(rs.last_execution_time, DATEPART(tz, SYSDATETIMEOFFSET())) AS last_execution_time_local,
	st.query_sql_text,
	sq.query_hash,
	rs.runtime_stats_id,
   sq.query_id,
	rs.plan_id,
	rs.runtime_stats_interval_id,
	rs.execution_type,
	rs.execution_type_desc,
	rs.first_execution_time,
	rs.last_execution_time,
	rs.count_executions,
	(rs.avg_duration / 1000.0) AS avg_duration_ms,
	(rs.last_duration / 1000.0) AS last_duration_ms,
	(rs.min_duration / 1000.0) AS min_duration_ms,
	(rs.max_duration / 1000.0) AS max_duration_ms,
	(rs.stdev_duration / 1000.0) AS stdev_duration_ms,
	(rs.avg_cpu_time / 1000.0) AS avg_cpu_time_ms,
	(rs.last_cpu_time / 1000.0) AS last_cpu_time_ms,
	(rs.min_cpu_time / 1000.0) AS min_cpu_time_ms,
	(rs.max_cpu_time / 1000.0) AS max_cpu_time_ms,
	rs.stdev_cpu_time,
	rs.avg_logical_io_reads,
	rs.last_logical_io_reads,
	rs.min_logical_io_reads,
	rs.max_logical_io_reads,
	rs.stdev_logical_io_reads,
	rs.avg_logical_io_writes,
	rs.last_logical_io_writes,
	rs.min_logical_io_writes,
	rs.max_logical_io_writes,
	rs.stdev_logical_io_writes,
	rs.avg_physical_io_reads,
	rs.last_physical_io_reads,
	rs.min_physical_io_reads,
	rs.max_physical_io_reads,
	rs.stdev_physical_io_reads,
	rs.avg_clr_time,
	rs.last_clr_time,
	rs.min_clr_time,
	rs.max_clr_time,
	rs.stdev_clr_time,
	rs.avg_dop,
	rs.last_dop,
	rs.min_dop,
	rs.max_dop,
	rs.stdev_dop,
	rs.avg_query_max_used_memory,
	rs.last_query_max_used_memory,
	rs.min_query_max_used_memory,
	rs.max_query_max_used_memory,
	rs.stdev_query_max_used_memory,
	rs.avg_rowcount,
	rs.last_rowcount,
	rs.min_rowcount,
	rs.max_rowcount,
	rs.stdev_rowcount,
	rs.avg_num_physical_io_reads,
	rs.last_num_physical_io_reads,
	rs.min_num_physical_io_reads,
	rs.max_num_physical_io_reads,
	rs.stdev_num_physical_io_reads,
	rs.avg_log_bytes_used,
	rs.last_log_bytes_used,
	rs.min_log_bytes_used,
	rs.max_log_bytes_used,
	rs.stdev_log_bytes_used,
	rs.avg_tempdb_space_used,
	rs.last_tempdb_space_used,
	rs.min_tempdb_space_used,
	rs.max_tempdb_space_used,
	rs.stdev_tempdb_space_used
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
	AND rs.execution_type <> 0
ORDER BY
	SWITCHOFFSET(rsi.start_time, DATEPART(tz, SYSDATETIMEOFFSET())) DESC

