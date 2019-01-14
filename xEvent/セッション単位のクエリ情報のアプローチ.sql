DECLARE @sessoin_id int = (SELECT @@SPID)
DECLARE @file_name sysname =(SELECT  N'session_research' + FORMAT(GETDATE(), 'yyyyMMddHHmmss'))


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
-- ロックを確認するクエリの実行
USE tpch;
BEGIN TRAN
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
SELECT * FROM REGION WITH(XLOCK, HOLDLOCK) WHERE R_REGIONKEY = 2
ROLLBACK TRAN
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
	* 
FROM 
	sys.dm_exec_session_wait_stats 
WHERE 
	session_id = @@SPID 
ORDER BY 
	wait_time_ms DESC

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
	ROW_NUMBER() OVER(ORDER BY timestamp_utc ASC) AS No, 
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



-- ロックの情報を取得
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
				OBJECT_NAME(res_object)
			ELSE object_id
		END
	WHEN database_name = 'master' AND resource_type = 'OBJECT' THEN
		OBJECT_NAME(object_id)
	ELSE
		object_id
	END AS object_name,
	--MAX(resource_description) AS resouce_description_sample,
	COUNT(*) AS count
FROM
(
SELECT
	No,
	timestamp_utc,
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
			CHARINDEX('object_id', event_data.value('(/event/data[@name="resource_description"]/value)[1]', 'sysname')) > 0
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
	END AS res_object
	-- ,event_data
FROM
	#tmp
WHERE 
	object_name = 'lock_acquired'
--ORDER BY 
--	No
--	-- AND event_data.value('(/event/data[@name="resource_type"]/text)[1]', 'sysname') = 'METADATA'
) AS T
GROUP BY
	resource_type,
	database_name,
	mode,
	object_id,
	res_object
ORDER BY
	database_name,
	resource_type,
	mode
