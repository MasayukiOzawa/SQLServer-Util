SELECT
	der.session_id,
	der.blocking_session_id,
	summary.thread_count,
	der.dop,
	--der.request_id,
	DB_NAME(des.database_id) AS database_name,
	der.status AS request_status,
	des.status AS session_status,
	der.wait_type,
	der.last_wait_type,
	der.wait_resource,
	der.command,
	summary.total_kernel_time + summary.total_usermode_time AS total_cpu_time,
	summary.total_kernel_time,
	summary.total_usermode_time,
	der.cpu_time AS request_cpu_time,
	des.cpu_time AS session_cpu_time,
	des.total_scheduled_time AS session_total_scheduler_time,
	der.wait_time,
	der.start_time,
	des.login_time,
	des.host_name,
	des.program_name,
	des.login_name,
	dest.text,
	SUBSTRING(dest.text, (der.statement_start_offset/2)+1,   
    ((CASE der.statement_end_offset  
        WHEN -1 THEN DATALENGTH(dest.text)  
        ELSE der.statement_end_offset  
        END - der.statement_start_offset)/2) + 1) AS statement_text,
	deqp.query_plan,
	CAST(detqp.query_plan AS xml) AS statement_query_plan,
	des.memory_usage,
	der.total_elapsed_time AS request_total_elapsed_time,
	des.total_elapsed_time AS session_total_elapsed_time,
	der.reads,
	der.writes,
	der.logical_reads,
	summary.total_pending_io_count,
	summary.total_pending_io_byte_count,
	summary.total_pending_io_byte_average,
	der.open_transaction_count,
	der.percent_complete,
	der.estimated_completion_time
FROM sys.dm_exec_requests AS der WITH(NOLOCK)
LEFT JOIN sys.dm_exec_sessions AS des WITH(NOLOCK)
ON des.session_id = der.session_id
OUTER APPLY sys.dm_exec_sql_text(der.sql_handle)  AS dest
OUTER APPLY sys.dm_exec_query_plan(der.plan_handle) AS deqp
OUTER APPLY sys.dm_exec_text_query_plan(der.plan_handle, der.statement_start_offset, der.statement_end_offset) AS detqp
LEFT JOIN
(
	SELECT 
		dot.session_id,
		COUNT(*) AS thread_count,
		SUM(doth.kernel_time) AS total_kernel_time,
		SUM(doth.usermode_time) AS total_usermode_time,
		SUM(dot.pending_io_count) AS total_pending_io_count,
		SUM(dot.pending_io_byte_count) AS total_pending_io_byte_count,
		SUM(dot.pending_io_byte_average) AS total_pending_io_byte_average
	FROM 
		sys.dm_os_tasks AS dot WITH(NOLOCK)
		LEFT JOIN sys.dm_os_threads AS doth WITH(NOLOCK)
			ON doth.worker_address = dot.worker_address
	WHERE
		dot.session_id IS NOT NULL AND dot.session_id <> @@SPID
	GROUP BY
		dot.session_id
)AS summary
ON summary.session_id = der.session_id
WHERE
	des.is_user_process = 1
	AND der.session_id <> @@SPID
ORDER BY
	total_cpu_time DESC