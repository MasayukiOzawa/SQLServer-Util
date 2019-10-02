exec sp_executesql @stmt=N'WITH system_allocated_memory(system_allocated_memory_in_mb) AS(
		SELECT ISNULL((SELECT CONVERT(decimal(18,2),(SUM(TMS.memory_allocated_for_table_kb) + SUM(TMS.memory_allocated_for_indexes_kb))/1024.00) 
		FROM [sys].[dm_db_xtp_table_memory_stats] TMS WHERE TMS.object_id <=0), 0.00)),
		table_index_memory(table_used_memory_in_mb, table_unused_memory_in_mb, index_used_memory_in_mb, index_unused_memory_in_mb) AS(
		SELECT ISNULL((SELECT CONVERT(decimal(18,2),(SUM(TMS.memory_used_by_table_kb)/1024.00))), 0.00) AS table_used_memory_in_mb,
			ISNULL((SELECT CONVERT(decimal(18,2),(SUM(TMS.memory_allocated_for_table_kb) - SUM(TMS.memory_used_by_table_kb))/1024.00)), 0.00) AS table_unused_memory_in_mb,
			ISNULL((SELECT CONVERT(decimal(18,2),(SUM(TMS.memory_used_by_indexes_kb)/1024.00))), 0.00) AS index_used_memory_in_mb,
			ISNULL((SELECT CONVERT(decimal(18,2),(SUM(TMS.memory_allocated_for_indexes_kb) - SUM(TMS.memory_used_by_indexes_kb))/1024.00)), 0.00) AS index_unused_memory_in_mb
		FROM [sys].[dm_db_xtp_table_memory_stats] TMS WHERE TMS.object_id > 0)
		SELECT 	s.system_allocated_memory_in_mb, t. table_used_memory_in_mb, t. table_unused_memory_in_mb, t. index_used_memory_in_mb, t. index_unused_memory_in_mb, 
			ISNULL((SELECT databasepropertyex(db_name(db_id()),''IsXTPSupported'')), 0) as has_memory_optimized_filegroup
		FROM system_allocated_memory s, table_index_memory t',@params=N''
go
exec sp_executesql @stmt=N'SELECT t.object_id, t.name, 
			ISNULL((SELECT CONVERT(decimal(18,2),(TMS.memory_used_by_table_kb)/1024.00)), 0.00) AS table_used_memory_in_mb,
			ISNULL((SELECT CONVERT(decimal(18,2),(TMS.memory_allocated_for_table_kb - TMS.memory_used_by_table_kb)/1024.00)), 0.00) AS table_unused_memory_in_mb,
			ISNULL((SELECT CONVERT(decimal(18,2),(TMS.memory_used_by_indexes_kb)/1024.00)), 0.00) AS index_used_memory_in_mb,
			ISNULL((SELECT CONVERT(decimal(18,2),(TMS.memory_allocated_for_indexes_kb - TMS.memory_used_by_indexes_kb)/1024.00)), 0.00) AS index_unused_memory_in_mb
		FROM sys.tables t JOIN sys.dm_db_xtp_table_memory_stats TMS ON (t.object_id = TMS.object_id)',@params=N''
go
