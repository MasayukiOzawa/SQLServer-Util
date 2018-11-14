/*
CREATE EVENT SESSION [LiveTrace] ON DATABASE 
ADD EVENT sqlserver.rpc_starting(SET collect_statement=(1)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.sql_batch_starting(SET collect_batch_text=(1)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username))
ADD TARGET package0.ring_buffer(SET max_memory=(102400))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_MULTIPLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO


ALTER EVENT SESSION [LiveTrace] ON DATABASE STATE=START 
ALTER EVENT SESSION [LiveTrace] ON DATABASE STATE=STOP
*/

DROP TABLE IF EXISTS #tmp
GO
SELECT 
	'1' AS No,
	CAST(xt.target_data AS XML) AS target_data
INTO #tmp
FROM 
	sys.dm_xe_database_sessions AS xs
	LEFT JOIN
	sys.dm_xe_database_session_targets AS xt
	ON
	xs.address = xt.event_session_address
WHERE
	xs.name = 'LiveTrace'


ALTER TABLE #tmp ALTER COLUMN  No int NOT NULL
ALTER TABLE #tmp ADD CONSTRAINT PK_Tmp PRIMARY KEY CLUSTERED(No)
CREATE PRIMARY XML INDEX PIdx_Tmp_target_Data ON #tmp(target_data)  

SELECT
	TimeStamp,
	name,
	[session_id],
	[client_hostname], 
	[client_app_name],
	[sql_text]
FROM
(
	SELECT
		T2.val.value('parent::*/@timestamp', 'datetime2(3)') AS TimeStamp,
		T2.val.value('parent::*/@name', 'varchar(255)') AS name,
		T2.val.value('@name', 'varchar(255)') AS action_name,
		T2.val.value('(./value)[1]', 'varchar(max)') AS text
		-- ,T2.val.query('.') AS xml

	FROM
		#tmp
		CROSS APPLY target_data.nodes('/RingBufferTarget/event/action') AS T2 (val)
) AS LiveTrace
PIVOT(
	MAX(text)
	FOR action_name IN([session_id], [sql_text], [client_hostname], [client_app_name])
) AS PV
WHERE
	session_id <> @@SPID
ORDER BY
	TimeStamp DESC