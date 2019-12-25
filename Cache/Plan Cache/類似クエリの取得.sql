/*************************************************
SQL Server 2008 R2 以降
*************************************************/
SET NOCOUNT ON
GO
-- 複数キャッシュされている類似クエリの query_hash を取得
SELECT
    GETDATE() AS DATE,
    REPLACE(REPLACE(REPLACE(MAX(est.text),CHAR(13), ''), CHAR(10), ' '),CHAR(9), ' ') AS text
	, objtype
    , COUNT(*) AS count
    , query_hash
    , query_plan_hash
FROM
    sys.dm_exec_query_stats eqs
    OUTER APPLY
    sys.dm_exec_sql_text(sql_handle) est
	LEFT JOIN sys.dm_exec_cached_plans AS cp
	ON cp.plan_handle = eqs.plan_handle
GROUP BY
    query_hash
    , query_plan_hash
	, cp.objtype
HAVING
    COUNT(*) > 1
ORDER BY
    count DESC
    , text
OPTION (RECOMPILE)
GO
