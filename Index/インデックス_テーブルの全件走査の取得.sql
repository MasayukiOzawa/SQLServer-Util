-- 実行プランを XML インデックスで検索するため、物理テーブルに格納
-- 検索性能が遅くてもよいのであれば、検索クエリの FROM 句に指定することも可能
DROP TABLE IF EXISTS #tmp
GO
SELECT 
	ROW_NUMBER() OVER(ORDER BY query_hash ASC) AS No,
	query_hash,
	query_plan_hash,
	text,
	query_plan
INTO #tmp
FROM sys.dm_exec_query_stats
OUTER APPLY
	sys.dm_exec_query_plan(plan_handle)
OUTER APPLY
	sys.dm_exec_sql_text(sql_handle)
GO

ALTER TABLE #tmp ALTER COLUMN  No int NOT NULL
GO
ALTER TABLE #tmp ADD CONSTRAINT PK_Tmp_Query PRIMARY KEY CLUSTERED(No)
GO
CREATE PRIMARY XML INDEX PIdx_Tmp_Query ON #tmp(query_plan)  
GO

-- 実行プランから特定のテーブルの全件検索を実施しているクエリを取得
DECLARE @TableName sysname = QUOTENAME('LINEITEM')

;WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan' ) 
SELECT 
	query_hash,
	query_plan_hash,
	query_plan,
	T2.Stmt.value('fn:local-name(.)', 'varchar(200)') AS local_name,
	CAST(T2.Stmt.query('data(parent::*/parent::RelOp/@PhysicalOp)') AS varchar(255)) AS PhysicalOp,
	CAST(T2.Stmt.query('data(./@Database)') AS varchar(255)) AS Database_Name,
	CAST(T2.Stmt.query('data(./@Table)') AS varchar(255)) AS Table_Name,
	CAST(T2.Stmt.query('data(./@Index)') AS varchar(255)) AS Index_Name
FROM
(
	SELECT * FROM #tmp
) AS T
	CROSS APPLY query_plan.nodes('//Object') AS T2(Stmt)
WHERE
	(
		Stmt.exist('parent::*/parent::RelOp[@PhysicalOp = "Index Scan"]') > 0
		OR
		Stmt.exist('parent::*/parent::RelOp[@PhysicalOp = "Clustered Index Scan"]') > 0
		OR
		Stmt.exist('parent::*/parent::RelOp[@PhysicalOp = "Table Scan"]') > 0
	) AND CAST(T2.Stmt.query('data(./@Table)') AS varchar(255)) = @TableName