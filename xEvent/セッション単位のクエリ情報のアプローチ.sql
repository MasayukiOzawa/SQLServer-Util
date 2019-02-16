SET NOCOUNT ON
-- DBCC TRACEON(3656, -1) WITH NO_INFOMSGS
GO
IF OBJECT_ID('tempdb..#filename') IS NOT NULL
BEGIN
	DROP TABLE #filename
END

DECLARE @sessoin_id int = (SELECT @@SPID)
SELECT  N'query_analyze_' + CAST(@sessoin_id AS varchar(6)) + '_' + FORMAT(GETDATE(), 'yyyyMMddHHmmss') AS filename INTO #filename
DECLARE @file_name sysname =(SELECT filename FROM #filename)

/******************************************************************/
-- 前処理
/******************************************************************/

-- 拡張イベントの存在確認 (存在している場合は削除)
IF EXISTS (SELECT 1 FROM sys.server_event_sessions WHERE name = 'query_analyze')
BEGIN 
	DROP EVENT SESSION [query_analyze] ON SERVER 
END

-- 自セッションの ID でフィルターした拡張イベントを作成
DECLARE @sql nvarchar(max) = N'
CREATE EVENT SESSION [query_analyze] ON SERVER 

ADD EVENT sqlserver.lock_acquired(SET collect_database_name=(1),collect_resource_description=(1)
	ACTION(package0.callstack,sqlserver.session_id,sqlserver.query_hash,sqlserver.query_plan_hash,sql_text)
	WHERE ([sqlserver].[session_id]=(@@session_id))),

ADD EVENT sqlserver.lock_released(SET collect_database_name=(1),collect_resource_description=(1)
	ACTION(package0.callstack,sqlserver.session_id,sqlserver.query_hash,sqlserver.query_plan_hash,sql_text)
	WHERE ([sqlserver].[session_id]=(@@session_id))),

ADD EVENT sqlserver.rpc_completed(
    ACTION(package0.callstack,sqlserver.session_id,sqlserver.query_hash,sqlserver.query_plan_hash)
 	WHERE ([sqlserver].[session_id]=(@@session_id))),

ADD EVENT sqlserver.sp_statement_completed(SET collect_statement=(1)
    ACTION(package0.callstack,sqlserver.session_id,sqlserver.query_hash,sqlserver.query_plan_hash)
 	WHERE ([sqlserver].[session_id]=(@@session_id))),

ADD EVENT sqlos.wait_info(
	ACTION(package0.callstack,sqlserver.session_id,sqlserver.query_hash,sqlserver.query_plan_hash)  
	WHERE ([sqlserver].[session_id]=(@@session_id))),

ADD EVENT sqlserver.sql_statement_completed(
    ACTION(package0.callstack,sqlserver.session_id,sqlserver.query_hash,sqlserver.query_plan_hash)
	WHERE ([sqlserver].[session_id]=(@@session_id))),

ADD EVENT sqlserver.query_post_execution_showplan(
    ACTION(package0.callstack,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id)
	WHERE ([sqlserver].[session_id]=(@@session_id)))

-- ADD TARGET package0.ring_buffer(SET max_events_limit=(20000),max_memory=(0))
ADD TARGET package0.event_file(SET filename=N''@@file_name'',max_file_size=(1000))
'

SET @sql = REPLACE(@sql, '@@session_id', @sessoin_id)
SET @sql = REPLACE(@sql, '@@file_name', @file_name)

EXECUTE(@sql)

---- 実行統計の取得
--SET STATISTICS TIME ON
--SET STATISTICS IO ON

-- 各種累計値の実行前の状態を取得
IF OBJECT_ID('tempdb..#session_tempdb_before') IS NOT NULL
BEGIN
	DROP TABLE #session_tempdb_before
END

SELECT * INTO #session_tempdb_before FROM sys.dm_db_session_space_usage WHERE session_id = @sessoin_id

IF OBJECT_ID('tempdb..#session_before') IS NOT NULL
BEGIN
	DROP TABLE #session_before
END

SELECT * INTO #session_before FROM sys.dm_exec_sessions WHERE session_id = @sessoin_id

-- イベントセッションの開始
ALTER EVENT SESSION [query_analyze] ON SERVER STATE = START
/******************************************************************/
GO

DECLARE @start datetime2 
SET @start = (SELECT GETDATE())

/***********************************************************************/
-- 情報を確認するクエリを以下に記載して実行
use tpch;
SELECT * FROM REGION OPTION(RECOMPILE)
--DBCC FREEPROCCACHE WITH NO_INFOMSGS 
--DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS 

--SELECT TOP 100 S_ACCTBAL, S_NAME, N_NAME, P_PARTKEY, P_MFGR, S_ADDRESS, S_PHONE, S_COMMENT
--FROM PART, SUPPLIER, PARTSUPP, NATION, REGION
--WHERE P_PARTKEY = PS_PARTKEY AND S_SUPPKEY = PS_SUPPKEY AND P_SIZE = 15 AND
--P_TYPE LIKE '%%BRASS' AND S_NATIONKEY = N_NATIONKEY AND N_REGIONKEY = R_REGIONKEY AND
--R_NAME = 'EUROPE' AND
--PS_SUPPLYCOST = (SELECT MIN(PS_SUPPLYCOST) FROM PARTSUPP, SUPPLIER, NATION, REGION
-- WHERE P_PARTKEY = PS_PARTKEY AND S_SUPPKEY = PS_SUPPKEY
-- AND S_NATIONKEY = N_NATIONKEY AND N_REGIONKEY = R_REGIONKEY AND R_NAME = 'EUROPE')
--ORDER BY S_ACCTBAL DESC, N_NAME, S_NAME, P_PARTKEY
--OPTION(QUERYTRACEON 8675, QUERYTRACEON 3604);

----DBCC FREEPROCCACHE WITH NO_INFOMSGS 
--DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS 
--SELECT TOP 100 S_ACCTBAL, S_NAME, N_NAME, P_PARTKEY, P_MFGR, S_ADDRESS, S_PHONE, S_COMMENT
--FROM PART, SUPPLIER, PARTSUPP, NATION, REGION
--WHERE P_PARTKEY = PS_PARTKEY AND S_SUPPKEY = PS_SUPPKEY AND P_SIZE = 15 AND
--P_TYPE LIKE '%%BRASS' AND S_NATIONKEY = N_NATIONKEY AND N_REGIONKEY = R_REGIONKEY AND
--R_NAME = 'EUROPE' AND
--PS_SUPPLYCOST = (SELECT MIN(PS_SUPPLYCOST) FROM PARTSUPP, SUPPLIER, NATION, REGION
-- WHERE P_PARTKEY = PS_PARTKEY AND S_SUPPKEY = PS_SUPPKEY
-- AND S_NATIONKEY = N_NATIONKEY AND N_REGIONKEY = R_REGIONKEY AND R_NAME = 'EUROPE')
--ORDER BY S_ACCTBAL DESC, N_NAME, S_NAME, P_PARTKEY
--OPTION(QUERYTRACEON 8780,QUERYTRACEON 8757,  QUERYTRACEON 8675, QUERYTRACEON 3604);

/***********************************************************************/
PRINT 'Queyr End : Elapsed Time (ms) : ' + CAST(DATEDIFF(MILLISECOND, @start, GETDATE()) AS varchar(20))
GO


/******************************************************************/
-- 後処理
/******************************************************************/

--SET STATISTICS TIME OFF
--SET STATISTICS IO OFF

-- イベントセッションの停止
ALTER EVENT SESSION [query_analyze] ON SERVER STATE = STOP

/******************************************************************/
GO


/******************************************************************/
-- 取得情報の分析
-- 分析のための tempdb への情報出力等があるため、情報の正確性には留意する
/******************************************************************/
-- ファイル名の設定
DECLARE @sessoin_id int = (SELECT @@SPID)
DECLARE @file_name sysname =(SELECT filename FROM #filename)
DECLARE @start datetime2 

-- セッション情報を出力
SET @start = (SELECT GETDATE())

SELECT 
	'session_info' AS info_type,
	T1.last_request_start_time,
	T1.last_request_end_time,
	T1.login_time,
	T1.session_id,
	(T1.cpu_time - T2.cpu_time) / 1000.0 AS cpu_time_sec,
	(T1.total_scheduled_time - T2.total_scheduled_time) / 1000.0 AS total_scheduled_time_sec,
	(T1.total_elapsed_time - T2.total_elapsed_time) / 1000.0 AS total_elapsed_time_sec,
	(T1.memory_usage - T2.memory_usage) * 8.0 / 1024 AS memory_usage_mb,
	(T1.reads - T2.reads) * 8.0 / 1024.0 AS physical_reads_mb,
	(T1.logical_reads - T2.logical_reads) * 8.0 / 1024 AS logical_reads_mb,
	(T1.writes - T2.writes) * 8.0 / 1024.0 AS writes_mb
FROM 
	sys.dm_exec_sessions AS T1
	LEFT JOIN
	#session_before AS T2
	ON
	T1.session_id = T2.session_id
WHERE 
	T1.session_id = @@SPID

PRINT 'session_info : Elapsed Time (ms) : ' + CAST(DATEDIFF(MILLISECOND, @start, GETDATE()) AS varchar(20))


-- tempdb の使用状況を取得
SET @start = (SELECT GETDATE())

SELECT 
	'tempdb_info' AS info_type,
	(T1.user_objects_alloc_page_count - T2.user_objects_alloc_page_count) * 8.0 / 1024.0 AS user_objects_alloc_mb_count,
	(T1.user_objects_dealloc_page_count - T2.user_objects_dealloc_page_count) * 8.0 / 1024.0 AS user_objects_dealloc_mb_count,
	(T1.internal_objects_alloc_page_count - T2.internal_objects_alloc_page_count) * 8.0 / 1024.0 AS internal_objects_alloc_mb_count,
	(T1.internal_objects_dealloc_page_count - T2.internal_objects_dealloc_page_count) * 8.0 / 1024.0 AS internal_objects_dealloc_mb_count
FROM 
	sys.dm_db_session_space_usage AS T1
	LEFT JOIN
	#session_tempdb_before AS T2
	ON
	T1.session_id = T2.session_id
WHERE 
	T1.session_id = @@SPID

PRINT 'tempdb_info elapsed time (ms) : ' + CAST(DATEDIFF(MILLISECOND, @start, GETDATE()) AS varchar(20))

-- ######### 以下、拡張イベントの分析 #########
-- 取得した拡張イベントのログを一時テーブルに格納
SET @start = (SELECT GETDATE())

IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
BEGIN
	DROP TABLE #tmp
END

SELECT
	ROW_NUMBER() OVER(ORDER BY object_name ASC) AS No, 
	-- timestamp_utc,
	object_name,
	CAST(event_data AS xml) AS event_data
INTO #tmp
FROM 
	sys.fn_xe_file_target_read_file (@file_name + '*.xel', NULL, NULL, NULL);

PRINT 'xevent load : Elapsed Time (ms) : ' + CAST(DATEDIFF(MILLISECOND, @start, GETDATE()) AS varchar(20))

-- 後続の拡張イベントの XML の分析の最適化のため、XML インデックスを設定
SET @start = (SELECT GETDATE())

ALTER TABLE #tmp ALTER COLUMN object_name nvarchar(60) NOT NULL
ALTER TABLE #tmp ALTER COLUMN No int NOT NULL
ALTER TABLE #tmp ADD CONSTRAINT PK_xevent_trace_tmp_index  PRIMARY KEY CLUSTERED (object_name, No)
CREATE PRIMARY XML INDEX IX_xevent_trace_xml_index ON #tmp(event_data)

PRINT 'xevent create index : Elapsed Time (ms) : ' + CAST(DATEDIFF(MILLISECOND, @start, GETDATE()) AS varchar(20))

-- ステートメントの情報を確認
SET @start = (SELECT GETDATE())

SELECT
	'xevent_statement_info' AS info_type,
	T.statemet_text,
	T2.query_object_name,
	T2.query_object_type,
	T2.query_plan,
	T2.missing_index,
	T.duration_sec,
	T2.duration_sec AS plan_duration_sec,
	T.cpu_time_sec,
	T2.cpu_time_sec as plan_cpu_time_sec,
	T2.CompileTime,
	T2.CompileCPU,
	T2.StatementOptmEarlyAbortReason,
	T2.UsedThreads,
	T2.estimated_cost,
	T2.ideal_memory_kb,
	T2.granted_memory_kb,
	T2.used_memory_kb,
	T.logical_reads_mb,
	T.physical_reads_mb,
	T.writes_mb,
	T.spills_mb,
	T.row_count,
	T2.estimated_rows,
	T2.dop
FROM(
	SELECT
		*
	FROM(
		SELECT
			--timestamp_utc,
			object_name,
			event_data.value('(/event/@timestamp)[1]', 'datetime') AS query_timestamp,
			event_data.value('(/event/action[@name="query_hash"])[1]', 'varchar(30)') AS query_hash,
			event_data.value('(/event/action[@name="query_plan_hash"])[1]', 'varchar(30)') AS query_plan_hash,
			event_data.value('(/event/data[@name="statement"]/value)[1]', 'nvarchar(max)') AS statemet_text,
			event_data.value('(/event/data[@name="duration"]/value)[1]', 'int') / 1000000.0 AS duration_sec,
			event_data.value('(/event/data[@name="cpu_time"]/value)[1]', 'int') / 1000000.0 AS cpu_time_sec,
			event_data.value('(/event/data[@name="logical_reads"]/value)[1]', 'bigint')  * 8.0 / 1024.0 AS logical_reads_mb,
			event_data.value('(/event/data[@name="physical_reads"]/value)[1]', 'bigint') * 8.0 / 1024.0 AS physical_reads_mb,
			event_data.value('(/event/data[@name="writes"]/value)[1]', 'bigint') * 8.0 / 1024.0 AS writes_mb,
			event_data.value('(/event/data[@name="spills"]/value)[1]', 'bigint')  * 8.0 / 1024.0 AS spills_mb,
			event_data.value('(/event/data[@name="row_count"]/value)[1]', 'bigint') AS row_count
			-- ,event_Data
		FROM
			#tmp
		WHERE 
			object_name = 'sql_statement_completed'
			OR
			object_name = 'rpc_completed'
			OR
			object_name = 'sp_statement_completed'
	) AS T
	WHERE
		query_hash <> '0'
) AS T
LEFT JOIN (
	SELECT
		*
	FROM(
		SELECT
			'xevent_statement_info' AS info_type,
			--timestamp_utc,
			object_name,
			T.query_plan.query('.') AS query_plan,
			T.query_plan.query('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan"; 
			./descendant::MissingIndexes') AS  missing_index,
			T.query_plan.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan"; 
			(./descendant::StmtSimple/@StatementOptmEarlyAbortReason)[1]', 'sysname') AS StatementOptmEarlyAbortReason,
			T.query_plan.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan"; 
			(./descendant::StmtSimple/QueryPlan/@CachedPlanSize)[1]', 'int') AS CachedPlanSize,
			event_data.value('(/event/@timestamp)[1]', 'datetime') AS query_timestamp,
			T.query_plan.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan"; 
			(./descendant::StmtSimple/QueryPlan/@CompileTime)[1]', 'int') AS CompileTime,
			T.query_plan.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan"; 
			(./descendant::StmtSimple/QueryPlan/@CompileCPU)[1]', 'int') AS CompileCPU,
			T.query_plan.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan"; 
			(./descendant::StmtSimple/QueryPlan/@CompileMemory)[1]', 'int') AS CompileMemory,
			T.query_plan.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan"; 
			(./descendant::StmtSimple/QueryPlan/ThreadStat/@UsedThreads)[1]', 'int') AS UsedThreads,
			event_data.value('(/event/action[@name="query_hash"])[1]', 'varchar(30)') AS query_hash,
			event_data.value('(/event/action[@name="query_plan_hash"])[1]', 'varchar(30)') AS query_plan_hash,
			event_data.value('(/event/data[@name="dop"]/value)[1]', 'int') AS dop,
			event_data.value('(/event/data[@name="cpu_time"]/value)[1]', 'int')/ 1000000.0 AS cpu_time_sec,
			event_data.value('(/event/data[@name="estimated_rows"]/value)[1]', 'int') AS estimated_rows,
			event_data.value('(/event/data[@name="estimated_cost"]/value)[1]', 'int') AS estimated_cost,
			event_data.value('(/event/data[@name="serial_ideal_memory_kb"]/value)[1]', 'int') AS serial_ideal_memory_kb,
			event_data.value('(/event/data[@name="requested_memory_kb"]/value)[1]', 'int') AS requested_memory_kb,
			event_data.value('(/event/data[@name="used_memory_kb"]/value)[1]', 'int') AS used_memory_kb,
			event_data.value('(/event/data[@name="ideal_memory_kb"]/value)[1]', 'int') AS ideal_memory_kb,
			event_data.value('(/event/data[@name="granted_memory_kb"]/value)[1]', 'int') AS granted_memory_kb,
			event_data.value('(/event/data[@name="duration"]/value)[1]', 'int') / 1000000.0 AS duration_sec,
			event_data.value('(/event/data[@name="object_name"]/value)[1]', 'sysname') AS query_object_name,
			event_data.value('(/event/data[@name="object_type"]/text)[1]', 'sysname') AS query_object_type,
			event_Data
		FROM
			#tmp
			OUTER APPLY #tmp.event_data.nodes('/event/data[@name="showplan_xml"]/value/*') as T(query_plan)
		WHERE 
			object_name = 'query_post_execution_showplan'
	) AS T
	WHERE
		query_hash <> '0'
) AS T2
ON
	T2.query_hash = T.query_hash
	AND
	T2.query_plan_hash =T.query_plan_hash
ORDER BY T.query_timestamp ASC

PRINT 'xevent_statement_info : Elapsed Time (ms) : ' + CAST(DATEDIFF(MILLISECOND, @start, GETDATE()) AS varchar(20))

-- 待ち事象の情報を確認
SET @start = (SELECT GETDATE())

SELECT
	'xevent_wait_info' AS info_type,
	T.query_hash,
	T.query_plan_hash,
	Q.statemet_text,
	T.wait_type,
	COUNT(*) AS wait_count,
	(SUM(T.duration_ms)) / 1000.0 AS total_duration_sec
FROM
(
	SELECT
		No,
		--timestamp_utc,
		object_name,
		event_data.value('(/event/action[@name="query_hash"])[1]', 'varchar(30)') AS query_hash,
		event_data.value('(/event/action[@name="query_plan_hash"])[1]', 'varchar(30)') AS query_plan_hash,
		event_data.value('(/event/data[@name="wait_type"]/text)[1]', 'sysname') AS wait_type,
		event_data.value('(/event/data[@name="duration"]/value)[1]', 'int') AS duration_ms
	FROM
		#tmp
	WHERE 
		object_name = 'wait_info'
) AS T
LEFT JOIN
(
	SELECT
		*
	FROM(
		SELECT
			event_data.value('(/event/action[@name="query_hash"])[1]', 'varchar(30)') AS query_hash,
			event_data.value('(/event/action[@name="query_plan_hash"])[1]', 'varchar(30)') AS query_plan_hash,
			event_data.value('(/event/data[@name="statement"]/value)[1]', 'nvarchar(max)') AS statemet_text
		FROM
			#tmp
		WHERE 
			object_name = 'sql_statement_completed'
			OR
			object_name = 'rpc_completed'
			OR
			object_name = 'sp_statement_completed'
	) AS T2
) AS Q

ON
	T.query_hash = Q.query_hash
	AND
	T.query_plan_hash = Q.query_plan_hash
WHERE
	T.query_hash <> '0'
GROUP BY
	Q.statemet_text,
	T.wait_type,
	T.query_hash,
	T.query_plan_hash
ORDER BY
	Q.statemet_text, 
	SUM(T.duration_ms) DESC

PRINT 'xevent_wait_info : Elapsed Time (ms) : ' + CAST(DATEDIFF(MILLISECOND, @start, GETDATE()) AS varchar(20))

-- 取得した拡張イベントからロックの情報を取得
SET @start = (SELECT GETDATE())

SELECT
	'xevent_lock_info' AS info_type,
	xevent_object_name,
	event_timestamp,
	database_name,
	resource_type,
	mode,
	CASE
	WHEN database_name = DB_NAME(DB_ID()) THEN
		CASE  
			WHEN resource_type = 'OBJECT' THEN 
				OBJECT_NAME(object_id)
			WHEN resource_type = 'METADATA' THEN
				OBJECT_NAME(resource_description_object_id)
			ELSE object_id
		END
	WHEN database_name = 'master' AND resource_type = 'OBJECT' THEN
		OBJECT_NAME(object_id)
	ELSE
		object_id
	END AS object_name,
	CASE
		WHEN resource_description_stats_id IS NOT NULL THEN
			(SELECT name FROM sys.stats AS s WHERE s.object_id = resource_description_object_id AND s.stats_id = resource_description_stats_id)
		WHEN resource_description_index_or_stats_id IS NOT NULL THEN
			(SELECT name FROM sys.stats AS s WHERE s.object_id = resource_description_object_id AND s.stats_id = resource_description_index_or_stats_id)
		ELSE
			NULL
	END AS index_or_stats_name,
	resource_description,
	duration,
	sql_text
	--,SUM(duration) / 1000 AS total_duration_ms
	--,COUNT(*) AS count
FROM
(
SELECT
	No,
	--timestamp_utc,
	object_name AS xevent_object_name,
	event_data.value('(/event/@timestamp)[1]', 'varchar(24)') as event_timestamp,
	event_data.value('(/event/data[@name="resource_type"]/text)[1]', 'sysname') AS resource_type,
	event_data.value('(/event/data[@name="database_name"]/value)[1]', 'sysname') AS database_name,
	event_data.value('(/event/data[@name="mode"]/text)[1]', 'sysname') AS mode,
	event_data.value('(/event/data[@name="object_id"]/value)[1]', 'sysname') AS object_id,
	event_data.value('(/event/data[@name="duration"]/value)[1]', 'int') AS duration,
	event_data.value('(/event/data[@name="resource_0"]/value)[1]', 'sysname') AS resource_0,
	event_data.value('(/event/data[@name="resource_1"]/value)[1]', 'sysname') AS resource_1,
	event_data.value('(/event/data[@name="resource_2"]/value)[1]', 'sysname') AS resource_2,
	event_data.value('(/event/data[@name="resource_description"]/value)[1]', 'sysname') AS resource_description,
	CASE 
		WHEN 
			CHARINDEX('object_id = ', event_data.value('(/event/data[@name="resource_description"]/value)[1]', 'sysname')) > 0
		THEN
		SUBSTRING(
			event_data.value('(/event/data[@name="resource_description"]/value)[1]', 'sysname'), 
			CHARINDEX('=', event_data.value('(/event/data[@name="resource_description"]/value)[1]', 'sysname')) + 2,
			CHARINDEX(',', event_data.value('(/event/data[@name="resource_description"]/value)[1]', 'sysname')) 
			- 
			(CHARINDEX('=', event_data.value('(/event/data[@name="resource_description"]/value)[1]', 'sysname')) + 2)
		)
	ELSE
			event_data.value('(/event/data[@name="object_id"]/value)[1]', 'sysname')
	END AS resource_description_object_id,
	CASE 
		WHEN 
		CHARINDEX(', stats_id = ', event_data.value('(/event/data[@name="resource_description"]/value)[1]', 'sysname')) > 0
		THEN
		SUBSTRING(
			event_data.value('(/event/data[@name="resource_description"]/value)[1]', 'sysname'), 
			CHARINDEX(', stats_id = ', event_data.value('(/event/data[@name="resource_description"]/value)[1]', 'sysname')) + LEN(', stats_id = ') + 1, 
			LEN(event_data.value('(/event/data[@name="resource_description"]/value)[1]', 'sysname')) 
			- 
			CHARINDEX(', stats_id = ', event_data.value('(/event/data[@name="resource_description"]/value)[1]', 'sysname')) + LEN(', stats_id = ') + 1
		)
	ELSE
		NULL
	END AS resource_description_stats_id,
	CASE 
		WHEN 
		CHARINDEX(', index_id or stats_id = ', event_data.value('(/event/data[@name="resource_description"]/value)[1]', 'sysname')) > 0
		THEN
		SUBSTRING(
			event_data.value('(/event/data[@name="resource_description"]/value)[1]', 'sysname'), 
			CHARINDEX(', index_id or stats_id = ', event_data.value('(/event/data[@name="resource_description"]/value)[1]', 'sysname')) + LEN(', index_id or stats_id = ') + 1, 
			LEN(event_data.value('(/event/data[@name="resource_description"]/value)[1]', 'sysname')) 
			- 
			CHARINDEX(', index_id or stats_id = ', event_data.value('(/event/data[@name="resource_description"]/value)[1]', 'sysname')) + LEN(', index_id or stats_id = ') + 1
		)
	ELSE
		NULL
	END AS resource_description_index_or_stats_id,
	event_data.value('(/event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS sql_text,
	event_data
FROM
	#tmp
WHERE 
	object_name IN('lock_acquired', 'lock_released')
	--AND event_data.value('(/event/data[@name="resource_type"]/text)[1]', 'sysname') = 'METADATA'
) AS T
--GROUP BY
--	resource_type,
--	database_name,
--	mode,
--	object_id,
--	resource_description_object_id,
--	resource_description_stats_id,
--	resource_description_index_or_stats_id
ORDER BY
	event_timestamp
	--database_name,
	--resource_type,
	--mode,
	--index_or_stats_name

PRINT 'xevent_lock_info : Elapsed Time (ms) : ' + CAST(DATEDIFF(MILLISECOND, @start, GETDATE()) AS varchar(20))

---- 使用した拡張イベントの削除
--IF EXISTS (SELECT 1 FROM sys.server_event_sessions WHERE name = 'query_analyze')
--BEGIN 
--	DROP EVENT SESSION [query_analyze] ON SERVER 
--END
/******************************************************************/