SET NOCOUNT ON
GO

DECLARE @sessoin_id int = (SELECT @@SPID)
DECLARE @file_name sysname =(SELECT  N'session_research_' + CAST(@sessoin_id AS varchar(6)) + '_' + FORMAT(GETDATE(), 'yyyyMMddHHmmss'))

-- セッション単位の待ち事象は累計値となるため、実行前の状態を取得
-- 連続実行を想定した考慮だが、取得情報の解析の待ちが計上されているため、あまり効果がないかも…
DROP TABLE IF EXISTS  #session_wait_before
SELECT * INTO #session_wait_before FROM sys.dm_exec_session_wait_stats WHERE session_id = @sessoin_id

-- 拡張イベントの存在確認 (存在している場合は削除)
IF EXISTS (SELECT 1 FROM sys.server_event_sessions WHERE name = 'session_research')
BEGIN 
	DROP EVENT SESSION [session_research] ON SERVER 
END

-- 自セッションの ID でフィルターした拡張イベントを作成
DECLARE @sql nvarchar(max) = N'
CREATE EVENT SESSION [session_research] ON SERVER 

ADD EVENT sqlserver.lock_acquired(SET collect_database_name=(1),collect_resource_description=(1)
ACTION(package0.callstack,sqlserver.session_id)
WHERE ([sqlserver].[session_id]=(@@session_id))),

ADD EVENT sqlos.wait_completed(
ACTION(package0.callstack,sqlserver.session_id)  
WHERE ([sqlserver].[session_id]=(@@session_id)))

-- ADD TARGET package0.ring_buffer(SET max_events_limit=(20000),max_memory=(0))
ADD TARGET package0.event_file(SET filename=N''@@file_name'',max_file_size=(200))
'

SET @sql = REPLACE(@sql, '@@session_id', @sessoin_id)
SET @sql = REPLACE(@sql, '@@file_name', @file_name)

EXECUTE(@sql)

-- イベントセッションの開始
ALTER EVENT SESSION [session_research] ON SERVER STATE = START

-- 実行統計の取得
SET STATISTICS TIME ON
SET STATISTICS IO ON


/***********************************************************************/
-- 情報を確認するクエリを以下に記載して実行
USE tpch;
SELECT COUNT(*) FROM REGION
/***********************************************************************/

SET STATISTICS TIME OFF
SET STATISTICS IO OFF

-- イベントセッションの停止
ALTER EVENT SESSION [session_research] ON SERVER STATE = STOP

-- セッションの情報を取得
SELECT 
	session_id,
	login_time,
	host_name,
	program_name,
	client_version,
	client_interface_name,
	login_name,
	status,
	cpu_time,
	memory_usage,
	total_scheduled_time,
	total_elapsed_time,
	last_request_start_time,
	last_request_end_time,
	reads,
	writes,
	logical_reads
FROM 
	sys.dm_exec_sessions 
WHERE 
	session_id = @@SPID

-- セッションの待ち事象の情報を取得
SELECT 
	T1.session_id,
	T1.wait_type,
	T1.waiting_tasks_count - COALESCE(T2.waiting_tasks_count, 0) AS waiting_tasks_count,
	T1.wait_time_ms - COALESCE(T2.wait_time_ms, 0) AS wait_time_ms,
	T1.max_wait_time_ms,
	T1.signal_wait_time_ms - COALESCE(T2.signal_wait_time_ms, 0) AS signal_wait_time_ms
FROM 
	sys.dm_exec_session_wait_stats AS T1
	LEFT JOIN
	#session_wait_before AS T2
	ON
	T1.session_id = T2.session_id
	AND 
	T1.wait_type = T2.wait_type
WHERE 
	T1.session_id = @@SPID 
	AND
	(
		T1.waiting_tasks_count - T2.waiting_tasks_count > 0
		OR
		T1.signal_wait_time_ms - T2.signal_wait_time_ms > 0
	)
ORDER BY 
	T1.wait_time_ms DESC

-- tempdb の使用状況を取得
SELECT 
	* 
FROM 
	sys.dm_db_session_space_usage 
WHERE 
	session_id = @@SPID

-- 取得した拡張イベントのログを一時テーブルに格納
DROP TABLE IF EXISTS #tmp

SELECT
	ROW_NUMBER() OVER(ORDER BY object_name ASC) AS No, 
	timestamp_utc,
	object_name,
	CAST(event_data AS xml) AS event_data
INTO #tmp
FROM 
	sys.fn_xe_file_target_read_file (@file_name + '*.xel', NULL, NULL, NULL) 

ALTER TABLE #tmp ALTER COLUMN No int NOT NULL
ALTER TABLE #tmp ADD CONSTRAINT PK_xevent_trace_tmp_index  PRIMARY KEY CLUSTERED (object_name, No)
CREATE PRIMARY XML INDEX IX_xevent_trace_xml_index ON #tmp(event_data)

-- 待ち事象の情報を確認
SELECT
	wait_type,
	COUNT(*) AS wait_count,
	SUM(duration_ms) AS total_duration_ms
FROM
(
SELECT
	No,
	timestamp_utc,
	object_name,
	event_data.value('(/event/data[@name="wait_type"]/text)[1]', 'sysname') AS wait_type,
	event_data.value('(/event/data[@name="duration"]/value)[1]', 'int') AS duration_ms

FROM
	#tmp
WHERE 
	object_name = 'wait_completed'
) AS T
GROUP BY
	wait_type
ORDER BY
	SUM(duration_ms) DESC


-- 取得した拡張イベントからロックの情報を取得
SELECT
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
	COUNT(*) AS count
FROM
(
SELECT
	No,
	--timestamp_utc,
	object_name AS xevent_object_name,
	event_data.value('(/event/data[@name="resource_type"]/text)[1]', 'sysname') AS resource_type,
	event_data.value('(/event/data[@name="database_name"]/value)[1]', 'sysname') AS database_name,
	event_data.value('(/event/data[@name="mode"]/text)[1]', 'sysname') AS mode,
	event_data.value('(/event/data[@name="object_id"]/value)[1]', 'sysname') AS object_id,
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
	END AS resource_description_index_or_stats_id
	,event_data
FROM
	#tmp
WHERE 
	object_name = 'lock_acquired'
	--AND event_data.value('(/event/data[@name="resource_type"]/text)[1]', 'sysname') = 'METADATA'
) AS T
GROUP BY
	resource_type,
	database_name,
	mode,
	object_id,
	resource_description_object_id,
	resource_description_stats_id,
	resource_description_index_or_stats_id
ORDER BY
	database_name,
	resource_type,
	mode,
	index_or_stats_name
