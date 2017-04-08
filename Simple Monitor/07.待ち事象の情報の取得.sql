SET NOCOUNT ON

SELECT
	GETDATE() as counter_date,
	counter_name,
	[Average wait time (ms)],
	[Waits in progress],
	[Waits started per second],
	[Cumulative wait time (ms) per second]
FROM
	(
	SELECT
		RTRIM(instance_name) AS instance_name,
		RTRIM(counter_name) AS counter_name,
		cntr_value
	FROM 
		sys.dm_os_performance_counters
	WHERE 
		object_name like '%Wait Statistics%'
	) AS T
PIVOT
(
	SUM(cntr_value)
	FOR instance_name 
	IN( 
		[Average wait time (ms)],
		[Waits in progress],
		[Waits started per second],
		[Cumulative wait time (ms) per second]
	)
) AS PVT
ORDER BY counter_name