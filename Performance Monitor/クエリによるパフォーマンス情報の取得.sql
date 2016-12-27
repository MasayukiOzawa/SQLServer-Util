-- https://msdn.microsoft.com/ja-JP/library/ms191246.aspx

-- CPU 使用率の取得
SELECT 
	pr.object_name,
	'CPU usage %' AS counter_name,
	pr.instance_name,
	CASE
		WHEN pr.cntr_value = 0 THEN 0
		ELSE CAST((CAST(pr.cntr_value AS FLOAT) / pb.cntr_value) * 100 AS numeric(5,2))
	END AS 'cpu_usage'                                                                                           
FROM 
	sys.dm_os_performance_counters pr
	INNER JOIN
	sys.dm_os_performance_counters pb
	ON
	pr.object_name = pb.object_name
	AND
	pr.instance_name = pb.instance_name
	AND
	pb.counter_name = 'CPU usage % base'
WHERE 
	pr.object_name = 'SQLServer:Resource Pool Stats' AND pr.counter_name = 'CPU usage %'

