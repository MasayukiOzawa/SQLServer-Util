SELECT 
	*
FROM 
	sys.dm_db_wait_stats 
ORDER BY wait_time_ms DESC
OPTION (RECOMPILE)

SELECT 
	*
FROM 
	sys.dm_os_wait_stats 
ORDER BY wait_time_ms DESC
OPTION (RECOMPILE)
