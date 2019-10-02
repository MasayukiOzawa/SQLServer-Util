exec sp_executesql @stmt=N'
--we need to filter out native stored procedures
--but uses_native_compilation is only defined on SQL14+ instances
--so, we should only execute the query if native compilation is supported
DECLARE @IsNativeSPSupported BIT
SELECT @IsNativeSPSupported = CAST(ISNULL(SERVERPROPERTY(''ISXTPSUPPORTED''), 0) AS BIT)
DECLARE @NativeProcs TABLE(proc_id int NOT NULL)
DECLARE @command NVARCHAR(1000)
SET @command = N''SELECT object_id FROM sys.sql_modules WHERE uses_native_compilation = 1''
IF @IsNativeSPSupported = 1 BEGIN 
INSERT INTO @NativeProcs EXEC (@command)
END

SELECT  TOP (@sp_count)
		SCHEMA_NAME(p.schema_id) as schema_name,
		d.object_id AS sp_id, 
        OBJECT_NAME(d.object_id, database_id) AS [sp_name],
        SUM(d.total_worker_time) AS [total_worker_time], 
        ISNULL(tableref.count_referenced_tables, 0) AS migration_difficulty
FROM sys.dm_exec_procedure_stats AS d 
JOIN sys.procedures p ON p.object_id = d.object_id
LEFT JOIN (
	SELECT dep.referencing_id AS referencing_object_id,
		count(dep.referenced_id) AS count_referenced_tables
	FROM sys.sql_expression_dependencies dep
	WHERE 
		dep.referencing_id NOT IN (SELECT proc_id FROM @NativeProcs)
		-- we only want proc references
		AND dep.referencing_id IN (SELECT object_id FROM sys.procedures WHERE is_ms_shipped = 0) 
		-- this eliminates any non-table references within the proc''s resident database. 
		-- Outside the proc''s resident database, we can''t get any information because the ID is null.
		AND dep.referenced_class = 1 
		AND (dep.referenced_id IN (SELECT object_id FROM sys.tables) OR dep.referenced_id IS NULL)
		AND is_ambiguous = 0
		AND is_caller_dependent = 0
	GROUP BY
		dep.referencing_id
	) AS tableref
ON tableref.referencing_object_id = d.object_id
WHERE d.database_id = DB_ID(@dbName)
AND d.object_id NOT IN (SELECT proc_id FROM @NativeProcs)
GROUP BY d.object_id, d.database_id, p.schema_id, tableref.count_referenced_tables
ORDER BY total_worker_time DESC
		',@params=N'@dbName NVarChar(max), @sp_count Int',@dbName=N'TEST',@sp_count=5
go
exec sp_executesql @stmt=N'SELECT 5 AS count
		UNION
		SELECT 10 AS count
		UNION 
		SELECT 15 AS count
		UNION 
		SELECT 20 AS count
		UNION 
		SELECT 25 AS count
		UNION 
		SELECT 30 AS count',@params=N''
go
