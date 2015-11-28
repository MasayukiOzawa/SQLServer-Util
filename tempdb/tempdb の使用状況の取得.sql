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

select * from sys.dm_db_file_space_usage
select * from sys.dm_db_session_space_usage where (user_objects_alloc_page_count > 0 or user_objects_dealloc_page_count > 0 or internal_objects_alloc_page_count > 0 or internal_objects_dealloc_page_count > 0)
select * from sys.dm_db_task_space_usage  where (user_objects_alloc_page_count > 0 or user_objects_dealloc_page_count > 0 or internal_objects_alloc_page_count > 0 or internal_objects_dealloc_page_count > 0)
