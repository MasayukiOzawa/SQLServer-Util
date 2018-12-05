-- master データベースに接続して実行 (5 分間隔の直近 14 日間の情報)
SELECT 
	DATEADD(hour, 9, start_time) start_time_jst,
	DATEADD(hour, 9, end_time) end_time_jst,
	*,
	(SELECT Max(v)FROM (VALUES 
	(avg_cpu_percent), 
	(avg_data_io_percent), 
	(avg_log_write_percent)
	)AS value(v)) as [max_DTU_percent]
FROM 
	sys.resource_stats
ORDER BY 
	database_name ASC,
	start_time DESC
OPTION (RECOMPILE)