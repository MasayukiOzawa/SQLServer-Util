/*******************************************/
-- ファイルに保存する場合は、SSMS のツール→オプションから
-- クエリ結果→ SQL Server → 結果をテキストで表示を
-- タブ区切り / 各列に表示される最大文字数を 8000 で取得する
/*******************************************/

SET NOCOUNT ON
GO
USE master
GO

/*********************************************/
-- 実行回数の高いクエリ TOP 300
/*********************************************/
SELECT TOP 300
	GETDATE() AS DATE,
	'HighExecution' AS type, 
	[total_elapsed_time] / [execution_count] / 1000.0 AS [Average Elapsed Time (ms)], 
	[total_worker_time]  / [execution_count] / 1000.0 AS [Average Worker Time (ms)], 
	[total_physical_reads] / [execution_count] AS [Average Physical Read Count], 
	[total_logical_reads] / [execution_count] AS [Average Logical Read Count], 
	[total_logical_writes]  / [execution_count] AS [Average Logical Write], 
	[total_elapsed_time] / 1000.0 AS [total_elapsed_time (ms)],
	[total_worker_time] / 1000.0  AS [total_worker_time (ms)],
	[total_physical_reads] AS [total_physical_reads (page)],
	[total_logical_reads] AS [total_logical_reads (page)],
	[total_logical_writes] AS [total_logical_writes (page)],
	[execution_count], 
	[plan_generation_num],
	[creation_time],
	[last_execution_time],
	DB_NAME(st.dbid) AS db_name,
	REPLACE(REPLACE(REPLACE(SUBSTRING(text, 
	([statement_start_offset] / 2) + 1, 
	((CASE [statement_end_offset]
	WHEN -1 THEN DATALENGTH(text)
	ELSE [statement_end_offset]
	END - [statement_start_offset]) / 2) + 1),CHAR(13), ' '), CHAR(10), ' '), CHAR(9), ' ') AS [stmt_text],
	REPLACE(REPLACE(REPLACE([text],CHAR(13), ''), CHAR(10), ' '), CHAR(9), ' ') AS [text]
	--,query_plan
FROM
	[sys].[dm_exec_query_stats]
	CROSS APPLY 
	[sys].[dm_exec_sql_text]([sql_handle]) AS st
	CROSS APPLY
	[sys].[dm_exec_query_plan]([plan_handle])
ORDER BY
	[execution_count] DESC
OPTION (RECOMPILE)

/*********************************************/
-- 平均 CPU 使用率の高いクエリ TOP 300
/*********************************************/
SELECT TOP 300
	GETDATE() AS DATE,
	'HighAvgCPU' AS type, 
	[total_elapsed_time] / [execution_count] / 1000.0 AS [Average Elapsed Time (ms)], 
	[total_worker_time]  / [execution_count] / 1000.0 AS [Average Worker Time (ms)], 
	[total_physical_reads] / [execution_count] AS [Average Physical Read Count], 
	[total_logical_reads] / [execution_count] AS [Average Logical Read Count], 
	[total_logical_writes]  / [execution_count] AS [Average Logical Write Count], 
	[total_elapsed_time] / 1000.0 AS [total_elapsed_time (ms)],
	[total_worker_time] / 1000.0  AS [total_worker_time (ms)],
	[total_physical_reads] AS [total_physical_reads (page)],
	[total_logical_reads] AS [total_logical_reads (page)],
	[total_logical_writes] AS [total_logical_writes (page)],
	[execution_count], 
	[plan_generation_num],
	[creation_time],
	[last_execution_time],
	DB_NAME(st.dbid) AS db_name,
	REPLACE(REPLACE(REPLACE(SUBSTRING(text, 
	([statement_start_offset] / 2) + 1, 
	((CASE [statement_end_offset]
	WHEN -1 THEN DATALENGTH(text)
	ELSE [statement_end_offset]
	END - [statement_start_offset]) / 2) + 1),CHAR(13), ' '), CHAR(10), ' '), CHAR(9), ' ') AS [stmt_text],
	REPLACE(REPLACE(REPLACE([text],CHAR(13), ''), CHAR(10), ' '), CHAR(9), ' ') AS [text]
	--,query_plan
FROM
	[sys].[dm_exec_query_stats]
	CROSS APPLY 
	[sys].[dm_exec_sql_text]([sql_handle]) AS st
	CROSS APPLY
	[sys].[dm_exec_query_plan]([plan_handle])
ORDER BY
	[Average Worker Time (ms)] DESC
OPTION (RECOMPILE)

/*********************************************/
-- 実行時間の高いクエリ TOP 300
/*********************************************/
SELECT TOP 300
	GETDATE() AS DATE,
	'HighAvgElapsedTime' AS type, 
	[total_elapsed_time] / [execution_count] / 1000.0 AS [Average Elapsed Time (ms)], 
	[total_worker_time]  / [execution_count] / 1000.0 AS [Average Worker Time (ms)], 
	[total_physical_reads] / [execution_count] AS [Average Physical Read Count], 
	[total_logical_reads] / [execution_count] AS [Average Logical Read Count], 
	[total_logical_writes]  / [execution_count] AS [Average Logical Write Count], 
	[total_elapsed_time] / 1000.0 AS [total_elapsed_time (ms)],
	[total_worker_time] / 1000.0  AS [total_worker_time (ms)],
	[total_physical_reads] AS [total_physical_reads (page)],
	[total_logical_reads] AS [total_logical_reads (page)],
	[total_logical_writes] AS [total_logical_writes (page)],
	[execution_count], 
	[plan_generation_num],
	[creation_time],
	[last_execution_time],
	DB_NAME(st.dbid) AS db_name,
	REPLACE(REPLACE(REPLACE(SUBSTRING(text, 
	([statement_start_offset] / 2) + 1, 
	((CASE [statement_end_offset]
	WHEN -1 THEN DATALENGTH(text)
	ELSE [statement_end_offset]
	END - [statement_start_offset]) / 2) + 1),CHAR(13), ' '), CHAR(10), ' '), CHAR(9), ' ') AS [stmt_text],
	REPLACE(REPLACE(REPLACE([text],CHAR(13), ''), CHAR(10), ' '), CHAR(9), ' ') AS [text]
	--,query_plan
