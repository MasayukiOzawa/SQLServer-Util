SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
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
	CAST(
	REPLACE(
			@queryplan_basexml, 
			'{0}', 
			CAST(T2.Stmt.query('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";.') AS nvarchar(max)))
	AS xml) AS query_plan,
	T2.Stmt.value('./@QueryHash', 'varchar(60)') AS xml_query_hash,
	T.*
FROM(
SELECT TOP 10
   total_dop
  ,last_dop
  ,min_dop
  ,max_dop
  --query text
  ,qt.TEXT as parent_query
  ,SUBSTRING(qt.TEXT, qs.statement_start_offset / 2, (
      CASE
        WHEN qs.statement_end_offset = - 1
          THEN LEN(CONVERT(NVARCHAR(MAX), qt.TEXT)) * 2
        ELSE qs.statement_end_offset
      END - qs.statement_start_offset
   ) / 2) as statement
  -- average
  ,total_worker_time / qs.execution_count / 1000 as average_CPU_time_ms
  ,total_elapsed_time / qs.execution_count / 1000 as average_duration_ms
  ,total_physical_reads / qs.execution_count / 1000 as average_physical_reads
  -- execution count
  ,qs.execution_count as execution_count
  -- creation / execution time
  ,last_execution_time
  ,creation_time
  -- total
  ,total_worker_time / 1000 as total_CPU_time_ms
  ,total_elapsed_time / 1000 as total_duration_ms
  ,total_physical_reads / 1000 as total_physical_reads
  -- query plan
  ,qs.query_hash
  ,qp.query_plan  -- プランもみたいときはコメント外す
FROM sys.dm_exec_query_stats qs
	OUTER APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt -- クエリテキスト用
	OUTER apply sys.dm_exec_query_plan(plan_handle) as qp -- プランプラン用
ORDER BY average_duration_ms desc
) AS T
OUTER APPLY query_plan.nodes('//StmtSimple') AS T2(Stmt)
WHERE
	T2.Stmt.value('./@QueryHash', 'varchar(64)') = CONVERT(varchar(64), query_hash, 1)
OPTION(RECOMPILE)