SELECT
	p.query_id,
	p.plan_id,
	rsi.start_time,
	rsi.end_time,
	rs.first_execution_time,
	rs.last_execution_time,
	p.last_execution_time,
	rs.avg_dop,
	rs.last_dop,
	rs.min_dop,
	rs.max_dop,
	rs.stdev_dop
FROM
	sys.query_store_plan AS p
	LEFT JOIN
		sys.query_store_runtime_stats AS rs
	ON
		rs.plan_id = p.plan_id
	LEFT JOIN
		sys.query_store_runtime_stats_interval rsi
	ON
		rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id 
WHERE
	is_parallel_plan = 1
	AND
	rsi.start_time >= DATEADD(dd, -1, GETUTCDATE())
ORDER BY
	start_time ASC