FROM
	[sys].[dm_exec_query_stats]
	CROSS APPLY 
	[sys].[dm_exec_sql_text]([sql_handle]) AS st
	CROSS APPLY
	[sys].[dm_exec_query_plan]([plan_handle])
ORDER BY
	[Average Elapsed Time (ms)] DESC
OPTION (RECOMPILE)

	

/*********************************************/
-- 平均読み取り回数の高いクエリ TOP 300
/*********************************************/
SELECT TOP 300
	GETDATE() AS DATE,
	'HighAvgRead' AS type, 
	[total_elapsed_time] / [execution_count] / 1000.0 AS [Average Elapsed Time (ms)], 
	[total_worker_time]  / [execution_count] / 1000.0 AS [Average Worker Time (ms)], 
	[total_physical_reads] / [execution_count] AS [Average Physical Read Count], 
	[total_logical_reads] / [execution_count] AS [Average Logical Read Count], 
	[total_logical_writes]  / [execution_count] AS [Average Logical Write Count], 
	[total_elapsed_time] / 1000.0 AS [total_elapsed_time (ms)],
	[total_worker_time] / 1000.0  AS [total_worker_time (ms)],
	[total_physical_reads] AS [total_physical_reads (page)],
	[total_logical_reads] AS [total_logical_reads (page)],
	[total_logical_writes] AS [total_logical_writes (page)],
	[execution_count], 
	[plan_generation_num],
	[creation_time],
	[last_execution_time],
	DB_NAME(st.dbid) AS db_name,
	REPLACE(REPLACE(REPLACE(SUBSTRING(text, 
	([statement_start_offset] / 2) + 1, 
	((CASE [statement_end_offset]
	WHEN -1 THEN DATALENGTH(text)
	ELSE [statement_end_offset]
	END - [statement_start_offset]) / 2) + 1),CHAR(13), ' '), CHAR(10), ' '), CHAR(9), ' ') AS [stmt_text],
	REPLACE(REPLACE(REPLACE([text],CHAR(13), ''), CHAR(10), ' '), CHAR(9), ' ') AS [text]
	--,query_plan
FROM
	[sys].[dm_exec_query_stats]
	CROSS APPLY 
	[sys].[dm_exec_sql_text]([sql_handle]) AS st
	CROSS APPLY
	[sys].[dm_exec_query_plan]([plan_handle])
ORDER BY
	([total_physical_reads] / [execution_count]) + ([total_logical_reads] / [execution_count]) DESC
OPTION (RECOMPILE)

/*********************************************/
-- 平均書き込み回数の高いクエリ TOP 300
/*********************************************/
SELECT TOP 300
	GETDATE() AS DATE,
	'HighAvgWrite' AS type, 
	[total_elapsed_time] / [execution_count] / 1000.0 AS [Average Elapsed Time (ms)], 
	[total_worker_time]  / [execution_count] / 1000.0 AS [Average Worker Time (ms)], 
	[total_physical_reads] / [execution_count] AS [Average Physical Read Count], 
	[total_logical_reads] / [execution_count] AS [Average Logical Read Count], 
	[total_logical_writes]  / [execution_count] AS [Average Logical Write Count], 
	[total_elapsed_time] / 1000.0 AS [total_elapsed_time (ms)],
	[total_worker_time] / 1000.0  AS [total_worker_time (ms)],
	[total_physical_reads] AS [total_physical_reads (page)],
	[total_logical_reads] AS [total_logical_reads (page)],
	[total_logical_writes] AS [total_logical_writes (page)],
	[execution_count], 
	[plan_generation_num],
	[creation_time],
	[last_execution_time],
	DB_NAME(st.dbid) AS db_name,
	REPLACE(REPLACE(REPLACE(SUBSTRING(text, 
	([statement_start_offset] / 2) + 1, 
	((CASE [statement_end_offset]
	WHEN -1 THEN DATALENGTH(text)
	ELSE [statement_end_offset]
	END - [statement_start_offset]) / 2) + 1),CHAR(13), ' '), CHAR(10), ' '), CHAR(9), ' ') AS [stmt_text],
	REPLACE(REPLACE(REPLACE([text],CHAR(13), ''), CHAR(10), ' '), CHAR(9), ' ') AS [text]
	--,query_plan
FROM
	[sys].[dm_exec_query_stats]
	CROSS APPLY 
	[sys].[dm_exec_sql_text]([sql_handle]) AS st
	CROSS APPLY
	[sys].[dm_exec_query_plan]([plan_handle])
ORDER BY
	[Average Logical Write Count] DESC
OPTION (RECOMPILE)
