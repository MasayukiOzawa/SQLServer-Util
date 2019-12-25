SELECT 
	t.session_id,
	wg.name,
	DB_NAME(r.database_id) AS database_name,
	s.login_name,
	USER_NAME(r.user_id) AS user_name,
	s.is_user_process,
	s.login_time,
	r.start_time,
	r.command,
	tx.text,
	r.last_wait_type,
	r.wait_resource,
	t.task_state,
	w.state,
	w.last_wait_type,
	s.host_name,
	s.program_name,
	s.client_version,
	s.client_interface_name,
	s.login_name,
	s.nt_domain,
	s.nt_user_name,
	s.status,
	s.cpu_time,
	s.memory_usage,

	s.total_scheduled_time,
	s.total_elapsed_time,
	s.last_request_start_time,
	s.last_request_end_time,

	s.reads,
	s.writes,
	s.logical_reads,
	s.row_count,
	r.status,
	r.wait_time,
	r.cpu_time,
	r.total_elapsed_time,
	r.reads,
	r.writes,
	r.logical_reads,

	t.pending_io_count,
	w.pending_io_count,
	w.pending_io_byte_count,
	t.pending_io_byte_count,
	w.pending_io_byte_count,
	t.pending_io_byte_average,
	w.pending_io_byte_average,

	mg.grant_time,
	mg.requested_memory_kb,
	mg.granted_memory_kb,
	mg.required_memory_kb,
	mg.used_memory_kb,
	mg.max_used_memory_kb,
	mg.query_cost,

	mg.scheduler_id,
	t.scheduler_id,
	mg.request_id,
	t.request_id,
	r.dop,
	mg.dop,
	r.parallel_worker_count,
	mg.reserved_worker_count,
	mg.used_worker_count,
	mg.max_used_worker_count,
	r.blocking_session_id,
	th.kernel_time,
	th.usermode_time,

	t.context_switches_count,
	w.context_switch_count,
	
	th.creation_time,
	th.started_by_sqlservr,

	s.host_process_id,
	th.os_thread_id,
	th.thread_address,
	th.worker_address,
	th.status,
	w.wait_started_ms_ticks

FROM 
	sys.dm_os_tasks AS t
	LEFT JOIN
	sys.dm_os_threads AS th
	ON
	th.worker_address = t.worker_address
	LEFT JOIN
	sys.dm_os_workers AS w
	ON
	w.worker_address = t.worker_address
	LEFT JOIN
	sys.dm_exec_requests AS r
	ON
	r.session_id = t.session_id
	AND
	r.request_id = t.request_id
	LEFT JOIN
	sys.dm_exec_sessions AS s
	ON
	s.session_id = t.session_id
	LEFT JOIN
	sys.dm_exec_query_memory_grants AS mg
	ON
	mg.session_id = r.session_id
	AND
	mg.request_id = r.request_id
	LEFT JOIN
	sys.resource_governor_workload_groups AS wg
	ON
	r.group_id = wg.group_id
	OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS tx
WHERE 
	t.session_id IS NOT NULL
	AND
	t.session_id <> @@SPID
	AND
	s.is_user_process = 1
ORDER BY
	t.session_id,
	t.scheduler_id
OPTION(RECOMPILE)

