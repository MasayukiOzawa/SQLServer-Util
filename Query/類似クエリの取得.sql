SET NOCOUNT ON
GO

SELECT
    GETDATE() AS DATE,
    REPLACE(REPLACE(REPLACE(MAX(est.text),CHAR(13), ''), CHAR(10), ' '),CHAR(9), ' ') AS text
    , COUNT(*) AS count
    , query_hash
    , query_plan_hash
FROM
    sys.dm_exec_query_stats eqs
    OUTER APPLY
    sys.dm_exec_sql_text(sql_handle) est
GROUP BY
    query_hash
    , query_plan_hash
HAVING
    COUNT(*) > 1
ORDER BY
    count DESC
    , text
OPTION (RECOMPILE)
