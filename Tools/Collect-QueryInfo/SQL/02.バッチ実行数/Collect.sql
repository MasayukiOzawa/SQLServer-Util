SELECT 
	@@servername AS server_name,
	CAST(SYSUTCDATETIME() AS datetime2(0)) AS collect_date,
	DB_NAME() as db_name,
	RTRIM(object_name) AS object_name,
	RTRIM(counter_name) AS counter_name,
	RTRIM(instance_name) AS instance_name,
	cntr_value,
	cntr_type
FROM 
	sys.dm_os_performance_counters
WHERE
	object_name LIKE '%Batch Resp Statistics%'
	OR
	counter_name = 'Batch Requests/sec'