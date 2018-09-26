-- DROP TABLE IF EXISTS #T1
-- DROP TABLE IF EXISTS #T2
IF (OBJECT_ID('tempdb..#T1') IS NOT NULL)
	DROP TABLE #T1
IF (OBJECT_ID('tempdb..#T2') IS NOT NULL)
	DROP TABLE #T2

SELECT 
	GETDATE() AS counter_date,
	RTRIM(object_name) AS object_name,
	RTRIM(instance_name) AS instance_name,
	RTRIM(counter_name) AS counter_name,
	cntr_value
INTO #T1
FROM 
	sys.dm_os_performance_counters
WHERE
	object_name LIKE '%Replica%'

WAITFOR DELAY '00:00:01'

SELECT 
	GETDATE() AS counter_date,
	RTRIM(object_name) AS object_name,
	RTRIM(instance_name) AS instance_name,
	RTRIM(counter_name) AS counter_name,
	cntr_value
INTO #T2
FROM 
	sys.dm_os_performance_counters
WHERE
	object_name LIKE '%Replica%'

SELECT
	#T2.counter_date,
	#T2.object_name,
	#T2.instance_name,
	#t2.counter_name,
	CAST((#T2.cntr_value - #T1.cntr_value) / (DATEDIFF(ms, #T1.counter_date, #T2.counter_date) / 1000.0) AS bigint) AS cntr_value
FROM
	#T2
	LEFT JOIN
	#T1
	ON
	#T1.object_name = #T2.object_name
	AND
	#T1.counter_name = #T2.counter_name
	AND
	#T1.instance_name = #T2.instance_name
