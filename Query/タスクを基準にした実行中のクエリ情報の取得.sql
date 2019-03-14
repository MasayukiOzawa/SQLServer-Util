SELECT 
	dot.session_id,
	der.blocking_session_id,
	dot.exec_context_id,
	DB_NAME(des.database_id) AS database_name,
	der.command,
	dest.text,
	SUBSTRING(dest.text, (der.statement_start_offset/2)+1,   
    ((CASE der.statement_end_offset  
        WHEN -1 THEN DATALENGTH(dest.text)  
        ELSE der.statement_end_offset  
        END - der.statement_start_offset)/2) + 1) AS statement_text,
	deqp.query_plan,
	CAST(detqp.query_plan AS xml) AS statement_query_plan,
	dot.task_state,
	dow.state,
	des.status AS des_status,
	der.status AS der_status,
	der.wait_type AS der_wait_type,
	dowt.wait_type AS dowt_wait_type,
	der.last_wait_type AS der_last_wait_type,
	dow.last_wait_type AS dow_last_wait_type,
	dowt.wait_duration_ms,
	der.wait_resource,
	dowt.resource_description,
	des.host_name,
	des.program_name,
	des.login_name,
	des.cpu_time AS des_cpu_time,
	der.cpu_time AS der_cpu_time,
	des.total_scheduled_time,
	doth.kernel_time,
	doth.usermode_time,
	des.total_elapsed_time AS des_total_elapsed_time,
	der.total_elapsed_time AS der_total_elapsed_time,
	CASE dow.wait_started_ms_ticks
		WHEN 0 THEN 0
		ELSE	dosi.ms_ticks - dow.wait_started_ms_ticks
	END AS suspended_ms,
	CASE dow.wait_resumed_ms_ticks
		WHEN 0 THEN 0
		ELSE	dosi.ms_ticks - dow.wait_resumed_ms_ticks
	END AS runnable_ms,
	des.memory_usage,
	des.reads AS des_reads,
	der.reads AS der_reads,
	des.writes AS des_writes,
	der.writes AS der_writes,
	des.logical_reads AS des_logical_reads,
	der.logical_reads AS der_logical_reads,
	dot.pending_io_count,
	dow.pending_io_count,
	dot.pending_io_byte_count,
	dow.pending_io_byte_count,
	dot.pending_io_byte_average,
	dot.pending_io_byte_average,
	der.start_time,
	des.login_time,
	des.last_request_start_time,
	des.last_request_end_time
FROM 
	sys.dm_os_tasks AS dot
	LEFT JOIN sys.dm_exec_sessions AS des
		ON des.session_id = dot.session_id
	LEFT JOIN sys.dm_os_threads AS doth
		ON doth.worker_address = dot.worker_address
	LEFT JOIN sys.dm_os_workers AS dow
		ON dow.worker_address = dot.worker_address
	LEFT JOIN sys.dm_exec_requests AS der
		ON der.task_address = dow.task_address
	LEFT JOIN sys.dm_os_waiting_tasks AS dowt
		ON dowt.session_id = dot.session_id
		AND dowt.exec_context_id = dot.exec_context_id
		AND dowt.session_id <> dowt.blocking_session_id
		AND dowt.resource_description IS NOT NULL
	OUTER APPLY sys.dm_exec_sql_text(sql_handle) AS dest
	OUTER APPLY sys.dm_exec_query_plan(der.plan_handle) AS deqp
	OUTER APPLY sys.dm_exec_text_query_plan(der.plan_handle, der.statement_start_offset, der.statement_end_offset) AS detqp
	CROSS JOIN sys.dm_os_sys_info AS dosi
WHERE
	dot.session_id IS NOT NULL AND dot.session_id <> @@SPID
	AND
	des.is_user_process = 1
ORDER BY
	dot.session_id ASC,
	dot.exec_context_id ASC
