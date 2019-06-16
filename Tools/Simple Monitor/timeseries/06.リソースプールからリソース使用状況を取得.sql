SET NOCOUNT ON;

SELECT
	GETDATE() AS counter_date,
	instance_name,
	CAST([CPU usage %] AS float) / CAST([CPU usage % base] AS float) * 100.0 AS [CPU Usage],
	[Max memory (KB)] / 1024.0 AS [Max memory (MB)],
	[Used memory (KB)] / 1024.0 AS [Used memory (KB)] ,
	[Target memory (KB)] / 1024.0 AS [Target memory (MB)] ,
	[Disk Read IO/sec],
	[Disk Read IO Throttled/sec],
	[Disk Read Bytes/sec] / POWER(1024.0, 2) AS [Disk Read MB/sec] ,
	[Disk Write IO/sec],
	[Disk Write IO Throttled/sec],
	[Disk Write Bytes/sec] / POWER(1024.0, 2) AS [Disk Write MB/sec]
FROM
	(
	SELECT
		RTRIM(instance_name) AS instance_name,
		RTRIM(counter_name) AS counter_name,
		cntr_value
	FROM 
		sys.dm_os_performance_counters WITH(NOLOCK)
	WHERE 
		object_name like '%Resource Pool Stats%'
		AND
		counter_name IN (
		'CPU usage %', 
		'CPU usage % base',
		'Max memory (KB)',
		'Used memory (KB)',
		'Target memory (KB)',
		'Disk Read IO/sec',
		'Disk Read IO Throttled/sec',
		'Disk Read Bytes/sec',
		'Disk Write IO/sec',
		'Disk Write IO Throttled/sec',
		'Disk Write Bytes/sec'
		)
	) AS T
PIVOT
(
	SUM(cntr_value)
	FOR counter_name 
	IN( 
		[CPU usage %],
		[CPU usage % base],
		[Max memory (KB)],
		[Used memory (KB)],
		[Target memory (KB)],
		[Disk Read IO/sec],
		[Disk Read IO Throttled/sec],
		[Disk Read Bytes/sec],
		[Disk Write IO/sec],
		[Disk Write IO Throttled/sec],
		[Disk Write Bytes/sec]
	)
) AS PVT
ORDER BY
	instance_name ASC
OPTION(RECOMPILE, MAXDOP 1);