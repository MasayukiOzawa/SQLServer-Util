SET NOCOUNT ON
GO

SELECT
    es.session_id,
    er.blocking_session_id,
    er.scheduler_id,
	ec.local_tcp_port,
	er.request_id,
	es.host_name,
	ec.local_net_address,
	ec.client_tcp_port,
    es.program_name,
	es.login_name,
	es.nt_user_name,
    -- er.database_id,
    es.status,
    er.command,
    er.wait_type,
    er.last_wait_type,
    er.wait_resource,
    DB_NAME(er.database_id) AS database_name,
	CASE er.transaction_isolation_level 
		WHEN 0 THEN 'Unspecified' 
		WHEN 1 THEN 'ReadUncommitted' 
		WHEN 2 THEN 'ReadCommitted' 
		WHEN 3 THEN 'Repeatable' 
		WHEN 4 THEN 'Serializable' 
		WHEN 5 THEN 'Snapshot' 
	END AS Transaction_Isolation_Level,
    --er.user_id,
    -- er.executing_managed_code,
    es.client_interface_name,
    es.login_name,
    es.client_version,
	ec.connect_time,
    es.login_time,
    er.start_time,
    es.last_request_start_time,
    es.last_request_end_time,
    er.wait_time,
    er.open_resultset_count,
    er.open_resultset_count,
    er.percent_complete,
    er.estimated_completion_time,
    es.total_elapsed_time,
    er.total_elapsed_time AS exec_requests_total_elapsed_time,
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
	tsu.user_objects_alloc_page_count,
	tsu.user_objects_dealloc_page_count,
	tsu.internal_objects_dealloc_page_count,
	tsu.internal_objects_dealloc_page_count,
    er.granted_query_memory,
    es.lock_timeout,
    er.lock_timeout as exec_requests_lock_timeout,
    es.deadlock_priority,
    er.deadlock_priority AS exec_requests_deadlock_priority,
    REPLACE(REPLACE(ec_text.text,CHAR(13), ''), CHAR(10), ' ') AS ec_text,
    REPLACE(REPLACE(er_text.text,CHAR(13), ''), CHAR(10), ' ') AS er_text,
    er_plan.query_plan AS er_plan
-- 以下は SQL Server 2005 では取得不可
    ,er.query_hash,
    er.query_plan_hash
-- 以下は SQL Server のバージョンによっては取得不可
    ,er.dop
FROM
    sys.dm_exec_requests er WITH (NOLOCK)
    LEFT JOIN
    sys.dm_exec_sessions es WITH (NOLOCK)
    ON
    es.session_id = er.session_id
    LEFT JOIN
    (SELECT * FROM sys.dm_exec_connections WITH (NOLOCK) WHERE most_recent_sql_handle <> 0x0) AS ec
    ON
    es.session_id = ec.session_id
    OUTER APPLY
    sys.dm_exec_sql_text(er.sql_handle) AS er_text
    OUTER APPLY
    sys.dm_exec_sql_text(ec.most_recent_sql_handle) AS ec_text
	OUTER APPLY
	sys.dm_exec_query_plan(er.plan_handle) as er_plan
	LEFT JOIN
	sys.dm_db_task_space_usage AS tsu WITH (NOLOCK)
	ON
	tsu.session_id = er.session_id
	AND
	tsu.request_id = er.request_id
WHERE
    es.session_id <> @@SPID
	AND
	es.session_id >=50
	AND
	es.is_user_process = 1
ORDER BY
	exec_requests_cpu_time DESC,
	cpu_time DESC, 
	session_id ASC
OPTION (RECOMPILE)
