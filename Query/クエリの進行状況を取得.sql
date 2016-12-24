-- SET STATISTICS PROFILE ON / SET STATISTICS XML ON を有効にしているクエリに関して情報を取得
-- 拡張イベントの query_post_execution_showplan を有効にすることで、個別のクエリで SET 句を付与しなくても取得できるが、拡張イベントを使用する場合はパフォーマンスの劣化に注意する
-- SQL Server 2014 SP2 / SQL Server 2016 SP1 以降は TF7412 を使用することで、軽量プロファイルを用いた情報の取得が可能
-- https://blogs.msdn.microsoft.com/sql_server_team/query-progress-anytime-anywhere/ 
-- DBCC TRACEON(7412, -1)

SELECT
    qp.session_id, 
    qp.request_id, 
    t.text,
    --p.query_plan,
    ot.task_state,
    qp.physical_operator_name, 
    qp.node_id, 
    qp.thread_id, 
    qp.row_count,
    qp.estimate_row_count,
    CASE row_count
        WHEN 0 THEN 0.0
        ELSE convert(float,qp.row_count) / qp.estimate_row_count * 100.0
    END as progress
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
