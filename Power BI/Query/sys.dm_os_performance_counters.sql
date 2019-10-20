DECLARE @cntr_value bigint
DECLARE @start_time datetime2(2)

SELECT
	@cntr_value = cntr_value,
	@start_time = GETDATE()
FROM 
	sys.dm_os_performance_counters
WHERE
	object_name like '%:SQL Statistics%'
	AND
	counter_name = 'Batch Requests/sec'

WAITFOR DELAY '00:00:01'

SELECT
	SUBSTRING(RTRIM(object_name), CHARINDEX(':', RTRIM(object_name)) + 1, LEN(RTRIM(object_name)) - CHARINDEX(':', RTRIM(object_name))) AS object_name,
	RTRIM(counter_name) AS counter_name,
	RTRIM(instance_name) AS instance_name,
	(cntr_value - @cntr_value) / DATEDIFF(SECOND, @start_time, GETDATE())AS cntr_value
FROM 
	sys.dm_os_performance_counters
WHERE
	object_name like '%:SQL Statistics%'
	AND
	counter_name = 'Batch Requests/sec'
UNION ALL
SELECT 
	SUBSTRING(RTRIM(object_name), CHARINDEX(':', RTRIM(object_name)) + 1, LEN(RTRIM(object_name)) - CHARINDEX(':', RTRIM(object_name))) AS object_name,
	RTRIM(counter_name) AS counter_name,
	RTRIM(instance_name) AS instance_name,
	cntr_value
FROM 
	sys.dm_os_performance_counters 
WHERE 
	object_name LIKE '%:Memory Manager%'
UNION ALL
SELECT 
	SUBSTRING(RTRIM(object_name), CHARINDEX(':', RTRIM(object_name)) + 1, LEN(RTRIM(object_name)) - CHARINDEX(':', RTRIM(object_name))) AS object_name,
	CASE 
		WHEN counter_name = 'Cache Pages' THEN 'Cache Pages (KB)'
		ELSE counter_name
	END AS counter_name,
	RTRIM(instance_name) AS instance_name, 
	CASE 
		WHEN counter_name = 'Cache Pages' THEN cntr_value * 8
		ELSE cntr_value
	END AS cntr_value
FROM 
	sys.dm_os_performance_counters 
WHERE 
	object_name LIKE '%:Plan Cache%'
	AND
	counter_name IN('Cache Pages', 'Cache Object Counts')


