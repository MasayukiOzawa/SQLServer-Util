-- https://msdn.microsoft.com/ja-JP/library/ms191246.aspx

-- CPU 使用率の取得
IF CHARINDEX('SQL Azure', CAST(SERVERPROPERTY('Edition') AS nvarchar(255))) = 0
BEGIN
	SELECT 
		RTRIM(pr.object_name) AS object_name,
		'CPU usage %' AS counter_name,
		RTRIM(pr.instance_name) AS instance_name,
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
		pr.object_name like '%Resource Pool Stats%' AND pr.counter_name = 'CPU usage %'
		And
		pr.instance_name = 'default'
END
ELSE
BEGIN
	SELECT 
		RTRIM(pr.object_name) AS object_name,
		'CPU usage %' AS counter_name,
		RTRIM(pr.instance_name) AS instance_name,
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
		pr.object_name like '%Resource Pool Stats%' AND pr.counter_name = 'CPU usage %'
		And
		pr.instance_name = 'SloSharedPool1' 
        Or
		pr.instance_name LIKE 'SloPool%' 
END

-- バッチ実行状況の取得 
DECLARE @previous_time datetime, @current_time datetime
DECLARE @previous_count bigint, @current_count bigint

SELECT @previous_time = GETDATE(), @previous_count = cntr_value from sys.dm_os_performance_counters where counter_name ='Batch Requests/sec'
WAITFOR DELAY '00:00:01'
SELECT @current_time = GETDATE(), @current_count = cntr_value from sys.dm_os_performance_counters where counter_name ='Batch Requests/sec'

SELECT CAST((@current_count - @previous_count ) / (DATEDIFF(ms, @previous_time, @current_time) / 1000.0) AS bigint) AS batch_request
