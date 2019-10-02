exec sp_executesql @stmt=N'
-- This calculates the number of migration blockers
		
--we need to filter out memory optimized tables
--but is_memory_optimized is only defined on SQL14+ instances
--so, we should only execute the query if hekaton is supported
DECLARE @IsXtpSupported BIT
DECLARE @SQLMAJORVERSION INT
DECLARE @SQL13AZURE12 BIT

SELECT @IsXtpSupported = CAST(ISNULL(SERVERPROPERTY(''ISXTPSUPPORTED''), 0) AS BIT)
SELECT @SQLMAJORVERSION  = LEFT(CONVERT(SYSNAME,SERVERPROPERTY(''ProductVersion'')), CHARINDEX(''.'', CONVERT(SYSNAME,SERVERPROPERTY(''ProductVersion'')), 0)-1)
SET @SQL13AZURE12 = 0
IF @IsXtpSupported = 1
BEGIN
IF CAST(SERVERPROPERTY(''ENGINEEDITION'') AS INT) = 5
BEGIN
IF @SQLMAJORVERSION >= 12
SET @SQL13AZURE12 = 1
END
ELSE
BEGIN
IF @SQLMAJORVERSION >= 13
SET @SQL13AZURE12 = 1
END
END

DECLARE @MemoryOptimizedTables TABLE(table_id int NOT NULL)
DECLARE @DefaultContraintTables TABLE(table_id int NOT NULL)
DECLARE @command NVARCHAR(1000)

SET @command = N''SELECT [object_id] FROM sys.tables WHERE [is_memory_optimized] = 1''
IF @IsXtpSupported = 1 BEGIN 
INSERT INTO @MemoryOptimizedTables EXEC (@command)
END
SET @command = N''SELECT [parent_object_id] FROM sys.default_constraints''
IF @SQL13AZURE12 = 0 BEGIN 
INSERT INTO @DefaultContraintTables EXEC (@command)
END

DECLARE @constraint_table TABLE
(
	table_id int not null,
	migration_rating int not null
)
INSERT INTO @constraint_table
SELECT
    table_id, 
    COUNT(constraint_name) AS migration_rating
FROM (
    SELECT  
		t.parent_object_id AS [table_id], 
        t.name AS [constraint_name]
    FROM sys.check_constraints t 
    JOIN sys.tables tbl ON tbl.object_id = t.parent_object_id
    WHERE tbl.is_ms_shipped = 0 
        AND object_name(t.parent_object_id,DB_ID()) IS NOT NULL
    UNION
    SELECT 
		t.parent_object_id AS [table_id], 
        t.name AS [constraint_name]
    FROM sys.default_constraints t 
    JOIN sys.tables tbl ON tbl.object_id = t.parent_object_id
    WHERE tbl.is_ms_shipped = 0 
        AND object_name(t.parent_object_id,DB_ID()) IS NOT NULL
        AND t.parent_object_id IN (SELECT * FROM @DefaultContraintTables)
    UNION
    SELECT  
		t.parent_object_id AS [table_id], 
        t.name AS [constraint_name]
    FROM sys.foreign_keys t 
    JOIN sys.tables tbl ON tbl.object_id = t.parent_object_id
    WHERE tbl.is_ms_shipped = 0 
        AND object_name(t.parent_object_id,DB_ID()) IS NOT NULL
    UNION
    SELECT  
		t.object_id AS [table_id], 
        t.name AS [constraint_name]
    FROM sys.indexes t 
    JOIN sys.tables tbl ON tbl.object_id = t.object_id
    WHERE tbl.is_ms_shipped = 0 
        AND object_name(t.object_id,DB_ID()) IS NOT NULL 
        AND (((t.is_unique = 1 OR t.is_unique_constraint = 1) AND t.is_primary_key = 0)
        OR t.type > 2)
    UNION
    SELECT 
		t.object_id AS [table_id], 
        c.name AS [constraint_name] 
    FROM sys.index_columns ic
    JOIN sys.tables t ON t.object_id = ic.object_id
    JOIN sys.all_columns c ON ic.column_id = c.column_id AND t.object_id = c.object_id
    WHERE t.is_ms_shipped = 0 AND c.is_nullable = 1
    UNION
    SELECT  
		tb.object_id AS [table_id],
        tr.name AS [constraint_name]
    FROM sys.triggers tr 
    JOIN sys.tables tb ON tr.parent_id = tb.object_id 
    WHERE tr.is_ms_shipped = 0 
        AND tr.parent_class = 1
    UNION
    SELECT 
		t.object_id AS [table_id], 
        t.name AS [constraint_name]
    FROM sys.all_columns t 
    JOIN sys.tables tbl ON tbl.object_id = t.object_id
    JOIN sys.types tp ON t.user_type_id = tp.user_type_id
    LEFT JOIN sys.identity_columns ic ON t.object_id = ic.object_id AND t.column_id = ic.column_id
    WHERE tbl.is_ms_shipped = 0 AND
        (t.is_computed = 1
        OR t.is_sparse = 1
        OR (t.is_identity = 1 AND (ic.increment_value != 1 OR ic.seed_value != 1))
        OR t.user_type_id != t.system_type_id
        OR tp.is_assembly_type = 1
        OR UPPER(tp.name) IN (''DATETIMEOFFSET'', ''GEOGRAPHY'', ''GEOMETRY'', ''SQL_VARIANT'', ''HIERARCHYID'', ''XML'', ''IMAGE'', ''XML'', ''TEXT'', ''NTEXT'', ''TIMESTAMP'')
        OR t.is_filestream = 1
        OR t.max_length = -1)
) AS t
GROUP BY table_id
HAVING table_id NOT IN (SELECT * FROM @MemoryOptimizedTables)

-- This calculates the gain after migration

DECLARE @sum_table TABLE
(
	database_id int,
	singleton_sum bigint,
	range_sum bigint,
	page_latch_wait_time_sum bigint
)

INSERT INTO @sum_table
SELECT 
	i.database_id,
	-- to ensure that the denominator is never 0
	ISNULL(NULLIF(SUM(i.singleton_lookup_count), 0), 1) as singleton_sum,
	ISNULL(NULLIF(SUM(i.range_scan_count), 0), 1) as range_sum,
	ISNULL(NULLIF(SUM(i.page_latch_wait_in_ms), 0), 1) as page_latch_wait_time_sum
FROM sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) i
WHERE i.object_id IN (SELECT object_id FROM sys.tables)
GROUP BY i.database_id

SELECT TOP (@num_tbls)
	i.database_id,
	SCHEMA_NAME(t.schema_id) as schema_name,
	t.object_id as table_id,
	t.name AS table_name,
	ISNULL(c.migration_rating, 0) AS migration_difficulty,
	(CAST(SUM(i.singleton_lookup_count) AS FLOAT) / CAST(st.singleton_sum AS FLOAT) + CAST(SUM(i.page_latch_wait_in_ms) AS FLOAT) / CAST(st.page_latch_wait_time_sum AS FLOAT)) AS migration_indicator
FROM sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) i
JOIN sys.tables t ON t.object_id = i.object_id
JOIN @sum_table st ON st.database_id = i.database_id
LEFT JOIN @constraint_table c ON i.object_id = c.table_id
GROUP BY i.database_id, t.schema_id, t.object_id, t.name, c.migration_rating, st.singleton_sum, st.page_latch_wait_time_sum
ORDER BY migration_indicator DESC',@params=N'@num_tbls Int',@num_tbls=5
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
