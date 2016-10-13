SET NOCOUNT ON
GO

/*********************************************/
-- tempdb の使用状況の取得
/*********************************************/
USE [tempdb]
GO
SELECT
	DB_NAME([database_id]) AS [DatabaseName],
	FILE_NAME([file_id]) AS [FileName],
	[unallocated_extent_page_count],
	[version_store_reserved_page_count],
	[user_object_reserved_page_count],
	[internal_object_reserved_page_count],
	[mixed_extent_page_count]
FROM
	[sys].[dm_db_file_space_usage]
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
SELECT * FROM sys.dm_tran_active_snapshot_database_transactions 
ORDER BY transaction_sequence_num ASC 
