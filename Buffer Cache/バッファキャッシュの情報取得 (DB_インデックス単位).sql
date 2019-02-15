SET NOCOUNT ON
GO

/********************************************/
-- バッファキャッシュの情報取得 (特定データベースのオブジェクト単位)
-- データベース単位で実行する
/********************************************/
SELECT 
	GETDATE() AS DATE,
	DB_NAME(bd.database_id) AS database_name,
	OBJECT_NAME(sp.object_id) AS object_name,
	bd.page_type,
	bd.is_modified,
	i.name,
	sp.partition_number,
	COUNT_BIG(*) AS page_count,
	COUNT_BIG(*) * 8 / 1024.0 AS page_size_mb,
	SUM(bd.row_count) AS row_count,
	SUM(bd.free_space_in_bytes) * 1.0 / POWER(1024, 2) AS free_space_in_mb
FROM 
	sys.dm_os_buffer_descriptors AS bd 
LEFT JOIN
	sys.allocation_units AS au WITH(NOLOCK)
ON
	bd.allocation_unit_id = au.allocation_unit_id
LEFT JOIN
	sys.partitions AS sp WITH(NOLOCK)
ON
	au.container_id = sp.hobt_id
LEFT JOIN
	sys.indexes AS i WITH(NOLOCK)
ON
	i.object_id = sp.object_id
	AND
	i.index_id = sp.index_id
WHERE
	bd.database_id = DB_ID()
	AND
	OBJECT_SCHEMA_NAME(sp.object_id) <> 'sys'
GROUP BY
	sp.object_id,
	bd.database_id,
	bd.page_type,
	sp.partition_number,
	i.name,
	is_modified
ORDER BY
	page_size_mb DESC,
	object_name,
	bd.page_type,
	sp.object_id
OPTION (MAXDOP 1, RECOMPILE)
