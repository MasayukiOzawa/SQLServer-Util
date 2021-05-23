/*
-- sys.fn_stmt_sql_handle_from_sql_stmt からの取得
EXEC Q2
SELECT * FROM sys.fn_stmt_sql_handle_from_sql_stmt('EXEC Q2', NULL);

*/


-- ハッシュからの取得
DECLARE @query_hash binary(8) = 0xB4A24E1213D92EE3
SELECT
    i.start_time,
    i.end_time,
    q.query_id    ,
    q.query_text_id,
    q.initial_compile_start_time,
    q.last_compile_start_time,
    q.last_execution_time,
    p.compatibility_level,
    t.query_sql_text,
    CAST(p.query_plan AS xml) AS query_plan,
    r.*
FROM
    sys.query_store_query q
    INNER JOIN    sys.query_store_plan p
         ON    q.query_id =  p.query_id
    INNER JOIN    sys.query_store_query_text t
         ON    t.query_text_id = q.query_text_id
    INNER JOIN    sys.query_store_runtime_stats r
         ON    r.plan_id =p.plan_id
    INNER JOIN    sys.query_store_runtime_stats_interval i
         ON    i.runtime_stats_interval_id = r.runtime_stats_interval_id
WHERE
    q.query_hash = @query_hash
ORDER BY
    i.start_time,q.query_id

