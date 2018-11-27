/********************************************/
-- 2 点で情報の取得を行い、特定期間の I/O を取得
/********************************************/

/********************************************/
-- ユーザーデータベースのファイルI/Oの発生状況を取得
/********************************************/
SELECT 
	[database_files].[name], 
	[database_files].[type_desc],
	[database_files].[size] * 8.0 AS size_KB,  
	[database_files].[max_size] * 8.0 AS max_size_KB,  
	[database_files].[growth],
	CASE [is_percent_growth]
		WHEN 0 THEN [database_files].[growth] * 8.0 
		ELSE [growth]
	END AS [converted_growth],
	[database_files].[is_percent_growth],
	[fn_virtualfilestats].[NumberReads], 
	[fn_virtualfilestats].[IoStallReadMS], 
	[fn_virtualfilestats].[BytesRead],  
	[fn_virtualfilestats].[NumberWrites],  
	[fn_virtualfilestats].[IoStallWriteMS], 
	[fn_virtualfilestats].[BytesWritten],  
	[fn_virtualfilestats].[BytesOnDisk] 
FROM 
	fn_virtualfilestats(DB_ID(), NULL) 
	LEFT JOIN
	sys.database_files
	ON
	database_files.file_id  = fn_virtualfilestats.FileId
OPTION (RECOMPILE)
GO

SELECT 
	SUM([fn_virtualfilestats].[BytesRead]) AS [BytesRead],  
	SUM([fn_virtualfilestats].[BytesWritten]) AS [BytesWritten]
FROM 
	fn_virtualfilestats(DB_ID(), NULL) 
	LEFT JOIN
	sys.database_files
	ON
	database_files.file_id  = fn_virtualfilestats.FileId
OPTION (RECOMPILE)
GO

SELECT
	RTRIM(t1.instance_name) AS instance_name,
	t2.cntr_value AS [Read Bytes/sec],
	t3.cntr_value AS [Write Bytes/sec],
	t4.cntr_value AS [Transfers/Sec],
	CASE t6.cntr_value
		WHEN 0 THEN 0
		ELSE t5.cntr_value / t6.cntr_value 
	END AS [Avg. Bytes/Read],
	CASE t8.cntr_value
		WHEN 0 THEN 0
		ELSE t7.cntr_value / t8.cntr_value 
	END AS [Avg. Bytes/Write],
	CASE t10.cntr_value
		WHEN 0 THEN 0
		ELSE t9.cntr_value / t10.cntr_value 
	END AS [Avg. microsec/Read],
	CASE t12.cntr_value
		WHEN 0 THEN 0
		ELSE t11.cntr_value / t12.cntr_value 
	END AS [Avg. microsec/Write]
FROM
	sys.dm_os_performance_counters t1
	INNER JOIN
	(SELECT	instance_name,cntr_value
	FROM sys.dm_os_performance_counters
	WHERE counter_name = 'Read Bytes/sec') AS t2
	ON t1.instance_name = t2.instance_name
	INNER JOIN
	(SELECT	instance_name,cntr_value
	FROM sys.dm_os_performance_counters
	WHERE counter_name = 'Write Bytes/sec') AS t3
	ON t1.instance_name = t3.instance_name
	INNER JOIN
	(SELECT	instance_name,cntr_value
	FROM sys.dm_os_performance_counters
	WHERE counter_name = 'Transfers/Sec') AS t4
	ON t1.instance_name = t4.instance_name
	INNER JOIN
	(SELECT	instance_name,cntr_value
	FROM sys.dm_os_performance_counters
	WHERE counter_name = 'Avg. Bytes/Read') AS t5
	ON t1.instance_name = t5.instance_name
	INNER JOIN
	(SELECT	instance_name,cntr_value
	FROM sys.dm_os_performance_counters
	WHERE counter_name = 'Avg. Bytes/Read BASE') AS t6
	ON t1.instance_name = t6.instance_name
	INNER JOIN
	(SELECT	instance_name,cntr_value
	FROM sys.dm_os_performance_counters
	WHERE counter_name = 'Avg. Bytes/Write') AS t7
	ON t1.instance_name = t7.instance_name
	INNER JOIN
	(SELECT	instance_name,cntr_value
	FROM sys.dm_os_performance_counters
	WHERE counter_name = 'Avg. Bytes/Write BASE') AS t8
	ON t1.instance_name = t8.instance_name
	INNER JOIN
	(SELECT	instance_name,cntr_value
	FROM sys.dm_os_performance_counters
	WHERE counter_name = 'Avg. microsec/Read') AS t9
	ON t1.instance_name = t9.instance_name
	INNER JOIN
	(SELECT	instance_name,cntr_value
	FROM sys.dm_os_performance_counters
	WHERE counter_name = 'Avg. microsec/Read BASE') AS t10
	ON t1.instance_name = t10.instance_name
	INNER JOIN
	(SELECT	instance_name,cntr_value
	FROM sys.dm_os_performance_counters
	WHERE counter_name = 'Avg. microsec/Write') AS t11
	ON t1.instance_name = t11.instance_name
	INNER JOIN
	(SELECT	instance_name,cntr_value
	FROM sys.dm_os_performance_counters
	WHERE counter_name = 'Avg. microsec/Write BASE') AS t12
	ON t1.instance_name = t12.instance_name
WHERE
	t1.object_name LIKE '%HTTP Storage%'
	AND t1.instance_name <> '_Total'
GROUP BY
	t1.instance_name,
	t2.cntr_value,
	t3.cntr_value,
	t4.cntr_value,
	t5.cntr_value,
	t6.cntr_value,
	t7.cntr_value,
	t8.cntr_value,
	t9.cntr_value,
	t10.cntr_value,
	t11.cntr_value,
	t12.cntr_value
ORDER BY
	t1.instance_name
OPTION (RECOMPILE)
