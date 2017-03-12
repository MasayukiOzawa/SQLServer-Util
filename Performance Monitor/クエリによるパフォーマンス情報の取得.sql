-- https://msdn.microsoft.com/ja-JP/library/ms191246.aspx

-- リソースプールの情報を取得
SELECT
	instance_name,
	CAST(CAST([CPU usage %] AS float) / CAST([CPU usage % base] AS float) * 100  AS int) AS [CPU Usage],
	[Max memory (KB)] / 1024 AS [Max memory (MB)],
	[Used memory (KB)] / 1024 AS [Used memory (KB)] ,
	[Target memory (KB)] / 1024 AS [Target memory (MB)] ,
	[Cache memory target (KB)] / 1024 AS [Cache memory target (MB)],
	[Query exec memory target (KB)] / 1024 AS [Query exec memory target (MB)],
	[Memory grants/sec],
	[Active memory grants count],
	[Memory grant timeouts/sec],
	[Active memory grant amount (KB)] / 1024 AS [Active memory grant amount (MB)] ,
	[Pending memory grants count],
	[Disk Read IO/sec],
	[Disk Read IO Throttled/sec],
	[Disk Read Bytes/sec] / POWER(1024, 2) AS [Disk Read MB/sec] ,
	[Disk Write IO/sec],
	[Disk Write IO Throttled/sec],
	[Disk Write Bytes/sec] / POWER(1024, 2) AS [Disk Write MB/sec]
FROM
	(
	SELECT
		RTRIM(instance_name) AS instance_name,
		RTRIM(counter_name) AS counter_name,
		cntr_value
	FROM 
		sys.dm_os_performance_counters
	WHERE 
		object_name like '%Resource Pool Stats%'
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
		[Cache memory target (KB)],
		[Query exec memory target (KB)],
		[Memory grants/sec],
		[Active memory grants count],
		[Memory grant timeouts/sec],
		[Active memory grant amount (KB)],
		[Pending memory grants count],
		[Disk Read IO/sec],
		[Disk Read IO Throttled/sec],
		[Disk Read Bytes/sec],
		[Disk Write IO/sec],
		[Disk Write IO Throttled/sec],
		[Disk Write Bytes/sec],
		[Compile memory target (KB)],
		[Avg Disk Read IO (ms)],
		[Avg Disk Read IO (ms) Base],
		[Avg Disk Write IO (ms)],
		[Avg Disk Write IO (ms) Base]
	)
) AS PVT
ORDER BY
	instance_name ASC
GO

-- CPU 使用率の取得
IF CHARINDEX('SQL Azure', CAST(SERVERPROPERTY('Edition') AS nvarchar(255))) = 0
BEGIN
	SELECT 
		1 AS No,
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
	UNION
	SELECT
		2 AS No,
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
		pr.instance_name = 'internal'
	ORDER BY 1 ASC
END
ELSE
BEGIN
	SELECT 
		1 AS No,
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
	UNION
	SELECT 
		2 AS No,
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
		pr.instance_name = 'internal' 
	ORDER BY 1
END
GO

-- バッチ実行状況の取得 
DECLARE @previous_time datetime, @current_time datetime
DECLARE @previous_count bigint, @current_count bigint

SELECT @previous_time = GETDATE(), @previous_count = cntr_value from sys.dm_os_performance_counters where counter_name ='Batch Requests/sec'

WAITFOR DELAY '00:00:01'

SELECT @current_time = GETDATE(), @current_count = cntr_value from sys.dm_os_performance_counters where counter_name ='Batch Requests/sec'
SELECT CAST((@current_count - @previous_count ) / (DATEDIFF(ms, @previous_time, @current_time) / 1000.0) AS bigint) AS batch_request
GO

-- IOPS の取得
DECLARE @previous_time datetime, @current_time datetime
DECLARE @previous_read_count bigint, @current_read_count bigint
DECLARE @previous_write_count bigint, @current_write_count bigint

SELECT
	@previous_time = GETDATE(),
	@previous_read_count = SUM([fn_virtualfilestats].[NumberReads]),
	@previous_write_count = SUM([fn_virtualfilestats].[NumberWrites])
FROM
	fn_virtualfilestats(NULL, NULL)

WAITFOR DELAY '00:00:01'

SELECT
	@current_time = GETDATE(),
	@current_read_count = SUM([fn_virtualfilestats].[NumberReads]),
	@current_write_count = SUM([fn_virtualfilestats].[NumberWrites])
FROM
	fn_virtualfilestats(NULL, NULL)
SELECT
	CAST((@current_read_count - @previous_read_count ) / (DATEDIFF(ms, @previous_time, @current_time) / 1000.0) AS bigint) AS NumberReads,
	CAST((@current_write_count - @previous_write_count ) / (DATEDIFF(ms, @previous_time, @current_time) / 1000.0) AS bigint) AS NumberWrites
GO

-- スループットの取得
DECLARE @previous_time datetime, @current_time datetime
DECLARE @previous_readbyte bigint, @current_readbyte bigint
DECLARE @previous_writebyte bigint, @current_writebyte bigint

SELECT
	@previous_time = GETDATE(),
	@previous_readbyte = SUM([fn_virtualfilestats].[BytesRead]),
	@previous_writebyte = SUM([fn_virtualfilestats].[BytesWritten])
FROM
	fn_virtualfilestats(NULL, NULL)

WAITFOR DELAY '00:00:01'

SELECT
	@current_time = GETDATE(),
	@current_readbyte = SUM([fn_virtualfilestats].[BytesRead]),
	@current_writebyte = SUM([fn_virtualfilestats].[BytesWritten])
FROM
	fn_virtualfilestats(NULL, NULL)

SELECT
	CAST((@current_readbyte - @previous_readbyte ) / (DATEDIFF(ms, @previous_time, @current_time) / 1000.0) AS bigint) / POWER(1024,2) AS [MBytesRead],
	CAST((@current_writebyte - @previous_writebyte ) / (DATEDIFF(ms, @previous_time, @current_time) / 1000.0) AS bigint) / POWER(1024,2) AS [MBytesWritten]
GO
