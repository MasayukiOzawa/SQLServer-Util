use tpch
GO
WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
SELECT
    *
FROM
(
    SELECT
        *,
        query_plan.value('(//StmtSimple/@StatementOptmLevel)[1]', 'nvarchar(100)') AS StatementOptmLevel,
        query_plan.value('(//StmtSimple/@StatementOptmEarlyAbortReason)[1]', 'nvarchar(100)') AS StatementOptmEarlyAbortReason
    FROM
    (

        SELECT
            qsp.query_id,
            qsp.plan_id,
            qsq.query_text_id,
            qsq.query_hash,
            qsp.query_plan_hash,
            qsqt.query_sql_text,
            CAST(qsq.avg_optimize_duration AS int) / 1000AS avg_optimize_duration_ms,
            CAST(qsq.avg_bind_duration AS int) / 1000 AS avg_bind_duration_ms,
            CAST(qsp.avg_compile_duration AS int) / 1000 AS avg_compile_duration_ms,
            cast(qsp.query_plan AS xml) AS query_plan
        FROM 
            sys.query_store_plan AS qsp
            inner join sys.query_store_query AS qsq
                ON qsq.query_id = qsp.query_id
            inner join sys.query_store_query_text AS qsqt
                ON qsqt.query_text_id = qsq.query_text_id
    ) AS T1
) AS T2
WHERE
    T2.StatementOptmEarlyAbortReason <> 'GoodEnoughPlanFound'
ORDER BY
    avg_optimize_duration_ms DESC