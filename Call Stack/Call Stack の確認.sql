SET NOCOUNT ON
GO

DBCC TRACEON(3656, -1)  
GO
DROP TABLE IF EXISTS #tmp
GO

DECLARE @target_name sysname = N'Connection'

SELECT 
	1 AS C1,
	CAST(target_data as xml) AS target_data
INTO 
	#tmp
FROM 
	sys.dm_xe_sessions AS s 
INNER JOIN 
	sys.dm_xe_session_targets AS t
    ON s.address = t.event_session_address
WHERE 
	s.name = @target_name
    AND t.target_name = 'ring_buffer'

ALTER TABLE #tmp ADD CONSTRAINT PK_callstack_tmp_index  PRIMARY KEY CLUSTERED (C1)
CREATE PRIMARY XML INDEX IX_callstack_tmp_xml_index ON #tmp(target_data)

SELECT 
	t.event.value('(./@timestamp)[1]', 'varchar(100)') AS timestamp,
	t.event.value('(./@name)[1]', 'varchar(100)') AS event_name,
	t.event.value('(child::action[@name="session_id"]/value)[1]', 'int') AS session_id,
	t.event.value('(child::data[@name="is_cached"]/value)[1]', 'bit') AS is_cached,
	t.event.value('(child::action[@name="client_app_name"]/value)[1]', 'varchar(100)') AS session_id,
	t.event.value('(child::action[@name="sql_text"])[1]', 'varchar(100)') AS sql_text,
	t.event.value('(child::data[@name="duration"]/value)[1]', 'int') AS duration,
	t.event.query('child::action[@name="callstack"]/value') AS callstack
FROM
	#tmp
	CROSS APPLY target_data.nodes('RingBufferTarget/event') AS t(event)
ORDER BY
	timestamp ASC