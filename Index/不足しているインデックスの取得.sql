SET NOCOUNT ON
GO
/*********************************************/
-- 不足しているインデックスの取得
/*********************************************/
SELECT 
	DB_NAME(mid.[database_id]) AS [DatabaseName], 
	[mid].[index_handle],
	OBJECT_NAME(mid.[object_id]) As [ObjectName],
	[avg_user_impact],
	[avg_total_user_cost],
	REPLACE([equality_columns], ',', '|') AS [equality_columns], 
	REPLACE([inequality_columns], ',', '|') AS  [inequality_columns],
	REPLACE([included_columns], ',', '|') AS [included_columns],
	[user_seeks],
	[last_user_seek],
	[user_scans],
	[last_user_scan], 
	[statement]
FROM 
	[sys].[dm_db_missing_index_details] mid
	left join
	sys.dm_db_missing_index_groups mig
	on
	mid.index_handle = mig.index_handle
	left join
	sys.dm_db_missing_index_group_stats migs
	on
	migs.group_handle = mig.index_group_handle
WHERE
	database_id = DB_ID()
	OR
	database_id IS NULL
ORDER BY
	[DatabaseName] ASC, 
	[ObjectName] ASC
OPTION (RECOMPILE)

