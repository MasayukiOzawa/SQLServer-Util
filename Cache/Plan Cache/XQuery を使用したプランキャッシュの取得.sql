-- 特定のクエリのステートメントを取得
WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan' ) 
SELECT 
	T2.Stmt.query('data(./@StatementId)') AS StatementId,
	T2.Stmt.value('fn:local-name(.)', 'varchar(200)') AS local_name,
	T2.Stmt.query('data(./@StatementText)') AS StatementText,
	T2.Stmt.query('data(./QueryPlan/@CachedPlanSize)') AS CachedPlanSize,
	T2.Stmt.query('data(./QueryPlan/@CompileTime)') AS CompileTime,
	T.query_plan.value('(/ShowPlanXML/@Build)[1]', 'varchar(18)') AS Build,
	T.query_hash,
	T.query_plan_hash
FROM
(
	SELECT TOP 1
		query_hash,
		query_plan_hash,
		text,
		query_plan
	FROM sys.dm_exec_query_stats
	OUTER APPLY
		sys.dm_exec_query_plan(plan_handle)
	OUTER APPLY
		sys.dm_exec_sql_text(sql_handle)
) AS T
CROSS APPLY query_plan.nodes('//StmtSimple') AS T2(Stmt);
GO


-- 特定のクエリの操作を取得
WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan' ) 
SELECT 
	T2.Stmt.query('data(./@NodeId)') AS NodeId,
	T2.Stmt.value('fn:local-name(.)', 'varchar(200)') AS local_name,
	T2.Stmt.query('data(./@PhysicalOp)') AS PhysicalOp,
	T2.Stmt.query('data(./@LogicalOp)') AS LogicalOp,
	T2.Stmt.query('data(./child::*/Object/@Table)') AS Table_Name,
	T2.Stmt.query('data(./child::*/Object/@Index)') AS Index_Name,
	T2.Stmt.query('data(./@EstimatedTotalSubtreeCost)') AS EstimatedTotalSubtreeCost,
	T2.Stmt.query('.')
FROM
(
	SELECT TOP 1
		query_hash,
		query_plan_hash,
		text,
		query_plan
	FROM sys.dm_exec_query_stats
	OUTER APPLY
		sys.dm_exec_query_plan(plan_handle)
	OUTER APPLY
		sys.dm_exec_sql_text(sql_handle)
) AS T
CROSS APPLY query_plan.nodes('//RelOp') AS T2(Stmt);
GO