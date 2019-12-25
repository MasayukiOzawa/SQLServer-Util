-- SET STATISTICS PROFILE ON / SET STATISTICS XML ON を有効にしているクエリに関して情報を取得
-- 拡張イベントの query_post_execution_showplan を有効にすることで、個別のクエリで SET 句を付与しなくても取得できるが、拡張イベントを使用する場合はパフォーマンスの劣化に注意する
-- SQL Server 2014 SP2 / SQL Server 2016 SP1 以降は TF7412 を使用することで、軽量プロファイルを用いた情報の取得が可能
-- https://blogs.msdn.microsoft.com/sql_server_team/query-progress-anytime-anywhere/ 
-- DBCC TRACEON(7412, -1)
-- SQL Server 2017 からはデフォルトで軽量プロファイリングが有効

DECLARE @session_id int = 148

DECLARE @starttime datetime = (SELECT sqlserver_start_time FROM sys.dm_os_sys_info)
SELECT
    qp.session_id, 
	DB_NAME(qp.database_id) AS db_name,
    qp.request_id, 
    ot.task_state,
    qp.physical_operator_name, 
    qp.node_id, 
    qp.thread_id, 
    qp.row_count,
    qp.estimate_row_count,
    CASE 
        WHEN row_count = 0 OR estimate_row_count = 0 THEN 0.0
        ELSE convert(float,qp.row_count) / qp.estimate_row_count * 100.0
    END as progress,
	DATEADD(ms, qp.first_active_time, @starttime) AS FirstActiveTime,
	DATEADD(ms, qp.last_active_time, @starttime) AS LastActiveTime,
	CASE qp.open_time
		WHEN 0 THEN NULL
		ELSE DATEADD(ms, qp.open_time, @starttime) 
	END AS OpenTime,
	CASE qp.close_time
		WHEN 0 THEN NULL
		ELSE DATEADD(ms, qp.close_time, @starttime) 
	END AS CloseTime,
	qp.elapsed_time_ms,
	qp.cpu_time_ms
FROM
    sys.dm_exec_query_profiles qp WITH(NOLOCK)
	--以下の APPLY は不可が高いのでコメント化
    --CROSS APPLY
    --sys.dm_exec_sql_text (sql_handle) t
    --CROSS APPLY
    --sys.dm_exec_query_plan(plan_handle) p
    LEFT JOIN
    sys.dm_os_tasks ot
	ON
		qp.task_address = ot.task_address
WHERE
	qp.session_id = @session_id
ORDER BY
    session_id, request_id, node_id, thread_id
OPTION (RECOMPILE)

-- 使用されている実行プランの取得
SELECT
    es.session_id,
    er.request_id,
	er.scheduler_id,
	--tsu.exec_context_id,
    er.start_time,
    er.start_time,
    es.last_request_start_time,
    es.last_request_end_time,
    --REPLACE(REPLACE(ec_text.text,CHAR(13), ''), CHAR(10), ' ') AS ec_text,
    REPLACE(REPLACE(er_text.text,CHAR(13), ''), CHAR(10), ' ') AS er_text,
    er.command,
    es.status,
    er.wait_type,
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
	--tsu.user_objects_alloc_page_count,
	--tsu.user_objects_dealloc_page_count,
	--tsu.internal_objects_dealloc_page_count,
	--tsu.internal_objects_dealloc_page_count,
	er.start_time,
    er.granted_query_memory,
    er.scheduler_id,
    er.transaction_isolation_level,
    er.executing_managed_code,
    es.lock_timeout,
    er.lock_timeout as exec_requests_lock_timeout,
    es.deadlock_priority,
    er.deadlock_priority AS exec_requests_deadlock_priority,
    es.host_name,
    es.program_name,
    es.login_time,
    es.login_name,
    es.client_version,
    es.client_interface_name,
	es.is_user_process,
    --er_plan.query_plan AS er_plan,
    er.query_hash,
    er.query_plan_hash,
	er.dop,
	qx.query_plan -- DBCC TRACEON(7412, -1) 設定以降に実行されたクエリについての実行プランを取得
FROM
    sys.dm_exec_requests er WITH (NOLOCK)
    LEFT JOIN
    sys.dm_exec_sessions es WITH (NOLOCK)
    ON
    es.session_id = er.session_id
    --LEFT JOIN
    --(SELECT * FROM sys.dm_exec_connections WITH (NOLOCK) WHERE most_recent_sql_handle <> 0x0) AS ec
    --ON
    --es.session_id = ec.session_id
    OUTER APPLY
    sys.dm_exec_sql_text(er.sql_handle) AS er_text
    --OUTER APPLY
    --sys.dm_exec_sql_text(ec.most_recent_sql_handle) AS ec_text
	--OUTER APPLY
	--sys.dm_exec_query_plan(er.plan_handle) as er_plan
	--LEFT JOIN
	--sys.dm_db_task_space_usage AS tsu WITH (NOLOCK)
	--ON
	--tsu.session_id = er.session_id
	--AND
	--tsu.request_id = er.request_id
	OUTER APPLY
	sys.dm_exec_query_statistics_xml(er.session_id) qx
WHERE
    es.session_id= @session_id
	AND
	qx.query_plan IS NOT NULL
ORDER BY
	exec_requests_cpu_time DESC,
	cpu_time DESC, 
	session_id ASC
OPTION (RECOMPILE)
