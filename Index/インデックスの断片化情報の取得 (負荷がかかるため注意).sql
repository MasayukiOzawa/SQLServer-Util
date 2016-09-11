SET NOCOUNT ON
GO

/*********************************************/
-- インデックスの設定状況の取得
/*********************************************/
DECLARE @DB_ID int
SET @DB_ID = DB_ID()

SELECT
	DB_NAME(DB_ID()),
	[sys].[schemas].[name], 
	[sys].[objects].[name],
	[sys].[indexes].[name],
	[sys].[dm_db_index_physical_stats].[partition_number],
	[sys].[dm_db_index_physical_stats].[index_type_desc],
	[sys].[dm_db_index_physical_stats].[alloc_unit_type_desc],
	[sys].[dm_db_index_physical_stats].[index_depth],
	[sys].[dm_db_index_physical_stats].[index_level],
	[sys].[indexes].[fill_factor], 
	[sys].[filegroups].[name], 
	[sys].[dm_db_index_physical_stats].[avg_fragmentation_in_percent], 
	[sys].[dm_db_index_physical_stats].[avg_fragment_size_in_pages], 
	[sys].[dm_db_index_physical_stats].[page_count], 
	[sys].[dm_db_index_physical_stats].[avg_page_space_used_in_percent], 
	[sys].[dm_db_index_physical_stats].[record_count], 
	[sys].[dm_db_index_physical_stats].[min_record_size_in_bytes], 
	[sys].[dm_db_index_physical_stats].[max_record_size_in_bytes], 
	[sys].[dm_db_index_physical_stats].[avg_record_size_in_bytes], 
	[sys].[dm_db_index_usage_stats].[user_seeks], 
	[sys].[dm_db_index_usage_stats].[last_user_seek], 
	[sys].[dm_db_index_usage_stats].[user_scans], 
	[sys].[dm_db_index_usage_stats].[last_user_scan], 
	[sys].[dm_db_index_usage_stats].[user_lookups], 
	[sys].[dm_db_index_usage_stats].[last_user_lookup], 
	[sys].[dm_db_index_usage_stats].[user_updates], 
	[sys].[dm_db_index_usage_stats].[last_user_update], 
	STATS_DATE([sys].[indexes].[object_id], [sys].[indexes].[index_id]) AS [stats_date]
FROM
	[sys].[indexes] WITH (NOLOCK)
	LEFT JOIN
		[sys].[objects] WITH (NOLOCK)
	ON
		[sys].[indexes].[object_id] = [sys].[objects].[object_id]
	LEFT JOIN
		[sys].[schemas] WITH (NOLOCK)
	ON
		[sys].[objects].[schema_id] = [sys].[schemas].[schema_id]
	LEFT JOIN
		[sys].[filegroups] WITH (NOLOCK)
	ON
		[sys].[indexes].[data_space_id] = [sys].[filegroups].[data_space_id]
	LEFT JOIN
		[sys].[dm_db_index_physical_stats](@DB_ID, NULL, NULL, NULL, 'LIMITED')
		ON
		[sys].[indexes].[object_id] = [sys].[dm_db_index_physical_stats].[object_id]
		AND
		[sys].[indexes].[index_id] = [sys].[dm_db_index_physical_stats].[index_id]
	LEFT JOIN
		[sys].[dm_db_index_usage_stats] WITH (NOLOCK)
		ON
		[sys].[indexes].[object_id] = [sys].[dm_db_index_usage_stats].[object_id]
		AND
		[sys].[indexes].[index_id] = [sys].[dm_db_index_usage_stats].[index_id]
		AND
		[sys].[dm_db_index_usage_stats].[database_id] = DB_ID()
WHERE
	[sys].[objects].[type] NOT IN ('S', 'IT')
	AND
	[sys].[dm_db_index_physical_stats].[fragment_count] IS NOT NULL
ORDER BY
	[sys].[indexes].[object_id] ASC, 
	[sys].[indexes].[index_id] ASC, 
	[sys].[dm_db_index_physical_stats].[partition_number] ASC
OPTION (RECOMPILE)

