DECLARE @file nvarchar(max) = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\BasicInfo*.xel'
DECLARE @metafile nvarchar(max) = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\BasicInfo*.xem'
DECLARE @version int = (SELECT LEFT(CAST(SERVERPROPERTY('ProductVersion') AS varchar(255)), CHARINDEX('.', (CAST(SERVERPROPERTY('ProductVersion') AS varchar(255))))-1)) 

-- Query
SELECT
	DATEADD(hour,9 , xmldata.value('(/event/@timestamp)[1]', 'datetime')) AS timestamp,
	object_name,
	xmldata.value('(/event/action[@name="database_id"]/value)[1]', 'int') AS database_id,
	xmldata.value('(/event/action[@name="database_name"]/value)[1]', 'sysname') AS database_name,
	xmldata.value('(/event/data[@name="batch_text"]/value)[1]', 'nvarchar(max)') AS batch_text,
	xmldata.value('(/event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS sql_text,
	CASE WHEN @version >= 11
	THEN xmldata.value('(/event/data[@name="duration"]/value)[1]', 'bigint') / 1000 
	ELSE xmldata.value('(/event/data[@name="duration"]/value)[1]', 'bigint') END AS duration_ms,
	CASE WHEN @version >= 11
	THEN xmldata.value('(/event/data[@name="cpu_time"]/value)[1]', 'bigint') / 1000
	ELSE xmldata.value('(/event/data[@name="cpu"]/value)[1]', 'bigint')	END  AS cpu_time_ms,
	CASE WHEN @version >= 11
	THEN xmldata.value('(/event/data[@name="physical_reads"]/value)[1]', 'bigint') 
	ELSE xmldata.value('(/event/data[@name="reads"]/value)[1]', 'bigint') END AS physical_reads,
	CASE WHEN @version >= 11
	THEN xmldata.value('(/event/data[@name="logical_reads"]/value)[1]', 'bigint') 
	ELSE NULL END AS logical_reads,
	xmldata.value('(/event/data[@name="writes"]/value)[1]', 'bigint') AS writes,
	xmldata.value('(/event/data[@name="row_count"]/value)[1]', 'bigint') AS row_count,
	CASE xmldata.value('(/event/data[@name="result"]/value)[1]', 'int') 
	WHEN 0 THEN 'OK'
	WHEN 2 THEN 'Abort'
	ELSE xmldata.value('(/event/data[@name="result"]/value)[1]', 'sysname') END AS result,
	xmldata.value('(/event/action[@name="query_plan_hash"]/value)[1]', 'sysname') AS query_plan_hash,
	xmldata.value('(/event/action[@name="query_hash"]/value)[1]', 'sysname') AS query_hash,
	xmldata.value('(/event/action[@name="nt_username"]/value)[1]', 'sysname') AS nt_username,
	xmldata.value('(/event/action[@name="username"]/value)[1]', 'sysname') AS username,
	xmldata.value('(/event/action[@name="client_hostname"]/value)[1]', 'sysname') AS client_hostname,
	xmldata.value('(/event/action[@name="client_app_name"]/value)[1]', 'sysname') AS client_app_name
FROM(
	SELECT
		object_name,
		CAST(event_data AS XML) AS xmldata
	FROM
		sys.fn_xe_file_target_read_file(@file, @metafile, NULL, NULL)
	WHERE
		object_name IN('sp_statement_completed', 'sql_batch_completed', 'rpc_completed', 'sql_statement_completed')
) AS x
ORDER BY timestamp ASC

-- Error
SELECT
	DATEADD(hour,9 , xmldata.value('(/event/@timestamp)[1]', 'datetime')) AS timestamp,
	object_name,
	xmldata.value('(/event/action[@name="database_id"]/value)[1]', 'int') AS database_id,
	xmldata.value('(/event/action[@name="database_name"]/value)[1]', 'sysname') AS database_name,
	xmldata.value('(/event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS sql_text,
	xmldata.value('(/event/data[@name="message"]/value)[1]', 'nvarchar(max)') AS message,
	xmldata.value('(/event/data[@name="error_number"]/value)[1]', 'nvarchar(max)') AS error_number,
	xmldata.value('(/event/data[@name="severity"]/value)[1]', 'nvarchar(max)') AS severity,
	xmldata.value('(/event/data[@name="state"]/value)[1]', 'nvarchar(max)') AS state,
	xmldata.value('(/event/action[@name="query_plan_hash"]/value)[1]', 'sysname') AS query_plan_hash,
	xmldata.value('(/event/action[@name="query_hash"]/value)[1]', 'sysname') AS query_hash,
	xmldata.value('(/event/action[@name="nt_username"]/value)[1]', 'sysname') AS nt_username,
	xmldata.value('(/event/action[@name="username"]/value)[1]', 'sysname') AS username,
	xmldata.value('(/event/action[@name="client_hostname"]/value)[1]', 'sysname') AS client_hostname,
	xmldata.value('(/event/action[@name="client_app_name"]/value)[1]', 'sysname') AS client_app_name
FROM(
	SELECT
		object_name,
		CAST(event_data AS XML) AS xmldata
	FROM
		sys.fn_xe_file_target_read_file(@file, @metafile, NULL, NULL)
	WHERE
		object_name IN('error_reported')
) AS x
ORDER BY timestamp ASC


-- Blocking
SELECT
	DATEADD(hour,9 , xmldata.value('(/event/@timestamp)[1]', 'datetime')) AS timestamp,
	object_name,
	xmldata.value('(/event/data[@name="database_id"]/value)[1]', 'int') AS database_id,
	xmldata.value('(/event/data[@name="database_name"]/value)[1]', 'sysname') AS database_name,
	xmldata.value('(/event/data[@name="lock_mode"]/text)[1]', 'sysname') AS lock_mode,
	xmldata.value('(/event/data[@name="blocked_process"]/value/blocked-process-report/blocked-process)[1]', 'nvarchar(max)') AS blocked_process,
	xmldata.value('(/event/data[@name="blocked_process"]/value/blocked-process-report/blocking-process)[1]', 'nvarchar(max)') AS blocking_process,
	CASE WHEN @version >= 11
	THEN xmldata.value('(/event/data[@name="duration"]/value)[1]', 'bigint') / 1000 
	ELSE xmldata.value('(/event/data[@name="duration"]/value)[1]', 'bigint') END AS duration_ms
FROM(
	SELECT
		object_name,
		CAST(event_data AS XML) AS xmldata
	FROM
		sys.fn_xe_file_target_read_file(@file, @metafile, NULL, NULL)
	WHERE
		object_name IN('blocked_process_report')
) AS x
ORDER BY timestamp ASC

-- Dead Lock
SELECT
	DATEADD(hour,9 , xmldata.value('(/event/@timestamp)[1]', 'datetime')) AS timestamp,
	object_name,
	xmldata.value('(/event/data/value/deadlock/process-list//inputbuf)[1]', 'nvarchar(max)') AS blocking_process_1,
	xmldata.value('(/event/data/value/deadlock/process-list//inputbuf)[2]', 'nvarchar(max)') AS blocking_process_2
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


