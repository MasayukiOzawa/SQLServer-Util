SET NOCOUNT ON
IF (SERVERPROPERTY('ProductMajorVersion') IS NOT NULL)
BEGIN
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
END
ELSE
BEGIN
	SELECT
		GETDATE() as counter_date,
		counter_name,
		[平均待機時間 (ミリ秒)] AS [Average wait time (ms)],
		[待機中] AS [Waits in progress],
		[1 秒あたりに開始された待機回数] AS [Waits started per second],
		[1 秒あたりの累積待機時間 (ミリ秒)] AS [Cumulative wait time (ms) per second]
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
			[平均待機時間 (ミリ秒)],
			[待機中],
			[1 秒あたりに開始された待機回数],
			[1 秒あたりの累積待機時間 (ミリ秒)]
		)
	) AS PVT
	ORDER BY counter_name
END