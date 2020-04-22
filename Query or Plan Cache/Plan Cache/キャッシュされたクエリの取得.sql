 /***************************************************
 SQL Server 2012 SP3 / 2014 SP2 / 2016 以降
 ***************************************************/

/*************************************************************/
-- ファイルに保存する場合は、SSMS のツール→オプションから
-- クエリ結果→ SQL Server → 結果をテキストで表示を
-- タブ区切り / 各列に表示される最大文字数を 8000 で取得する
/*************************************************************/

USE master
GO

SET NOCOUNT ON
GO

DECLARE @last_execution_time datetime = (SELECT DATEADD(HOUR, -8, GETDATE()))
/*********************************************/
-- mode
-- 1 : 実行回数の高いクエリ
-- 2 : 平均 CPU 使用率の高いクエリ
-- 3 : 実行時間の高いクエリ
-- 4 : 平均読み取り回数の高いクエリ
-- 5 : 平均書き込み回数の高いクエリ
/*********************************************/

DECLARE @mode int = 2
SELECT TOP 300
	GETDATE() AS DATE,
	CASE @mode 
		WHEN 1 THEN 'HighExecution' 
		WHEN 2 THEN 'HighAvgCPU'
		WHEN 3 THEN 'HighAvgElapsedTime'
		WHEN 4 THEN 'HighAvgRead'
		WHEN 5 THEN 'HighAvgWrite'
		ELSE 'HighExecution' 
	END AS type, 
	DB_NAME(st.dbid) AS db_name,
	OBJECT_NAME(st.objectid,st.dbid) AS object_name,
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
	[total_rows],
	[last_rows],
	[min_rows],
	[max_rows],
	[plan_generation_num],
	[creation_time],
	[last_execution_time],
	[query_hash],
	[query_plan_hash],
	REPLACE(REPLACE(REPLACE(SUBSTRING(text, 
	([statement_start_offset] / 2) + 1, 
	((CASE [statement_end_offset]
	WHEN -1 THEN DATALENGTH(text)
	ELSE [statement_end_offset]
	END - [statement_start_offset]) / 2) + 1),CHAR(13), ' '), CHAR(10), ' '), CHAR(9), ' ') AS [stmt_text],
	REPLACE(REPLACE(REPLACE([text],CHAR(13), ''), CHAR(10), ' '), CHAR(9), ' ') AS [text]
	, qp.query_plan
	--, plan_handle
	--, sql_handle
FROM
	[sys].[dm_exec_query_stats]
	CROSS APPLY 
	[sys].[dm_exec_sql_text]([sql_handle]) AS st
	CROSS APPLY
	[sys].[dm_exec_query_plan]([plan_handle]) AS qp
	CROSS APPLY
	[sys].[dm_exec_text_query_plan]([plan_handle], [statement_start_offset], [statement_end_offset]) AS tqp
WHERE
	last_execution_time >= @last_execution_time
	AND
	query_hash <> 0x0000000000000000
ORDER BY
	CASE @mode
		WHEN 1 THEN [execution_count]
		WHEN 2 THEN [total_worker_time]  / [execution_count] / 1000.0
		WHEN 3 THEN [total_elapsed_time] / [execution_count] / 1000.0
		WHEN 4 THEN ([total_physical_reads] / [execution_count]) + ([total_logical_reads] / [execution_count]) 
		WHEN 5 THEN [total_logical_writes]  / [execution_count]
		ELSE [execution_count]
	END DESC
OPTION (RECOMPILE, MAXDOP 1)