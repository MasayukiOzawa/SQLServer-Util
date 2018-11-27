DROP TABLE IF EXISTS #xmldata
CREATE TABLE #xmldata (C1 int PRIMARY KEY, targetdata XML)
INSERT INTO #xmldata
SELECT 
	1,
	CAST(t.target_data AS XML) as targetdata
FROM 
	sys.dm_xe_database_sessions s
	INNER JOIN
	sys.dm_xe_database_session_targets  t
	ON
	s.address = t.event_session_address
WHERE 
	name = 'QueryTrace'
CREATE PRIMARY XML INDEX idx_xml on #xmldata (targetdata)

SELECT 
	DATEADD(hh, 9, xed.event_data.value('(@timestamp)[1]', 'datetime')) AS timestamp,
	xed.event_data.value('(action[@name=''session_id''])[1]', 'int') AS session_id,
	xed.event_data.value('(action[@name=''client_app_name''])[1]', 'nvarchar(max)') AS client_app_name,
	xed.event_data.value('(action[@name=''client_hostname''])[1]', 'nvarchar(max)') AS client_hostname,
	xed.event_data.value('(@name)[1]', 'varchar(100)') AS event_name,
	xed.event_data.value('(data[@name=''duration''])[1]', 'bigint') / 1000 AS duration_ms,
	xed.event_data.value('(data[@name=''cpu_time''])[1]', 'bigint') / 1000 AS cpu_time_ms,
	xed.event_data.value('(data[@name=''physical_reads''])[1]', 'bigint') / 1000 AS physical_reads,
	xed.event_data.value('(data[@name=''logical_reads''])[1]', 'bigint') / 1000 AS logical_reads,
	xed.event_data.value('(data[@name=''writes''])[1]', 'bigint') / 1000 AS writes,
	xed.event_data.value('(action[@name=''sql_text''])[1]', 'nvarchar(max)') AS sql_text,
	xed.event_data.value('(data[@name=''statement''])[1]', 'nvarchar(max)') AS statement
FROM 
	#xmldata
	CROSS APPLY 
	targetdata.nodes('//RingBufferTarget/event') AS xed (event_data)
WHERE
	xed.event_data.value('(action[@name=''session_id''])[1]', 'int') <> @@SPID
ORDER BY 
	[timestamp] DESC