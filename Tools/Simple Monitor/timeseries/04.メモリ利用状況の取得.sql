SET NOCOUNT ON;

SELECT
	GETDATE() AS counter_date,
	RTRIM(object_name) AS object_name,
	RTRIM(counter_name) AS counter_name,
	RTRIM(instance_name) AS instance_name,
	cntr_value 
FROM 
	sys.dm_os_performance_counters WITH(NOLOCK)
WHERE
	object_name LIKE '%Memory Manager%'
OPTION(RECOMPILE, MAXDOP 1);