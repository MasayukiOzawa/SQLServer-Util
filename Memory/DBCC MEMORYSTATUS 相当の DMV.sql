/*
SET NOCOUNT ON
DBCC MEMORYSTATUS
*/
-- https://learn.microsoft.com/ja-jp/troubleshoot/sql/database-engine/performance/dbcc-memorystatus-monitor-memory-usage
-- https://support.microsoft.com/ja-jp/topic/dbcc-memorystatus-%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89%E3%82%92%E4%BD%BF%E7%94%A8%E3%81%97%E3%81%A6-sql-server-2005-%E3%81%AE%E3%83%A1%E3%83%A2%E3%83%AA%E4%BD%BF%E7%94%A8%E9%87%8F%E3%82%92%E7%9B%A3%E8%A6%96%E3%81%99%E3%82%8B%E6%96%B9%E6%B3%95-05462bbc-47a9-b893-9969-c5040c30a7ca


-- Process/System Counts
SELECT 
	GETDATE() AS collect_date,
	'sys.dm_os_sys_memory' AS info,
	total_physical_memory_kb / 1024 AS total_physical_memory_mb,
	available_physical_memory_kb /1024 AS available_physical_memory_mb,
	total_page_file_kb / 1024 AS total_page_file_mb,
	available_page_file_kb / 1024 AS available_page_file_mb,
	system_cache_kb / 1024 AS system_cache_mb,
	kernel_paged_pool_kb / 1024 AS kernel_paged_pool_mb,
	kernel_nonpaged_pool_kb / 1024 AS kernel_nonpaged_pool_mb,
	system_high_memory_signal_state,
	system_low_memory_signal_state,
	system_memory_state_desc
FROM 
	sys.dm_os_sys_memory

-- Memory Manager
SELECT
	GETDATE() AS collect_date,
	'sys.dm_os_process_memory' AS info,
	physical_memory_in_use_kb / 1024 AS physical_memory_in_use_mb,
	large_page_allocations_kb / 1024 AS large_page_allocations_mb,
	locked_page_allocations_kb / 1024 AS locked_page_allocations_mb,
	total_virtual_address_space_kb / 1024 AS total_virtual_address_space_mb,
	virtual_address_space_reserved_kb / 1024 AS virtual_address_space_reserved_mb,
	virtual_address_space_committed_kb / 1024 AS virtual_address_space_committed_mb,
	virtual_address_space_available_kb / 1024 AS virtual_address_space_available_mb,
	page_fault_count,
	memory_utilization_percentage,
	available_commit_limit_kb / 1024 AS available_commit_limit_mn,
	process_physical_memory_low,
	process_virtual_memory_low
FROM 
	sys.dm_os_process_memory

-- Memory Nodes
SELECT
	GETDATE() AS collect_date,
	'sys.dm_os_memory_nodes' AS info,
	memory_node_id,
	virtual_address_space_reserved_kb / 1024 AS virtual_address_space_reserved_mb,
	virtual_address_space_committed_kb / 1024 AS virtual_address_space_committed_mb,
	locked_page_allocations_kb / 1024 AS locked_page_allocations_mb,
	pages_kb / 1024 AS pages_mb,
	shared_memory_reserved_kb / 1024 AS shared_memory_reserved_mb,
	shared_memory_committed_kb / 1024 AS shared_memory_committed_mb,
	cpu_affinity_mask,
	online_scheduler_mask,
	processor_group,
	foreign_committed_kb / 1024 AS foreign_committed_mb,
	target_kb / 1024 AS target_mb
FROM 
	sys.dm_os_memory_nodes
ORDER BY
	memory_node_id

-- Memory Clerks
SELECT 
	GETDATE() AS collect_date,
	'sys.dm_os_memory_clerks'  AS info,
	type, memory_node_id,
	SUM(pages_kb) / 1024 AS pages_mb,
	SUM(virtual_memory_reserved_kb) / 1024 AS virtual_memory_reserved_mb, 
	SUM(virtual_memory_committed_kb) / 1024 AS virtual_memory_committed_mb , 
	SUM(awe_allocated_kb) / 1024 AS awe_allocated_mb, 
	SUM(shared_memory_reserved_kb) / 1024 AS shared_memory_reserved_mb, 
	SUM(shared_memory_committed_kb) / 1024 AS shared_memory_committed_mb
FROM 
	sys.dm_os_memory_clerks 
GROUP BY
	type, memory_node_id
ORDER BY 
	type, memory_node_id

