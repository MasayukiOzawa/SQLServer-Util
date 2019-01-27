CREATE EVENT SESSION [ConnectionPoolTest] ON DATABASE 
ADD EVENT sqlserver.login(ACTION(sqlserver.client_app_name,sqlserver.session_id)),
ADD EVENT sqlserver.logout(ACTION(sqlserver.client_app_name,sqlserver.session_id))
ADD TARGET package0.ring_buffer
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

ALTER EVENT SESSION [ConnectionPoolTest] ON DATABASE STATE = START
GO

/*
ALTER EVENT SESSION [ConnectionPoolTest] ON DATABASE STATE = STOP
GO
*/


DROP TABLE IF EXISTS #xEvent
GO

SELECT
	1 AS No, 
	CAST([target_data] AS XML) AS target_data
INTO #xEvent
FROM    
	sys.dm_xe_database_session_targets AS xt
	INNER JOIN 
	sys.dm_xe_database_sessions AS xs
	ON 
		xs.address = xt.event_session_address
WHERE    
	xs.name = N'ConnectionPoolTest' AND xt.target_name = N'ring_buffer'


ALTER TABLE #xEvent
ADD CONSTRAINT PK_xEvent_Login PRIMARY KEY (No)
GO
CREATE PRIMARY XML INDEX XIX_xEvent_Login ON #xEvent(target_data)
GO


SELECT
	event_name,
	client_app_name,
	is_cached,
	COUNT(*) AS connection_count
FROM
(
SELECT
	xe_xml.value('(@timestamp)[1]', 'datetime') AS event_timestamp,
	xe_xml.value('(@name)[1]', 'sysname') AS event_name,
	xe_xml.value('(action[@name="session_id"]/value)[1]', 'int') AS session_id,
	xe_xml.value('(action[@name="client_app_name"]/value)[1]', 'sysname') AS client_app_name,
	xe_xml.value('(data[@name="is_cached"]/value)[1]', 'sysname') AS is_cached
FROM
	#xEvent AS T
CROSS APPLY 
	T.target_data.nodes('//event') AS T2(xe_xml)
) AS T3
GROUP BY
	event_name,
	client_app_name,
	is_cached
ORDER BY
	client_app_name, is_cached
GO

