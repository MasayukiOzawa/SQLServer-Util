-- https://stackoverflow.com/questions/624206/modify-xml-in-sql-server-to-add-a-root-node
DECLARE @sql_handle varbinary(64) = 0x0300FF7F149270E47A1011013FAC000000000000000000000000000000000000000000000000000000000000

;WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')

SELECT
    T.sql_handle,
    T.text,
    T.query_plan,
    T.query_hash,
    T.query_plan_hash,
    T2.stmt.value('@StatementId', 'tinyint') AS StatementId,
    SUBSTRING(T.text, (T.statement_start_offset/2) + 1,  
    ((CASE statement_end_offset   
        WHEN -1 THEN DATALENGTH(T.text)  
        ELSE T.statement_end_offset END   
            - T.statement_start_offset)/2) + 1) AS statement_text,
    T2.stmt.value('@StatementOptmLevel', 'varchar(100)') AS StatementOptmLevel,
    T2.stmt.value('(//@CachedPlanSize)[1]', 'int') AS CachedPlanSize, -- KB
    T2.stmt.value('(//@CompileTime)[1]', 'int') AS CompileTime, -- ms
    T2.stmt.value('(//@CompileCPU)[1]', 'int') AS CompileCPU, -- ms
    T2.stmt.value('(//@CompileMemory)[1]', 'int') AS CompileMemory, -- kb
    -- T2.stmt.query('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";.') AS statementPlan,
    T2.stmt.query('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";
        <ShowPlanXML Version="1.539" Build="15.0.4073.23"><BatchSequence><Batch><Statements>
            { for $item in . return $item }
        </Statements></Batch></BatchSequence></ShowPlanXML>'
    ) AS stmt_plan
FROM
(
    SELECT
        qs.sql_handle,
        qs.query_hash,
        qs.query_plan_hash,
        qs.statement_sql_handle,
        qs.statement_start_offset,
        qs.statement_end_offset,
        qs.creation_time,
        qp.query_plan,
        qt.text
    FROM
        sys.dm_exec_query_stats AS qs
        CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
        CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
    WHERE
        sql_handle = @sql_handle
) AS T
OUTER APPLY query_plan.nodes('//Statements/StmtSimple') AS T2(stmt)
WHERE
    CONVERT(varchar(16), query_hash, 1) = T2.stmt.value('(@QueryHash)[1]', 'varchar(16)')
ORDER BY
    sql_handle, T2.stmt.value('@StatementId', 'tinyint')