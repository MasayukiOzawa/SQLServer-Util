SET NOCOUNT ON
GO

/*********************************************/
-- 接続中のセッション情報を取得 
/*********************************************/
SELECT 
	es.session_id,
	er.request_id,
	er.start_time,
	er.start_time,
	es.last_request_start_time,
	es.last_request_end_time,
	CASE WHEN er.sql_handle IS NULL
		THEN REPLACE(REPLACE(ec_text.text,CHAR(13), ''), CHAR(10), ' ')
		ELSE REPLACE(REPLACE(er_text.text,CHAR(13), ''), CHAR(10), ' ')
	END AS text,
	er.command,
	es.status,
	er.wait_type,
	owt.blocking_session_id,
	owt.resource_description,
	er.last_wait_type,
	er.wait_resource,
	er.database_id,
	DB_NAME(er.database_id) AS database_name,
	er.user_id,
	er.wait_time,
	er.open_resultset_count,
	er.open_resultset_count,
	er.percent_complete,
	er.estimated_completion_time,
	es.total_elapsed_time,
	er.total_elapsed_time AS exec_requests_total_elapsed_time,
	owt.wait_duration_ms,
	es.cpu_time,
	er.cpu_time AS exec_requests_cpu_time,
	es.memory_usage,
	es.total_scheduled_time,
	es.reads,
	er.reads AS exec_requests_reads,
	es.writes,
	er.writes AS exec_requests_writes,
	es.logical_reads,
	er.logical_reads AS exec_requests_logical_reads,
	es.row_count,
	er.row_count AS exec_requests_row_count,
	er.granted_query_memory,
	er.scheduler_id,
	er.transaction_isolation_level,
	er.executing_managed_code,
	es.lock_timeout,
	er.lock_timeout as exec_requests_lock_timeout,
	es.deadlock_priority,
	er.deadlock_priority AS exec_requests_deadlock_priority,
	owt.exec_context_id,
	es.host_name,
	es.program_name,
	es.login_time,
	es.login_name,
	es.client_version,
	es.client_interface_name
	-- 以下は SQL Server 2005 では取得不可
	 ,er.query_hash,
	 er.query_plan_hash
FROM 
	sys.dm_exec_sessions es
	LEFT JOIN
	sys.dm_exec_requests er
	ON
	es.session_id = er.session_id
	LEFT JOIN
	sys.dm_os_waiting_tasks owt
	ON
	er.session_id = owt.session_id
	LEFT JOIN
	(SELECT * FROM sys.dm_exec_connections WHERE most_recent_sql_handle <> 0x0) AS ec
	ON
	es.session_id = ec.session_id
	OUTER APPLY
	sys.dm_exec_sql_text(er.sql_handle) AS er_text
	OUTER APPLY
	sys.dm_exec_sql_text(ec.most_recent_sql_handle) AS ec_text
WHERE
	es.session_id > 50
	AND
	es.session_id <> @@SPID
	AND
	es.program_name NOT LIKE 'SQLAgent%'
	AND
	es.program_name NOT LIKE 'SQL Server Data Collector%'
ORDER BY
	session_id ASC
OPTION (RECOMPILE)

