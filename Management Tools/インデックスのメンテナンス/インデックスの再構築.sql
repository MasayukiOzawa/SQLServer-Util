DECLARE @SchemaName sysname, @TableName sysname, @IndexName sysname, @IndexType tinyint, @PartitionNumber int, @PartitionCount int, @Fragment float, @PageCount bigint, @IncludeColumnstore bit
DECLARE @basesql nvarchar(max), @sql nvarchar(max) 
DECLARE @Edition nvarchar(max)

DECLARE @PageThreshold int = 1000			-- メンテナンス対象とするページの数の閾値
DECLARE @ReorganizeThreshold int = 15		-- REORGANIZE の閾値
DECLARE @RebuildThreshold int = 30			-- REBUILD の閾値
DECLARE @OnlineOnly bit = 1					--  0 : Enterprise Edition の REBUILD で ONLINE = ON が使用できない構成でも再構築を実施

DECLARE @StartDate AS datetime2 = (SELECT SYSDATETIME())

PRINT 'Index Maintenance Start:' + CAST(@StartDate AS sysname)

SET @Edition = CONVERT(nvarchar, SERVERPROPERTY('Edition'))

-- Live Query 統計が取得できるよう、PROFILE ON を実施
SET @basesql = 'SET STATISTICS PROFILE ON;ALTER INDEX @1 On @2.@3 REBUILD @4 @5'

-- Enterprise と SQL Database はオンラインでのインデックス再構築を基本とする
IF PATINDEX('%Enterprise%', @Edition) > 0 or PATINDEX('%SQL Azure%', @Edition) > 0
    SET @basesql = REPLACE(@basesql, '@5', 'WITH (ONLINE=ON)') 
ELSE 
    SET @basesql = REPLACE(@basesql, '@5', '')

DECLARE IXC CURSOR FOR 

SELECT DISTINCT
	OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName
    , OBJECT_NAME(i.object_id) AS TableName 
    , name AS IndexName
	, type AS IndexType
	, ps.partition_number AS PartitionNumber
	, p.partition_count
	, COALESCE(include_columnstore, 0) AS IncludeColumnstore
	, ps.avg_fragmentation_in_percent AS Fragment
	, ps.page_count AS PageCount
FROM 
    sys.indexes i
CROSS APPLY
(
	SELECT
		COUNT(*) 
	FROM
		sys.partitions p
	WHERE
		p.object_id = i.object_id
		AND
		p.index_id = i.index_id
) AS p(partition_count)
OUTER APPLY
(
	SELECT
		1
	FROM
		sys.indexes c
	WHERE
		c.object_id = i.object_id
		AND
		c.type IN (5,6)
)AS c(include_columnstore)
OUTER APPLY
(
	/*
	SQL Server 2014 より前のバージョンは、In-Memory OLTP の判断ができないため、本ブロックは SELECT NULL のみに入れ替える
	SELECT NULL
	*/
	SELECT
		1
	FROM
		sys.dm_db_xtp_object_stats m
	WHERE
		m.object_id = i.object_id
)AS m(is_memory)
CROSS APPLY
	sys.dm_db_index_physical_stats(DB_ID(), object_id, index_id, NULL, 'LIMITED') AS ps
WHERE 
    OBJECT_SCHEMA_NAME (i.object_id) <> 'sys' 
    AND 
    i.index_id > 0 
	AND
	ps.index_level = 0 AND ps.alloc_unit_type_desc = 'IN_ROW_DATA'
	-- In-Memory テーブルは ALTER INDEX をサポートしていないため除外
	AND
	is_memory IS NULL
ORDER BY 1


OPEN IXC

FETCH NEXT FROM IXC 
INTO @SchemaName, @TableName, @IndexName, @IndexType, @PartitionNumber, @PartitionCount, @IncludeColumnstore, @Fragment, @PageCount

WHILE @@FETCH_STATUS = 0 
BEGIN 
	PRINT @SchemaName + '.' + @TableName + ':' + @IndexName + ':' +  CAST(@IndexType AS nvarchar(1)) + ':' +  CAST(@PartitionNumber AS nvarchar(3)) + ':' +  CAST(@PartitionCount AS nvarchar(3)) + ':IncludeColumnstore=' + CAST(@IncludeColumnstore AS nvarchar(1)) + ':Fragment=' +  CAST(CAST(@Fragment AS int) AS nvarchar(3)) + ':Page Count=' +  CAST(@PageCount AS nvarchar(255))
	-- 断片化が 15% 以内の場合かつ、1,000 ページ以下の場合、メンテナンスは実施しない
	-- 列ストアインデックスについては、断片化 / ページカウントが 0 となるため、本スクリプトでは再構築は行われない
	IF @Fragment > @ReorganizeThreshold AND @PageCount > @PageThreshold
	BEGIN
		SET @sql = REPLACE(@basesql,	'@1', QUOTENAME(@IndexName)) 
		SET @sql = REPLACE(@sql,		'@2', QUOTENAME(@SchemaName)) 
		SET @sql = REPLACE(@sql,		'@3', QUOTENAME(@TableName))
		IF @PartitionCount > 1
			SET @sql = REPLACE(@sql,		'@4', N'PARTITION = ' + CAST(@PartitionNumber AS nvarchar(3)))
		ELSE
			SET @sql = REPLACE(@sql,		'@4', '')
		-- 断片化が 30% 以上の場合は再構築
		IF @Fragment >= @RebuildThreshold
		BEGIN
			-- 列ストアインデックス含むテーブル / XML インデックスはオンライン再構築ができないためオフラインで再構築
			IF @IncludeColumnstore = 1 Or @IndexType = 3
			BEGIN
				-- Online Only が有効な場合、オンライン → オフラインへの変更は行わない
				IF @OnlineOnly = 0 
				BEGIN
					SET @sql = REPLACE(@sql, 'WITH (ONLINE=ON)', '')
					EXECUTE (@sql)
				END
				ELSE
					PRINT 'REBUILD Skip'
			END
			ELSE
				EXECUTE (@sql)	
		END
		-- 30% 未満は再構成
		ELSE
		BEGIN
			SET @sql = REPLACE(@sql, 'REBUILD', 'REORGANIZE')
			SET @sql = REPLACE(@sql, 'WITH (ONLINE=ON)', '')

			EXECUTE (@sql)
		END
		PRINT @sql 

	END 
    FETCH NEXT FROM IXC 
    INTO @SchemaName, @TableName, @IndexName, @IndexType, @PartitionNumber, @PartitionCount, @IncludeColumnstore, @Fragment, @PageCount
END

CLOSE IXC 
DEALLOCATE IXC

PRINT 'Index Maintenance End:' + CAST(SYSDATETIME() AS sysname)
PRINT 'Total Time (Sec):' + CAST(DATEDIFF(ss, @StartDate, SYSDATETIME()) AS sysname)