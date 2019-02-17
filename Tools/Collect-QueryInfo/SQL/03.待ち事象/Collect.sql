SELECT 
	@@servername AS server_name,
	CAST(SYSUTCDATETIME() AS datetime2(0)) AS collect_date,
	DB_NAME() as db_name,
	wait_type,
	waiting_tasks_count,
	wait_time_ms,
	max_wait_time_ms,
	signal_wait_time_ms
FROM 
	sys.dm_os_wait_stats