-- SET STATISTICS PROFILE ON を有効にしているクエリに関して情報を取得
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
ORDER BY
    session_id, request_id, node_id, thread_id
