-- event_file から取得
DECLARE @file nvarchar(max) = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\system_health*.xel'
DECLARE @metafile nvarchar(max) = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\system_health*.xem'

SELECT
	DATEADD(hour,9 , xmldata.value('(/event/@timestamp)[1]', 'datetime')) AS timestamp,
	object_name,
	xmldata.value('(/event/data/value/deadlock/process-list//inputbuf)[1]', 'nvarchar(max)') AS blocking_process_1,
	xmldata.value('(/event/data/value/deadlock/process-list//inputbuf)[2]', 'nvarchar(max)') AS blocking_process_2,
	xmldata
FROM(
	SELECT
		object_name,
		CAST(event_data AS XML) AS xmldata
	FROM
		sys.fn_xe_file_target_read_file(@file, @metafile, NULL, NULL)
	WHERE
		object_name IN('xml_deadlock_report')
) AS x
ORDER BY timestamp ASC
GO


-- ring_buffer から取得
SELECT    xed.value('@timestamp', 'datetime') as Creation_Date,
         xed.query('.') AS Extend_Event
FROM    (    SELECT    CAST([target_data] AS XML) AS Target_Data
             FROM    sys.dm_xe_session_targets AS xt
                     INNER JOIN sys.dm_xe_sessions AS xs
                     ON xs.address = xt.event_session_address
             WHERE    xs.name = N'system_health'
                     AND xt.target_name = N'ring_buffer')
AS XML_Data
CROSS APPLY Target_Data.nodes('RingBufferTarget/event[@name="xml_deadlock_report"]') AS XEventData(xed)
ORDER BY Creation_Date DESC
GO
