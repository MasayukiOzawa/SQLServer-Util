SELECT
	SUBSTRING(RTRIM(T.object_name), CHARINDEX(':', RTRIM(T.object_name)) + 1, LEN(RTRIM(T.object_name)) - CHARINDEX(':', RTRIM(T.object_name))) AS object_name,
	T.counter_name,
	T.instance_name,
	(T.cntr_value * 1.0 / T_BASE.cntr_value) * 100 AS cntr_value
FROM
	sys.dm_os_performance_counters AS T
	LEFT JOIN
	(
	SELECT
		*
	FROM
		sys.dm_os_performance_counters
	WHERE
		object_name like '%Resource Pool Stats%'
		AND 
		counter_name = 'CPU usage % base'
	) AS T_Base
	ON
	T_BASE.instance_name = t.instance_name
		
WHERE
	T.object_name like '%Resource Pool Stats%'
	AND 
	T.counter_name = 'CPU usage %'