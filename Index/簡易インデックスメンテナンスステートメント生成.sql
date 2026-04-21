SELECT
	ps.object_id, OBJECT_SCHEMA_NAME(ps.object_id) AS schema_name, OBJECT_NAME(ps.object_id) AS object_name,
	i.name, ps.index_id, ps.partition_number, 
	ps.used_page_count * 8 / 1024 AS used_page_MiB,
	(ps.reserved_page_count - ps.used_page_count) * 8 / 1024 AS unused_page_MiB ,
	p.data_compression_desc,
	CASE 
		WHEN i.data_space_id = 1 THEN
			'ALTER INDEX ' + i.name + ' ON ' + 
			QUOTENAME(OBJECT_SCHEMA_NAME(ps.object_id)) + '.' + QUOTENAME(OBJECT_NAME(ps.object_id)) + 
			' REORGANIZE'
		ELSE 
			'ALTER INDEX ' + i.name + ' ON ' + 
			QUOTENAME(OBJECT_SCHEMA_NAME(ps.object_id)) + '.' + QUOTENAME(OBJECT_NAME(ps.object_id)) + 
			' REORGANIZE PARTITION=' + CAST(ps.partition_number AS nvarchar(10)) 
	END AS maintenance_query,
	SUM((ps.reserved_page_count - ps.used_page_count) * 8 / 1024) OVER() AS total_unused_page_MiB
FROM sys.dm_db_partition_stats AS ps
	INNER JOIN sys.indexes AS i
		ON i.object_id = ps.object_id AND i.index_id = ps.index_id
	INNER JOIN sys.partitions AS p
		ON p.object_id = ps.object_id AND p.index_id = ps.index_id AND p.partition_number = ps.partition_number
ORDER BY 
	(reserved_page_count - used_page_count) DESC