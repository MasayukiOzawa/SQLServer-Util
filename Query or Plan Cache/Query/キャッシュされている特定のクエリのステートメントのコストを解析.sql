DECLARE @query_hash varbinary(max)  = 0x9BC39AF97F187CB7;
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS showplan)

SELECT
	statement.stmt.value('(@StatementId)[1]', 'float') AS StatementId,
	RANK() OVER (ORDER BY statement.stmt.value('(showplan:QueryPlan/showplan:RelOp/@EstimatedTotalSubtreeCost)[1]', 'float') DESC) AS Cost_Rank,
	statement.stmt.value('(@StatementText)[1]', 'nvarchar(max)') AS sql_text,
	statement.stmt.value('(@QueryHash)[1]', 'nvarchar(255)') AS QueryHash,
	statement.stmt.value('(@QueryPlanHash)[1]', 'nvarchar(255)') AS QueryPlanHash,
	statement.stmt.value('(showplan:QueryPlan/showplan:RelOp/@EstimatedTotalSubtreeCost)[1]', 'float') AS EstimatedTotalSubtreeCost,
	statement.stmt.value('count(showplan:QueryPlan/showplan:RelOp/showplan:OutputList/showplan:ColumnReference)', 'float') AS ColumnReference_Count,
	statement.stmt.value('(showplan:QueryPlan/showplan:RelOp/@PhysicalOp)[1]', 'nvarchar(255)') AS First_PhysicalOp,
	statement.stmt.query('.') AS path_xml,
	statement.stmt.query('(showplan:QueryPlan/showplan:RelOp)') AS RelOp_xml
FROM
	sys.dm_exec_query_stats AS qs
	CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
	CROSS APPLY qp.query_plan.nodes('//showplan:StmtSimple') AS statement(stmt)
WHERE
	qs.query_hash = @query_hash
	AND
	qs.statement_start_offset = (SELECT TOP 1 statement_start_offset FROM sys.dm_exec_query_stats AS T WHERE T.query_hash = qs.query_hash)
ORDER BY StatementId ASC
OPTION(RECOMPILE)
