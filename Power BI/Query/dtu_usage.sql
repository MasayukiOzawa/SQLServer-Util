SELECT
	DATEADD(HOUR, 9, end_time) AT TIME ZONE 'Tokyo Standard Time' AS end_time_jp
	,*
FROM
	sys.dm_db_resource_stats
ORDER BY end_time ASC