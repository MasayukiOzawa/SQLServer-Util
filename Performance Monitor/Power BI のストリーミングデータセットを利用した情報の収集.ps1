$endpoint = "エンドポイント URL"

$sql = @"
SELECT
    GETDATE() AS input_date,
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
"@

while($true){
    $ret = Invoke-Sqlcmd -ServerInstance <インスタンス名> -Username <ユーザー名> -Password <パスワード> -Database <DB> -Query $sql

    Invoke-RestMethod -Method Post -Uri "$endpoint" -Body (ConvertTo-Json ($ret | select input_Date,instance_name,"CPU Usage","Max memory (MB)","Used memory (KB)","Target memory (MB)","Cache memory target (MB)","Query exec memory target (MB)","Memory grants/sec","Active memory grants count","Memory grant timeouts/sec","Active memory grant amount (MB)","Pending memory grants count","Disk Read IO/sec","Disk Read IO Throttled/sec","Disk Read MB/sec","Disk Write IO/sec","Disk Write IO Throttled/sec","Disk Write MB/sec"))
    Start-Sleep -Seconds 1
}