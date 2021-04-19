DECLARE @target int = 100
/*
DECLARE @target int = <target, int, 1>
*/
;
WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT
    T.*,
    CAST(
    '<ShowPlanXML xmlns="http://schemas.microsoft.com/sqlserver/2004/07/showplan" Version="1.539" Build="15.0.4053.23"><BatchSequence><Batch><Statements>' + 
        CAST(T2.stmt.query('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";.') AS nvarchar(max)) 
    + '</Statements></Batch></BatchSequence></ShowPlanXML>' AS xml) AS statementPlan,
    T2.stmt.value('(./@StatementText)[1]','varchar(max)') AS StatementText,
    T2.stmt.value('(./@StatementOptmLevel)[1]','varchar(max)') AS StatementOptmLevel,
    T2.stmt.value('(//QueryPlan/@NonParallelPlanReason)[1]','varchar(max)') AS NonParallelPlanReason,
    T2.stmt.value('(./@StatementOptmEarlyAbortReason)[1]','varchar(max)') AS StatementOptmEarlyAbortReason,
    FORMAT(T2.stmt.value('(//QueryPlan/@CachedPlanSize)[1]','int'), '#,##0') AS CachedPlanSize_kb,
    FORMAT(T2.stmt.value('(//QueryPlan/@CompileTime)[1]','int'), '#,##0') AS CompileTime_ms,
    FORMAT(T2.stmt.value('(//QueryPlan/@CompileCPU)[1]','int'), '#,##0') AS CompileCPU_ms,
    FORMAT(T2.stmt.value('(//QueryPlan/@CompileMemory)[1]','int'), '#,##0') AS CompileMemory_kb,
    FORMAT(T2.stmt.value('(//MemoryGrantInfo/@SerialRequiredMemory)[1]','int'), '#,##0') AS SerialRequiredMemory_kb,
    FORMAT(T2.stmt.value('(//MemoryGrantInfo/@SerialDesiredMemory)[1]','int'), '#,##0') AS SerialDesiredMemory_kb,
    FORMAT(T2.stmt.value('(//MemoryGrantInfo/@GrantedMemory)[1]','int'), '#,##0') AS GrantedMemory_kb,
    FORMAT(T2.stmt.value('(//MemoryGrantInfo/@MaxUsedMemory)[1]','int'), '#,##0') AS MaxUsedMemory_kb
FROM
(
    /*
    SELECT TOP 100 PERCENT last_execution_time, plan_id, cast(query_plan as xml) AS query_plan 
    FROM sys.query_store_plan
    WHERE last_execution_time >= DATEADD(day, -@target, GETDATE())
    ORDER BY last_execution_time DESC
    */
    SELECT TOP 100 PERCENT creation_time, last_execution_time, query_hash, query_plan_hash, query_plan 
    FROM sys.dm_exec_query_stats CROSS APPLY sys.dm_exec_query_plan(plan_handle) 
    WHERE last_execution_time >= DATEADD(day, -@target, GETDATE()) ORDER BY last_execution_time DESC
) AS T
    CROSS APPLY query_plan.nodes('//StmtSimple') AS T2(stmt)
WHERE
    T2.stmt.value('(./@StatementOptmEarlyAbortReason)[1]','varchar(max)') IS NOT NULL