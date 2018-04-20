DECLARE @xml xml = '
';
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
	@xml.nodes('//showplan:StmtSimple') AS statement(stmt)
ORDER BY StatementId ASC
OPTION(RECOMPILE)
