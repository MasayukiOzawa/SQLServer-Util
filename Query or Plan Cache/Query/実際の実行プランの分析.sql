/*
CREATE TABLE Analyze(KeyColumn int primary key, QueryPlan xml)
GO
CREATE PRIMARY XML INDEX XML_Analyze ON Analyze (QueryPlan)
GO
-- DROP INDEX XML_Analyze ON Analyze
GO 
INSERT INTO Analyze
SELECT 5, CAST(C AS XML) FROM OPENROWSET(BULK N'E:\temp\TPCH_ALL.sqlplan', SINGLE_BLOB) AST(C)
GO
*/

DECLARE @queryplan_basexml nvarchar(max) = N'<?xml version="1.0" encoding="utf-16"?>
<ShowPlanXML xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" Version="1.539" Build="15.0.4013.40" xmlns="http://schemas.microsoft.com/sqlserver/2004/07/showplan">
  <BatchSequence>
    <Batch>
      <Statements>
	  {0}
      </Statements>
    </Batch>
  </BatchSequence>
</ShowPlanXML>
';

WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
SELECT 
	T2.Stmt.value('data(./@StatementId)', 'int') AS StatementId,
	T2.Stmt.value('data(./@QueryHash)', 'varchar(40)') AS QueryHash,
	T2.Stmt.value('data(./@StatementText)', 'nvarchar(max)') AS qeury_text,
	CAST(
		REPLACE(
			@queryplan_basexml, 
			'{0}', 
			CAST(T2.Stmt.query('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";.') AS nvarchar(max)))
	AS xml) AS query_plan,
	T2.Stmt.value('data(./@StatementOptmEarlyAbortReason)', 'varchar(100)') AS StatementOptmEarlyAbortReason,
	T2.Stmt.value('data(./@StatementSubTreeCost)', 'varchar(20)') AS StatementSubTreeCost,
	FORMAT(T2.Stmt.value('data(./QueryPlan/@DegreeOfParallelism)[1]', 'int'),'#,##0') AS DegreeOfParallelism,
	FORMAT(T2.Stmt.value('data(./descendant::*/@CpuTime)[1]', 'int'),'#,##0') AS CpuTime_ms,
	FORMAT(T2.Stmt.value('data(./descendant::*/@ElapsedTime)[1]', 'int'),'#,##0') AS ElapsedTime_ms,
	FORMAT(T2.Stmt.value('data(./QueryPlan/@CompileTime)[1]', 'int'),'#,##0') AS CompileTime_ms,
	FORMAT(T2.Stmt.value('data(./QueryPlan/@CachedPlanSize)[1]', 'int'),'#,##0') AS CachedPlanSize_kb,
	FORMAT(T2.Stmt.value('data(./QueryPlan/@CompileMemory)[1]', 'int'),'#,##0') AS CompileMemory_kb,
	FORMAT(T2.Stmt.value('data(./QueryPlan/@MemoryGrant)[1]', 'int'),'#,##0') AS MemoryGrant_kb,
	T2.Stmt.query('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";.//WaitStats') AS wait_stats,
	T2.Stmt.query('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";.//OptimizerStatsUsage') AS statistcis_info,
	T2.Stmt.query('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";.//MissingIndexes') AS missing_index
FROM(
SELECT 
	*
FROM 
	Analyze
WHERE
	KeyColumn = 5
) AS T
CROSS APPLY QueryPlan.nodes('//StmtSimple') AS T2(Stmt)
ORDER BY
	StatementSubTreeCost DESC
