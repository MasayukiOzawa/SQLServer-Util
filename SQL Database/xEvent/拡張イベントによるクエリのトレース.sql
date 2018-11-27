-- クエリのトレース
CREATE EVENT SESSION [QueryTrace] ON DATABASE 
ADD EVENT sqlserver.rpc_completed(SET collect_statement=(1)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_hash_signed,sqlserver.query_plan_hash,sqlserver.query_plan_hash_signed,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([statement]<>N'exec sp_reset_connection')),
ADD EVENT sqlserver.sp_statement_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_hash_signed,sqlserver.query_plan_hash,sqlserver.query_plan_hash_signed,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_hash_signed,sqlserver.query_plan_hash,sqlserver.query_plan_hash_signed,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.query_hash_signed,sqlserver.query_plan_hash,sqlserver.query_plan_hash_signed,sqlserver.session_id,sqlserver.sql_text,sqlserver.username))
ADD TARGET package0.ring_buffer
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_MULTIPLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO

ALTER EVENT SESSION [QueryTrace] ON DATABASE STATE = START
GO

-- クエリのトレース用情報から情報を取得
/*
SELECT * FROM  sys.all_objects where name like '%xe[_]%' order by name desc

SELECT * FROM sys.dm_xe_database_sessions
SELECT * FROM sys.dm_xe_database_session_targets
*/

DROP TABLE IF EXISTS #xmldata
GO
CREATE TABLE #xmldata (C1 int IDENTITY PRIMARY KEY, xml_data XML)

INSERT INTO #xmldata (xml_data)
SELECT CAST(target_data AS XML) AS xml_data 
FROM sys.dm_xe_database_session_targets 
WHERE event_session_address = 
(SELECT address FROM sys.dm_xe_database_sessions WHERE name = 'QueryTrace')

CREATE PRIMARY XML INDEX idx_xml on #xmldata (xml_data)
  
SELECT
	xed.event_data.value('(@timestamp)[1]','datetime2') AS timestamp,  
   xed.event_data.value('(@name)[1]','varchar(255)') AS event_name,
   xed.event_data.value('(action[@name="sql_text"]/value)[1]','varchar(max)') AS sql_text,
   xed.event_data.value('(data[@name="statement"]/value)[1]','varchar(max)') AS statement,
   xed.event_data.value('(action[@name="username"]/value)[1]','varchar(max)') AS username,
   xed.event_data.value('(action[@name="client_hostname"]/value)[1]','varchar(max)') AS client_hostname,
   xed.event_data.value('(action[@name="client_app_name"]/value)[1]','varchar(max)') AS client_app_name
FROM
	#xmldata
CROSS APPLY xml_data.nodes('//RingBufferTarget/event') AS xed (event_data)


-- クエリの進行状況取得用のトレース
CREATE EVENT SESSION [QueryPlanTrace] ON DATABASE 
ADD EVENT sqlserver.query_post_execution_showplan
ADD TARGET package0.ring_buffer
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_MULTIPLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

ALTER EVENT SESSION [QueryPlanTrace] ON DATABASE STATE = START
GO

