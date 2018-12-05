/*
master で実行する
*/
SELECT top 100 *,
	CAST(event_data as XML).value('(/event/@timestamp)[1]', 'datetime2') AS timestamp
	,CAST(event_data as XML).value('(/event/data[@name="error"]/value)[1]', 'INT') AS error
	,CAST(event_data as XML).value('(/event/data[@name="state"]/value)[1]', 'INT') AS state
	,CAST(event_data as XML).value('(/event/data[@name="is_success"]/value)[1]', 'bit') AS is_success
	,CAST(event_data as XML).value('(/event/data[@name="database_name"]/value)[1]', 'sysname') AS database_name
	,CAST(event_data as XML) AS xdl
FROM 
	sys.fn_xe_telemetry_blob_target_read_file('el', null, null, null) 
WHERE 
	object_name = 'lock_deadlock' 
ORDER BY CAST(event_data as XML).value('(/event/@timestamp)[1]', 'datetime2') desc
GO

SELECT top 100 *,
	CAST(event_data as XML).value('(/event/@timestamp)[1]', 'datetime2') AS timestamp
	,CAST(event_data as XML).value('(/event/data[@name="error"]/value)[1]', 'INT') AS error
	,CAST(event_data as XML).value('(/event/data[@name="state"]/value)[1]', 'INT') AS state
	,CAST(event_data as XML).value('(/event/data[@name="is_success"]/value)[1]', 'bit') AS is_success
	,CAST(event_data as XML).value('(/event/data[@name="database_name"]/value)[1]', 'sysname') AS database_name
	,CAST(event_data as XML) AS xdl
FROM 
	sys.fn_xe_telemetry_blob_target_read_file('dl', null, null, null) 
WHERE 
	object_name = 'database_xml_deadlock_report'
ORDER BY CAST(event_data as XML).value('(/event/@timestamp)[1]', 'datetime2') desc
GO

-- fn_xe_telemetry_blob_target_read_file の種別 (2018/08 時点)
-- dl
-- el
-- ru
