SET NOCOUNT ON

SELECT
	GETDATE() AS counter_date,
	instance_name,
	[Lock waits],
	[Memory grant queue waits],
	[Thread-safe memory objects waits],
	[Log write waits],
	[Log buffer waits],
	[Network IO waits],
	[Page IO latch waits],
	[Page latch waits],
	[Non-Page latch waits],
	[Wait for the worker],
	[Workspace synchronization waits],
	[Transaction ownership waits]
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
	FOR counter_name 
	IN( 
		[Lock waits],
		[Memory grant queue waits],
		[Thread-safe memory objects waits],
		[Log write waits],
		[Log buffer waits],
		[Network IO waits],
		[Page IO latch waits],
		[Page latch waits],
		[Non-Page latch waits],
		[Wait for the worker],
		[Workspace synchronization waits],
		[Transaction ownership waits]
	)
) AS PVT
ORDER BY
	instance_name ASC