SET NOCOUNT ON
GO
 /*********************************************/
-- DBCC MEMORY STATUS の実行
-- 結果はテキストで取得する	
/*********************************************/
DBCC MEMORYSTATUS

 /*********************************************/
-- メモリークラークの取得
/*********************************************/
SELECT
	[memory_node_id], 
	[type], 
	[name], 
	SUM([single_pages_kb]) AS [single_pages_kb], 
	SUM([multi_pages_kb]) AS [multi_pages_kb], 
	SUM([virtual_memory_reserved_kb]) AS [virtual_memory_reserved_kb], 
	SUM([virtual_memory_committed_kb]) AS [virtual_memory_committed_kb], 
	SUM([awe_allocated_kb]) AS [awe_allocated_kb], 
	SUM([shared_memory_reserved_kb]) AS [shared_memory_reserved_kb], 
	SUM([shared_memory_committed_kb]) AS [shared_memory_committed_kb], 
	[page_size_bytes]
FROM
	[sys].[dm_os_memory_clerks]
GROUP BY
	[memory_node_id], 
	[type], 
	[name], 
	[page_size_bytes]
ORDER BY
	[type] ASC
OPTION (RECOMPILE)

 /*********************************************/
-- メモリーオブジェクトの取得
/*********************************************/
SELECT 
	GETDATE() AS DATE, 
	[memory_node_id],  
	[type],
	SUM([pages_allocated_count]) AS [pages_allocated_count (Total)], 
	[page_size_in_bytes],
	SUM ([pages_allocated_count] * [page_size_in_bytes]) / 1024 AS [Bytes Used (KB)]
FROM 
	[sys].[dm_os_memory_objects]
GROUP BY 
	[memory_node_id],  
	[page_size_in_bytes], 
	[type],
	[name]
ORDER BY 
	[type] ASC
OPTION (RECOMPILE)

 /*********************************************/
-- メモリーキャッシュカウンターの取得
/*********************************************/
SELECT
	[name],
	[type],
	[single_pages_kb], 
	[multi_pages_kb], 
	[single_pages_in_use_kb], 
	[multi_pages_in_use_kb], 
	[entries_count], 
	[entries_in_use_count]
FROM
	[sys].[dm_os_memory_cache_counters]
ORDER BY
	[type] ASC
OPTION (RECOMPILE)

 /*********************************************/
-- メモリープールの取得
/*********************************************/ 
SELECT
	[pool_id], 
	[type], 
	[name], 
	[max_free_entries_count], 
	[free_entries_count], 
	[removed_in_all_rounds_count]
FROM
	[sys].[dm_os_memory_pools ]
ORDER BY
	[type] ASC
OPTION (RECOMPILE)
 
 /*********************************************/
-- OS メモリの取得
/*********************************************/ 
SELECT
	[cpu_count], 
	[hyperthread_ratio],
	[physical_memory_in_bytes],
	[virtual_memory_in_bytes],
	[bpool_committed], 
	[bpool_committed] * 8.0 AS [bpool_committed (KB)],
	[bpool_commit_target], 
	[bpool_commit_target] * 8.0 AS [bpool_commit_target (KB)], 
	[bpool_visible], 
	[max_workers_count],
	[scheduler_count], 
	[scheduler_total_count]
--	[sqlserver_start_time], 
--	[virtual_machine_type], 
--	[virtual_machine_type_desc]
FROM
	[sys].[dm_os_sys_info]
OPTION (RECOMPILE)
