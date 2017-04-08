-- メモリ利用状況の取得
SELECT
	GETDATE() AS counter_date,
	RTRIM(object_name) AS object_name,
	RTRIM(counter_name) AS counter_name,
	RTRIM(instance_name) AS instance_name,
	cntr_value 
FROM 
	sys.dm_os_performance_counters
WHERE
	object_name LIKE '%Memory Manager%'