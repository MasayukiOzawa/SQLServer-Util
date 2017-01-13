-- SET STATISTICS PROFILE ON / SET STATISTICS XML ON を有効にしているクエリに関して情報を取得
-- 拡張イベントの query_post_execution_showplan を有効にすることで、個別のクエリで SET 句を付与しなくても取得できるが、拡張イベントを使用する場合はパフォーマンスの劣化に注意する
-- SQL Server 2014 SP2 / SQL Server 2016 SP1 以降は TF7412 を使用することで、軽量プロファイルを用いた情報の取得が可能
-- https://blogs.msdn.microsoft.com/sql_server_team/query-progress-anytime-anywhere/ 
-- DBCC TRACEON(7412, -1)

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
    sys.dm_exec_query_profiles qp
    CROSS APPLY
    sys.dm_exec_sql_text (sql_handle) t
    CROSS APPLY
    sys.dm_exec_query_plan(plan_handle) p
    LEFT JOIN
    sys.dm_os_tasks ot
ON
    qp.task_address = ot.task_address
WHERE
	qp.session_id <> @@SPID
ORDER BY
    session_id, request_id, node_id, thread_id
OPTION (RECOMPILE)