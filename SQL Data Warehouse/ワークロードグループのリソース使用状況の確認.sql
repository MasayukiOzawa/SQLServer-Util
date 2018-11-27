SELECT
	wg.pdw_node_id, 
	n.type,
	n.name,
	wg.name,
	rp.name,
	wg.importance,
	max_dop,
	effective_max_dop,
	max_memory_kb / 1024 * request_max_memory_grant_percent * 0.1 AS memory,
	wg.statistics_start_time,
	wg.total_request_count,
	wg.total_queued_request_count,
	wg.active_request_count,
	wg.queued_request_count,
	wg.total_cpu_limit_violation_count,
	wg.total_cpu_usage_ms,
	wg.max_request_cpu_time_ms,
	wg.blocked_task_count,
	wg.total_lock_wait_count,
	wg.total_lock_wait_time_ms,
	wg.total_query_optimization_count,
	wg.total_suboptimal_plan_generation_count,
	wg.total_reduced_memgrant_count,
	wg.max_request_grant_memory_kb,
	wg.active_parallel_thread_count,
	wg.request_max_memory_grant_percent,
	wg.request_max_cpu_time_sec,
	wg.request_memory_grant_timeout_sec,
	wg.group_max_requests,
	wg.max_dop,
	wg.effective_max_dop,
	wg.total_cpu_usage_preemptive_ms,
	rp.total_cpu_usage_ms,
	rp.cache_memory_kb,
	rp.compile_memory_kb,
	rp.used_memgrant_kb,
	rp.total_memgrant_count,
	rp.total_memgrant_timeout_count,
	rp.active_memgrant_count,
	rp.active_memgrant_kb,
	rp.memgrant_waiter_count,
	rp.max_memory_kb,
	rp.used_memory_kb,
	rp.target_memory_kb,
	rp.out_of_memory_count,
	rp.min_cpu_percent,
	rp.max_cpu_percent,
	rp.min_memory_percent,
	rp.max_memory_percent,
	rp.cap_cpu_percent,
	rp.total_cpu_usage_preemptive_ms
FROM 
	sys.dm_pdw_nodes_resource_governor_workload_groups wg
	LEFT JOIN
	sys.dm_pdw_nodes_resource_governor_resource_pools rp
	ON
	wg.pool_id = rp.pool_id
	AND
	wg.pdw_node_id = rp.pdw_node_id
	LEFT JOIN
	sys.dm_pdw_nodes n
	ON
	n.pdw_node_id = wg.pdw_node_id
WHERE 
	wg.name LIKE 'SloDW%'