SELECT 
	GETDATE() AS collect_date,
	'sys.dm_os_memory_clerks_summary'  AS info,
	type,
	SUM(pages_kb) / 1024 AS pages_mb,
	SUM(virtual_memory_reserved_kb) / 1024 AS virtual_memory_reserved_mb, 
	SUM(virtual_memory_committed_kb) / 1024 AS virtual_memory_committed_mb , 
	SUM(awe_allocated_kb) / 1024 AS awe_allocated_mb, 
	SUM(shared_memory_reserved_kb) / 1024 AS shared_memory_reserved_mb, 
	SUM(shared_memory_committed_kb) / 1024 AS shared_memory_committed_mb
FROM 
	sys.dm_os_memory_clerks 
GROUP BY
	type
ORDER BY 
	type

-- Memory Broker
SELECT 
	GETDATE() AS collect_date,
	'sys.dm_os_memory_brokers' AS info,
	pool_id,
	memory_broker_type,
	allocations_kb / 1024 AS allocations_mb,
	allocations_kb_per_sec,
	predicted_allocations_kb / 1024 AS predicted_allocations_mb,
	target_allocations_kb / 1024 AS target_allocations_mb,
	future_allocations_kb / 1024 AS future_allocations_mb,
	overall_limit_kb / 1024 AS overall_limit_mb,
	last_notification 
FROM 
	sys.dm_os_memory_brokers 
ORDER BY 
	pool_id, memory_broker_type

-- Memory Broker Clerk
SELECT 
	GETDATE() AS collect_date,
	'sys.dm_os_memory_broker_clerks' AS info,
	clerk_name,
	total_kb / 1024 AS total_mb,
	simulated_kb / 1024 AS simulated_mb,
	simulation_benefit,
	internal_benefit,
	external_benefit,
	value_of_memory,
	periodic_freed_kb / 1024 AS		periodic_freed_mb,
	internal_freed_kb / 1024 AS internal_freed_mb
FROM 
	sys.dm_os_memory_broker_clerks

-- Clock hands
SELECT
	GETDATE() AS collect_date,
	'sys.dm_os_memory_cache_clock_hands' AS info,
	name, type, clock_hand, clock_status,
	SUM(rounds_count) AS rounds_count,
	SUM(removed_all_rounds_count) AS removed_all_rounds_count,
	SUM(updated_last_round_count) AS updated_last_round_count,
	SUM(removed_last_round_count) AS removed_last_round_count,
	SUM(last_tick_time) AS last_tick_time,
	SUM(round_start_time) AS round_start_time,
	SUM(last_round_start_time) AS last_round_start_time,
	SUM(entries_visited_all_rounds_count) AS entries_visited_all_rounds_count,
	SUM(inuse_all_rounds_count) AS inuse_all_rounds_count,
	SUM(pinned_all_rounds_count) AS pinned_all_rounds_count,
	SUM(do_not_remove_all_rounds_count) AS do_not_remove_all_rounds_count,
	SUM(invisible_all_rounds_count) AS invisible_all_rounds_count,
	SUM(different_pool_all_rounds_count) AS different_pool_all_rounds_count
FROM 
	sys.dm_os_memory_cache_clock_hands 
WHERE
	type <> 'USERSTORE_TOKENPERM'
GROUP BY 
	name, type, clock_hand, clock_status
ORDER BY
	name, type, clock_hand, clock_status

-- Memory Gateway
SELECT 
	GETDATE() AS collect_date,
	'sys.dm_exec_query_optimizer_memory_gateways' AS info,
	pool_id,
	name,
	max_count,
	active_count,
	waiter_count,
	threshold_factor,
	threshold,
	is_active
FROM 
	sys.dm_exec_query_optimizer_memory_gateways
ORDER BY
	pool_id, name

