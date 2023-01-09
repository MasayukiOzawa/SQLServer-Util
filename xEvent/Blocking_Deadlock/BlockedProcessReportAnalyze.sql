/*
DROP TABLE IF EXISTS [blocked_report_yyyymmdd];

SELECT
	DATEADD(hour, 9, CAST(event_data as XML).value('(//@timestamp)[1]', 'datetime2')) AS timestamp,
	CAST(event_data as XML).value('(/event/@name)[1]', 'varchar(100)') AS name,
	CAST(event_data as XML) AS event_data
INTO [blocked_report_yyyymmdd]
FROM 
	sys.fn_xe_file_target_read_file('D:\work_yyyymmdd\blocked_report\*.xel', NULL, NULL, NULL)
ORDER BY 1
GO
*/

DECLARE @start_time datetime2(3) = '2022-01-01 00:00:00'
DECLARE @end_time   datetime2(3) = '2023-12-31 00:00:00'


SELECT 
	[timestamp],
	name,
	--CAST(event_data as XML).value('(/event/data[@name="database_id"])[1]', 'int') AS database_id,
	--CAST(event_data as XML).value('(/event/data[@name="object_id"])[1]', 'int') AS object_id,
	--CAST(event_data as XML).value('(/event/data[@name="index_id"])[1]', 'int') AS index_id,
	CAST(event_data as XML).value('(/event/data[@name="lock_mode"]/text)[1]', 'varchar(100)') AS lock_mode,
	CAST(event_data as XML).value('(/event/data[@name="resource_owner_type"]/text)[1]', 'varchar(100)') AS resource_owner_type,
	CAST(event_data as XML).value('(/event/data[@name="database_name"])[1]', 'varchar(100)') AS database_name,


	CAST(event_data as XML).value('(/event/data[@name="blocked_process"]//blocked-process/process/@lasttranstarted)[1]', 'datetime2(3)') AS blocked_lasttranstarted,
	CAST(event_data as XML).value('(/event/data[@name="blocked_process"]//blocked-process/process/@lastbatchstarted)[1]', 'datetime2(3)') AS blocked_lastbatchstarted,
	CAST(event_data as XML).value('(/event/data[@name="blocked_process"]//blocked-process/process/@lastattention)[1]', 'datetime2(3)') AS blocked_lastattention,
	CAST(event_data as XML).value('(/event/data[@name="blocked_process"]//blocked-process/process/@waitresource)[1]', 'varchar(100)') AS blocked_waitresource,
	CAST(event_data as XML).value('(/event/data[@name="blocked_process"]//blocked-process/process/@waittime)[1]', 'int') AS blocked_waittime,
	CAST(event_data as XML).value('(/event/data[@name="blocked_process"]//blocked-process/process/@transactionname)[1]', 'varchar(100)') AS blocked_transactionname,
	CAST(event_data as XML).value('(/event/data[@name="blocked_process"]//blocked-process/process/@lockMode)[1]', 'varchar(100)') AS blocked_lockMode,
	CAST(event_data as XML).value('(/event/data[@name="blocked_process"]//blocked-process/process/@status)[1]', 'varchar(100)') AS blocked_status,
	CAST(event_data as XML).value('(/event/data[@name="blocked_process"]//blocked-process/process/@spid)[1]', 'int') AS blocked_spid,
	CAST(event_data as XML).value('(/event/data[@name="blocked_process"]//blocked-process/process/@hostname)[1]', 'varchar(100)') AS blocked_hostname,
	CAST(event_data as XML).value('(/event/data[@name="blocked_process"]//blocked-process/process/@loginname)[1]', 'varchar(100)') AS blocked_loginname,
	CAST(event_data as XML).value('(/event/data[@name="blocked_process"]//blocked-process//inputbuf)[1]', 'nvarchar(max)') AS blocked_inputbuf,


	CAST(event_data as XML).value('(/event/data[@name="blocked_process"]//blocking-process/process/@lastbatchstarted)[1]', 'datetime2(3)') AS blocking_lastbatchstarted,
	CAST(event_data as XML).value('(/event/data[@name="blocked_process"]//blocking-process/process/@lastbatchcompleted)[1]', 'datetime2(3)') AS blocking_lastbatchcompleted,
	CAST(event_data as XML).value('(/event/data[@name="blocked_process"]//blocking-process/process/@lastattention)[1]', 'datetime2(3)') AS blocking_lastbatchcompleted,
	CAST(event_data as XML).value('(/event/data[@name="blocked_process"]//blocking-process/process/@status)[1]', 'varchar(100)') AS blocking_status,
	CAST(event_data as XML).value('(/event/data[@name="blocked_process"]//blocking-process/process/@trancount)[1]', 'int') AS blocking_trancount,
	CAST(event_data as XML).value('(/event/data[@name="blocked_process"]//blocking-process/process/@spid)[1]', 'int') AS blocking_spid,
	CAST(event_data as XML).value('(/event/data[@name="blocked_process"]//blocking-process/process/@hostname)[1]', 'varchar(100)') AS blocking_hostname,
	CAST(event_data as XML).value('(/event/data[@name="blocked_process"]//blocking-process/process/@loginname)[1]', 'varchar(100)') AS blocking_loginname,
	CAST(event_data as XML).value('(/event/data[@name="blocked_process"]//blocking-process//inputbuf)[1]', 'nvarchar(max)') AS blocking_inputbuf,


	CAST(event_data as XML) AS event_data
FROM  
	[blocked_report_yyyymmdd]
WHERE
	name = 'blocked_process_report'
	AND timestamp >= @start_time AND timestamp < @end_time
ORDER BY 
	timestamp ASC