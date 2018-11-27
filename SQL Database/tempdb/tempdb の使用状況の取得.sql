/********************************************/
-- tempdb 使用状況の取得 
-- SQL Database では tempdb が DB 単位に独立しているため各 DB で取得
/********************************************/
SELECT 
	[database_files].[name], 
	[database_files].[type_desc],
	[database_files].[size] * 8.0 AS size,  
	[database_files].[max_size] * 8.0 AS max_size_KB,  
	[database_files].[growth],
	CASE is_percent_growth
		WHEN 0 THEN [database_files].[growth] * 8.0 
		ELSE [growth]
	END AS converted_growth,
	[database_files].[is_percent_growth],
	[fn_virtualfilestats].[NumberReads], 
	[fn_virtualfilestats].[IoStallReadMS], 
	[fn_virtualfilestats].[BytesRead],  
	[fn_virtualfilestats].[NumberWrites],  
	[fn_virtualfilestats].[IoStallWriteMS], 
	[fn_virtualfilestats].[BytesWritten],  
	[fn_virtualfilestats].[BytesOnDisk],
	[dm_db_file_space_usage].[unallocated_extent_page_count],
	[dm_db_file_space_usage].[version_store_reserved_page_count],
	[dm_db_file_space_usage].[user_object_reserved_page_count],
	[dm_db_file_space_usage].[internal_object_reserved_page_count],
	[dm_db_file_space_usage].[mixed_extent_page_count]
FROM 
	fn_virtualfilestats(2, NULL) 
	LEFT JOIN
	tempdb.sys.database_files
	ON
	database_files.file_id  = fn_virtualfilestats.FileId
	LEFT JOIN
	[tempdb].[sys].[dm_db_file_space_usage]
	ON
	database_files.file_id  = dm_db_file_space_usage.file_id
OPTION (RECOMPILE)
