SET NOCOUNT ON
GO

/*********************************************/
-- tempdb の使用状況の取得
/*********************************************/
SELECT
	DB_NAME([database_id]) AS [DatabaseName],
	FILE_NAME([file_id]) AS [FileName],
	/*
	[total_page_count] * 8 / 1024 AS total_page_mb,
	[allocated_extent_page_count] * 8 / 1024 AS allocated_extent_page_mb,
	[modified_extent_page_count] * 8 / 1024 AS modified_extent_page_mb,
	*/
	[unallocated_extent_page_count] * 8 / 1024 AS unallocated_extent_page_mb,
	[version_store_reserved_page_count] * 8 / 1024 AS version_store_reserved_page_mb,
	[user_object_reserved_page_count] * 8 / 1024 AS [user_object_reserved_page_mb],
	[internal_object_reserved_page_count] * 8 / 1024 AS internal_object_reserved_page_mb,
	[mixed_extent_page_count] * 8 / 1024 AS mixed_extent_page_mb
FROM
	[tempdb].[sys].[dm_db_file_space_usage] WITH(NOLOCK)
OPTION (RECOMPILE)
GO

-- セッション単位の使用状況
SELECT 
	*
FROM 
	sys.dm_db_session_space_usage 
WHERE 
	(user_objects_alloc_page_count > 0 or user_objects_dealloc_page_count > 0 or internal_objects_alloc_page_count > 0 or internal_objects_dealloc_page_count > 0)

-- タスク単位の使用状況
SELECT 
	* 
FROM
	sys.dm_db_task_space_usage  
WHERE 
	(user_objects_alloc_page_count > 0 or user_objects_dealloc_page_count > 0 or internal_objects_alloc_page_count > 0 or internal_objects_dealloc_page_count > 0)

-- 行バージョンにアクセスする可能性のあるトランザクションの取得
SELECT 
	* 
FROM 
	sys.dm_tran_active_snapshot_database_transactions ast
	LEFT JOIN
	sys.dm_tran_current_transaction ct
	ON
	ast.transaction_sequence_num = ct.first_useful_sequence_num
WHERE 
	ast.commit_sequence_num IS NULL
ORDER BY 
	ast.transaction_sequence_num ASC 
