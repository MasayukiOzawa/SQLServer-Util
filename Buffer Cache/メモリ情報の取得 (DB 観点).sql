/*********************************************
SQL Server 2012 以降
**********************************************/

SET NOCOUNT ON
GO

/*********************************************/
-- キャッシュ内のエントリの取得
/*********************************************/ 
SELECT 
	m.type, 
	m.name, 
	p.name,
	SUM(m.pages_kb) AS pages_kb, 
	SUM(m.in_use_count) AS in_use_count, 
	m.is_dirty,
	SUM(m.disk_ios_count) AS disk_ios_count, 
	SUM(m.original_cost) AS original_cost, 
	SUM(m.current_cost) AS current_cost
FROM 
	sys.dm_os_memory_cache_entries AS m
	LEFT JOIN
	sys.dm_resource_governor_resource_pools AS p
	ON
	m.pool_id = p.pool_id
GROUP BY 
	m.name, 
	m.type,
	p.name,
	m.is_dirty
ORDER BY
	m.type, m.name

/*********************************************/
-- メモリ クラークの取得
/*********************************************/
SELECT
	[memory_node_id], 
	[type], 
	[name], 
	SUM([pages_kb]) AS [pages_kb], 
	SUM([virtual_memory_reserved_kb]) AS [virtual_memory_reserved_kb], 
	SUM([virtual_memory_committed_kb]) AS [virtual_memory_committed_kb], 
	SUM([awe_allocated_kb]) AS [awe_allocated_kb], 
	SUM([shared_memory_reserved_kb]) AS [shared_memory_reserved_kb], 
	SUM([shared_memory_committed_kb]) AS [shared_memory_committed_kb], 
	[page_size_in_bytes]
FROM
	[sys].[dm_os_memory_clerks]
GROUP BY
	[memory_node_id], 
	[type], 
	[name], 
	[page_size_in_bytes]
ORDER BY
	[type] ASC
OPTION (RECOMPILE)

/*********************************************/
-- メモリ オブジェクトの取得
/*********************************************/
SELECT 
	GETDATE() AS DATE, 
	[memory_node_id],  
	[type],
	[page_size_in_bytes],
	COUNT(*) AS page_count,
	SUM([page_size_in_bytes]) AS [page_size_in_bytes (Total)]
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
-- メモリ キャッシュカウンターの取得
/*********************************************/
SELECT
	*
FROM
	[sys].[dm_os_memory_cache_counters]
ORDER BY
	[type] ASC
OPTION (RECOMPILE)

/*********************************************/
-- メモリ プールの取得
/*********************************************/ 
SELECT
	*
FROM
	[sys].[dm_os_memory_pools]
ORDER BY
	[type] ASC
OPTION (RECOMPILE)
 
/*********************************************/
-- OS メモリの取得
/*********************************************/ 
SELECT
	*
FROM
	[sys].[dm_os_sys_info]
OPTION (RECOMPILE)

/*********************************************/
-- SQL Server メモリ情報
/*********************************************/ 
SELECT
	*
FROM 
	[sys].[dm_os_sys_memory]
OPTION (RECOMPILE)	




/*********************************************/
-- DBCC MEMORY STATUS の実行
-- 結果はテキストで取得する	
/*********************************************/
DBCC MEMORYSTATUS