-- Memory Grants
SELECT 
	GETDATE() AS collect_date,
	'sys.dm_resource_governor_resource_pools' AS info, 
	pool_id	name,
	statistics_start_time,
	total_cpu_usage_ms,
	cache_memory_kb / 1024 AS cache_memory_mb,
	compile_memory_kb / 1024 AS compile_memory_mb,
	used_memgrant_kb / 1024 ASused_memgrant_mb,
	total_memgrant_count,
	total_memgrant_timeout_count,
	active_memgrant_count,
	active_memgrant_kb / 1024 AS active_memgrant_mb,
	memgrant_waiter_count,
	max_memory_kb / 1024 AS max_memory_mb,
	used_memory_kb / 1024 AS used_memory_mb,
	target_memory_kb / 1024 AS target_memory_mb,
	out_of_memory_count,
	min_cpu_percent,
	max_cpu_percent,
	min_memory_percent,
	max_memory_percent,
	cap_cpu_percent,
	min_iops_per_volume,
	max_iops_per_volume,
	read_io_queued_total,
	read_io_issued_total,
	read_io_completed_total,
	read_io_throttled_total,
	read_bytes_total,
	read_io_stall_total_ms,
	read_io_stall_queued_ms,
	write_io_queued_total,
	write_io_issued_total,
	write_io_completed_total,
	write_io_throttled_total,
	write_bytes_total,
	write_io_stall_total_ms,
	write_io_stall_queued_ms,
	io_issue_violations_total,
	io_issue_delay_total_ms,
	io_issue_ahead_total_ms,
	reserved_io_limited_by_volume_total,
	io_issue_delay_non_throttled_total_ms,
	total_cpu_delayed_ms,
	total_cpu_active_ms,
	total_cpu_violation_delay_ms,
	total_cpu_violation_sec,
	total_cpu_usage_preemptive_ms
FROM 
	sys.dm_resource_governor_resource_pools
ORDER BY
	pool_id


SELECT 
	GETDATE() AS collect_date,
	'sys.dm_resource_governor_workload_groups' AS info,
	group_id,
	name,
	pool_id,
	external_pool_id,
	statistics_start_time,
	total_request_count,
	total_queued_request_count,
	active_request_count,
	queued_request_count,
	total_cpu_limit_violation_count,
	total_cpu_usage_ms,
	max_request_cpu_time_ms,
	blocked_task_count,
	total_lock_wait_count,
	total_lock_wait_time_ms,
	total_query_optimization_count,
	total_suboptimal_plan_generation_count,
	total_reduced_memgrant_count,
	max_request_grant_memory_kb / 1024 AS max_request_grant_memory_mb,
	active_parallel_thread_count,
	importance,
	request_max_memory_grant_percent,
	request_max_cpu_time_sec,
	request_memory_grant_timeout_sec,
	group_max_requests,
	max_dop,
	effective_max_dop,
	total_cpu_usage_preemptive_ms,
	request_max_memory_grant_percent_numeric
FROM 
	sys.dm_resource_governor_workload_groups
ORDER BY
	group_id


SELECT 
	GETDATE() AS collect_date,
	'sys.dm_exec_query_resource_semaphores' AS info,
	pool_id,
	resource_semaphore_id,
	target_memory_kb / 1024 AS target_memory_mb,
	max_target_memory_kb / 1024 AS max_target_memory_mb,
	total_memory_kb / 1024 AS total_memory_mb,
	available_memory_kb / 1024 AS available_memory_mb,
	granted_memory_kb / 1024 AS granted_memory_mb,
	used_memory_kb / 1024 AS used_memory_mb,
	grantee_count,
	waiter_count,
	timeout_error_count,
	forced_grant_count
FROM 
	sys.dm_exec_query_resource_semaphores
ORDER BY
	pool_id, resource_semaphore_id
	
SELECT 
	GETDATE() AS collect_date,
	'sys.dm_exec_query_memory_grants_summary' AS info,
	SUM(requested_memory_kb) / 1024 AS requested_memory_mb,
	SUM(granted_memory_kb) / 1024 AS granted_memory_mb,
	SUM(required_memory_kb) / 1024 AS required_memory_mb,
	SUM(used_memory_kb) / 1024 AS used_memory_mb,
	SUM(max_used_memory_kb) / 1024 AS max_used_memory_mb,
	SUM(ideal_memory_kb) / 1024 AS ideal_memory_mb
FROM
	sys.dm_exec_query_memory_grants

/*
SELECT 
	GETDATE() AS collect_date,
	session_id,
	request_id,
	scheduler_id,
	dop,
	request_time,
	grant_time,
	requested_memory_kb / 1024 AS requested_memory_mb,
	granted_memory_kb / 1024 AS granted_memory_mb,
	required_memory_kb / 1024 AS required_memory_mb,
	used_memory_kb / 1024 AS used_memory_mb,
	max_used_memory_kb / 1024 AS max_used_memory_mb,
	query_cost,
	timeout_sec,
	resource_semaphore_id,
	queue_id,
	wait_order,
	is_next_candidate,
	wait_time_ms,
	plan_handle,
	sql_handle,
	group_id,
	pool_id,
	is_small,
	ideal_memory_kb / 1024 AS ideal_memory_mb,
	reserved_worker_count,
	used_worker_count,
	max_used_worker_count,
	reserved_node_bitmap
FROM
	sys.dm_exec_query_memory_grants
ORDER BY
	session_id, request_id
*/