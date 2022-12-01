/*
CREATE EVENT SESSION [Lock Info] ON SERVER 
ADD EVENT sqlserver.lock_acquired(SET collect_database_name=(1),collect_resource_description=(1)
    ACTION(sqlserver.client_app_name,sqlserver.session_id,sqlserver.sql_text)
    WHERE ([package0].[equal_uint64]([sqlserver].[session_id],(59)))),
ADD EVENT sqlserver.lock_released(SET collect_database_name=(1),collect_resource_description=(1)
    ACTION(sqlserver.client_app_name,sqlserver.session_id,sqlserver.sql_text)
    WHERE ([package0].[equal_uint64]([sqlserver].[session_id],(59))))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=NO_EVENT_LOSS,MAX_DISPATCH_LATENCY=5 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO

DROP TABLE IF EXISTS xEvents
GO
*/

SELECT
    timestamp,
    name, 
    resource_type, 
    mode,
    CASE
        WHEN resource_type = 'OBJECT' THEN object_name(resource_0, database_id)
        WHEN resource_type = 'DATABASE' THEN DB_NAME(resource_0)
        WHEN resource_type = 'METADATA' THEN resource_description
        WHEN resource_type = 'KEY' THEN object_name(resource_0,database_id) + ' : '+ resource_description
        ELSE CAST(resource_0 AS varchar(10))
    END AS lock_resource,
    resource_0,
    resource_1,
    resource_2,
    resource_description,
    [attach_activity_id.guid],
    [attach_activity_id.seq],
    client_app_name,
    sql_text
FROM 
    xEvents 
ORDER BY
    timestamp ASC
GO

DROP TABLE IF EXISTS tmp
SELECT 
	DATEADD(hour, 9, CAST(event_data as XML).value('(//@timestamp)[1]', 'datetime2')) AS timestamp,
	CAST(event_data as XML).value('(//data[@name="lock_mode"]/text)[1]', 'nvarchar(max)') AS lock_mode,
	CAST(event_data as XML).value('(//blocking-process/process/@lastbatchstarted)[1]', 'datetime2(3)') AS blocking_lastbatchstarted,
	CAST(event_data as XML).value('(//blocking-process/process/@lastbatchcompleted)[1]', 'datetime2(3)') AS blocking_lastbatchcompleted,
	CAST(event_data as XML).value('(//blocking-process/process/@lastattention)[1]', 'datetime2(3)') AS blocking_lastattention,
	CAST(event_data as XML).value('(//blocking-process/process/@hostname)[1]', 'nvarchar(max)') AS blocking_hostname,
	CAST(event_data as XML).value('(//blocking-process/process/@spid)[1]', 'int') AS blocking_spid,
	CAST(event_data as XML).value('(//blocking-process/process/@status)[1]', 'nvarchar(max)') AS blocking_status,
	CAST(event_data as XML).value('(//blocking-process/process/@waitresource)[1]', 'nvarchar(max)') as blocking_waitresource,
	CAST(event_data as XML).value('(//blocking-process/process/@clientapp)[1]', 'nvarchar(max)') AS blocking_clientapp,
	CAST(event_data as XML).value('(//blocking-process/process/@trancount)[1]', 'int') AS blocking_trancont,
	CAST(event_data as XML).value('(//blocking-process//inputbuf)[1]', 'nvarchar(max)') AS blocking_inputbuf,
	CAST(event_data as XML).value('(//blocking-process//executionStack/frame/@line)[1]', 'int') AS blocking_line,
	CAST(event_data as XML).value('(//blocking-process//executionStack/frame/@stmtstart)[1]', 'int') AS blocking_stmtstart,
	CAST(event_data as XML).value('(//blocking-process//executionStack/frame/@stmtend)[1]', 'int') AS blocking_stmtend,
	CAST(event_data as XML).value('(//blocked-process/process/@lasttranstarted)[1]', 'datetime2(3)') AS blocked_lasttranstarted,
	CAST(event_data as XML).value('(//blocked-process/process/@lastbatchstarted)[1]', 'datetime2(3)') AS blocked_lastbatchstarted,
	CAST(event_data as XML).value('(//blocked-process/process/@lastbatchcompleted)[1]', 'datetime2(3)') AS blocked_lastbatchcompleted,
	CAST(event_data as XML).value('(//blocked-process/process/@hostname)[1]', 'nvarchar(max)') AS blocked_hostname,
	CAST(event_data as XML).value('(//blocked-process/process/@spid)[1]', 'int') AS blocked_spid,
	CAST(event_data as XML).value('(//blocked-process/process/@status)[1]', 'nvarchar(max)') AS blocked_status,
	CAST(event_data as XML).value('(//blocked-process/process/@waitresource)[1]', 'nvarchar(max)') as blocked_waitresource,
	CAST(event_data as XML).value('(//blocked-process/process/@transactionname)[1]', 'nvarchar(max)') AS blocked_transactionname,
	CAST(event_data as XML).value('(//blocked-process/process/@clientapp)[1]', 'nvarchar(max)') AS blocked_clientapp,
	CAST(event_data as XML).value('(//blocked-process/process/@trancount)[1]', 'int') AS blocked_trancont,
	CAST(event_data as XML).value('(//blocked-process//inputbuf)[1]', 'nvarchar(max)') AS blocked_inputbuf,
	CAST(event_data as XML).value('(//blocked-process//executionStack/frame/@line)[1]', 'int') AS blocked_line,
	CAST(event_data as XML).value('(//blocked-process//executionStack/frame/@stmtstart)[1]', 'int') AS blocked_stmtstart,
	CAST(event_data as XML).value('(//blocked-process//executionStack/frame/@stmtend)[1]', 'int') AS blocked_stmtend,
	CAST(event_data as XML) AS event_data
INTO tmp
FROM 
	sys.fn_xe_file_target_read_file('f:\work\*.xel', NULL, NULL, NULL)
ORDER BY 1
GO

SELECT 
	*
FROM tmp
GO
