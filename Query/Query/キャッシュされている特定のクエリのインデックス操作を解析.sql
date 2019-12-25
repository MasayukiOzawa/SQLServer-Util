DECLARE @query_hash varbinary(max)  = 0x9BC39AF97F187CB7;
-- SELECT * FROM sys.dm_exec_query_stats CROSS APPLY sys.dm_exec_query_plan (plan_handle) WHERE query_hash = 0x9BC39AF97F187CB7 
WITH XMLNAMESPACES (DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan' )

SELECT
	statement.stmt.value('(@NodeId)[1]', 'int') AS NodeId,
	RANK() OVER (ORDER BY statement.stmt.value('(@EstimatedTotalSubtreeCost)[1]', 'float') DESC) AS SubtreeCost_Rank,
	statement.stmt.value('(@EstimatedTotalSubtreeCost)[1]', 'float') AS EstimatedTotalSubtreeCost,
	statement.stmt.value('(@PhysicalOp)[1]', 'nvarchar(255)') AS PhysicalOp,
	statement.stmt.value('(@LogicalOp)[1]', 'nvarchar(255)') AS LogicalOp,
	statement.stmt.value('(@EstimatedExecutionMode)[1]', 'nvarchar(10)') AS EstimatedExecutionMode,
	statement.stmt.value('(IndexScan/Object/@Database)[1]', 'nvarchar(255)') AS Database_Name,
	statement.stmt.value('(IndexScan/Object/@Schema)[1]', 'nvarchar(255)') AS Schema_Name,
	statement.stmt.value('(IndexScan/Object/@Table)[1]', 'nvarchar(255)') AS Table_Name,
	statement.stmt.value('(IndexScan/Object/@Index)[1]', 'nvarchar(255)') AS Index_Name,
	statement.stmt.value('(OutputList/ColumnReference/@Table)[1]', 'nvarchar(255)') AS Scan_Table_Name,
	statement.stmt.value('(@EstimateRows)[1]', 'float') AS EstimateRows,
	statement.stmt.value('(@EstimatedRowsRead)[1]', 'float') AS EstimatedRowsRead,
	statement.stmt.value('(@EstimateIO)[1]', 'float') AS EstimateIO,
	statement.stmt.value('(@EstimateCPU)[1]', 'float') AS EstimateCPU,
	statement.stmt.value('(@AvgRowSize)[1]', 'float') AS AvgRowSize,
	statement.stmt.value('(@Parallel)[1]', 'nvarchar(5)') AS Parallel,
	statement.stmt.value('(@TableCardinality)[1]', 'int') AS TableCardinality,
	statement.stmt.value('(../../QueryPlan/@CachedPlanSize)[1]', 'float') AS CachedPlanSize,
	statement.stmt.value('(../../QueryPlan/@CompileTime)[1]', 'float') AS CompileTime,
	statement.stmt.value('(../../QueryPlan/@CompileTime)[1]', 'float') AS CompileTime,
	statement.stmt.value('(../../QueryPlan/@CompileCPU)[1]', 'float') AS CompileCPU,
	statement.stmt.value('(../../QueryPlan/@CompileMemory)[1]', 'float') AS CompileMemory,
	statement.stmt.value('(../OptimizerHardwareDependentProperties/@EstimatedAvailableMemoryGrant)[1]', 'float') AS EstimatedAvailableMemoryGrant,
	statement.stmt.query('.') AS path_xml
FROM
	sys.dm_exec_query_stats AS qs
	CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
	CROSS APPLY qp.query_plan.nodes('//RelOp') AS statement(stmt)
WHERE
	qs.query_hash = @query_hash
	AND
	(
		statement.stmt.value('(@PhysicalOp)[1]', 'nvarchar(max)')  LIKE '%Index Seek'
		OR
		statement.stmt.value('(@PhysicalOp)[1]', 'nvarchar(max)')  LIKE '%Index Scan'
		OR
		statement.stmt.value('(@PhysicalOp)[1]', 'nvarchar(max)')  = 'Table Scan'
	)
OPTION (RECOMPILE)
