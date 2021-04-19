SELECT
	ot.session_id,
	ot.exec_context_id,
	ot.request_id,
	ot.scheduler_id,
	er.dop,
	ot.task_state,
	ow.state,
	ow.last_wait_type,
	ot.context_switches_count,
	ow.pending_io_count,
	ow.pending_io_byte_count,
	ow.pending_io_byte_average,
	oth.os_thread_id
FROM 
	sys.dm_os_tasks AS ot
	INNER JOIN sys.dm_exec_sessions AS es
		ON es.session_id = ot.session_id AND es.is_user_process = 1
	INNER JOIN sys.dm_exec_requests as er
		ON er.session_id = ot.session_id
	INNER JOIN sys.dm_os_workers AS ow
		ON ow.worker_address = ot.worker_address
	INNER JOIN sys.dm_os_threads AS oth
		ON oth.thread_address = ow.thread_address
WHERE 
	ot.session_id IS NOT NULL
	AND (ot.task_state = 'RUNNING' AND ow.state = 'RUNNING')
ORDER BY 
	ot.session_id ASC,
	ot.exec_context_id ASC