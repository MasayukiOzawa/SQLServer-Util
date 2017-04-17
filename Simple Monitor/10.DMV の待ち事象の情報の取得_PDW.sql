/*
DROP TABLE #T1
DROP TABLE #T2
*/

SELECT
	GETDATE() AS counter_date,
	*
INTO #T1
FROM
	sys.dm_pdw_nodes_os_wait_stats
WHERE
	waiting_tasks_count > 0

SELECT
	GETDATE() AS counter_date,
	*
INTO #T2
FROM
	sys.dm_pdw_nodes_os_wait_stats
WHERE
	waiting_tasks_count > 0

SELECT
	#T2.counter_date,
	#T2.pdw_node_id,
	n.type,
	#T2.wait_type,
	CAST((#T2.waiting_tasks_count - #T1.waiting_tasks_count) / (DATEDIFF(ms, #T1.counter_date, #T2.counter_date) / 1000.0) AS bigint) AS waiting_tasks_count,
	CAST((#T2.wait_time_ms - #T1.wait_time_ms) / (DATEDIFF(ms, #T1.counter_date, #T2.counter_date) / 1000.0) AS bigint) AS wait_time_ms,
	#T2.max_wait_time_ms,
	CAST((#T2.signal_wait_time_ms - #T1.signal_wait_time_ms) / (DATEDIFF(ms, #T1.counter_date, #T2.counter_date) / 1000.0) AS bigint) AS signal_wait_time_ms
FROM
	#T2
	LEFT JOIN
	#T1
	ON
	#T1.wait_type = #T2.wait_Type
	LEFT JOIN
	sys.dm_pdw_nodes n
	ON
	n.pdw_node_id = #T2.pdw_node_id
WHERE
	#T2.waiting_tasks_count - #T1.waiting_tasks_count > 0
	AND
	#T2.wait_type <> 'WAITFOR'
	AND
	#T2.pdw_node_id = #T1.pdw_node_id
ORDER BY
	n.type DESC,
	#T2.pdw_node_id ASC