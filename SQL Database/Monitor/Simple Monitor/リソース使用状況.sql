DECLARE @TargetHour int = 1

-- Resource Access
SELECT 
	end_date,
	service_objective,

	-- Storage Usage
	[allocated_extent_megabytes],

	-- Batch Request/sec, Worker , Session
	[Batch Requests/sec],
	[max_worker_percent], 
	[active_workers_count], 
	[max_session_percent],
	[User Connections],

	-- DTU CPU
	[avg_cpu_percent], 

	-- CPU
	CAST(CAST([CPU usage %] AS Float) / 
	CAST([CPU usage % base] AS Float) * 100 AS numeric(6,2)
	) AS [CPU usage %] ,

	-- Memory
	[avg_memory_usage_percent], 
	CAST([Database Cache Memory (KB)] / 1024.0 AS numeric(10,3)) AS [Database Cache Memory (MB)],

	-- DTU Data IO
	[avg_data_io_percent], 

	-- Database File (Read)
	CAST([Disk Read Bytes/sec] / POWER(1024.0,2) AS numeric(10,3)) AS [Disk Read MBytes/sec] ,
	[Disk Reads/sec],
	-- Database File (Read : Basic / Standard HTTP Storage)
	CAST([Read Bytes/Sec] / POWER(1024.0,2) AS numeric(10,3)) AS  [Read MBytes/Sec (HTTP)] ,
	[Reads/sec] AS [Reads/Sec (HTTP)],

	-- Database File (Write)
	CAST([Disk Write Bytes/sec] / POWER(1024.0,2) AS numeric(10,3)) AS [Disk Write MBytes/sec],
	[Disk Writes/sec],

	-- Database File (Write : Basic / Standard HTTP Storage)
	CAST([Write Bytes/Sec] / POWER(1024.0,2) AS numeric(10,3)) AS  [Write MBytes/Sec (HTTP)] ,
	[Writes/sec] AS [Writes/Sec (HTTP)],

	-- Check Point (Pages : 1 Page = 8kb)
	[Checkpoint pages/sec],
	CAST([Page writes/sec] * 8.0 / 1024 AS numeric(10,3)) AS  [Page write MBytes/sec], 
	CAST([Background writer pages/sec] * 8.0  /1024 AS numeric(10,3)) AS  [Background writer MBytes/sec],

	-- DTU Log
	[avg_log_write_percent], 

	-- Transaction Log
	CAST([Log Bytes Flushed/sec] / POWER(1024.0,2) AS numeric(10,3)) AS [Log MBytes Flushed/sec],
	[Log Flushes/sec], 
	[Log Writer Writes/sec],

	-- In-Memory OLTP
	[xtp_storage_percent]
FROM
(
SELECT 
 	end_date,
	service_objective,
	counter_name,
	cntr_value AS cntr_value_diff
FROM 
	Simple_Monitor 
WHERE 
	end_date >= DATEADD(HOUR, @TargetHour * -1, DATEADD(HOUR, 9, GETUTCDATE()))
	AND
	(
		(object_name LIKE  '%Workload Group Stats'	AND counter_name LIKE 'Disk%' AND cntr_type = 65792)
		OR
		(object_name = 'sys.dm_db_resource_stats')
		OR
		(counter_name LIKE 'CPU usage [%]%')
		OR
		(counter_name IN('User Connections', 'active_workers_count', 'allocated_extent_megabytes'))
	)

UNION

SELECT 
	end_date,
	service_objective,
	counter_name,
	cntr_value AS cntr_value_diff
FROM 
	Simple_Monitor 
WHERE 
	end_date >= DATEADD(HOUR, @TargetHour * -1, DATEADD(HOUR, 9, GETUTCDATE()))
	AND
	counter_name = 'Database Cache Memory (KB)'


UNION

SELECT 
	end_date,
	service_objective,
	counter_name,
	CASE DATEDIFF(SECOND, 
		LAG(end_date,  1, end_date) OVER (PARTITION BY counter_name ORDER BY end_date ASC) ,
		end_date)
		WHEN 0 THEN 0
		ELSE 
			(cntr_value - LAG(cntr_value,  1, 0) OVER (PARTITION BY counter_name ORDER BY end_date ASC)) / DATEDIFF(SECOND, LAG(end_date,  1, end_date) OVER (PARTITION BY counter_name ORDER BY end_date ASC) ,	end_date)
	END AS cntr_value_diff
FROM 
	Simple_Monitor 
WHERE 
	end_date >= DATEADD(HOUR, @TargetHour * -1, DATEADD(HOUR, 9, GETUTCDATE()))
	AND
	counter_name IN ('Batch Requests/sec', 'Log Flushes/sec', 'Log Writer Writes/sec', 'Log Bytes Flushed/sec', 'Checkpoint pages/sec', 'Page writes/sec',	'Background writer pages/sec')

UNION

SELECT 
	end_date,
	service_objective,
	counter_name,
	CASE DATEDIFF(SECOND, 
		LAG(end_date,  1, end_date) OVER (PARTITION BY counter_name ORDER BY end_date ASC) ,
		end_date)
		WHEN 0 THEN 0
		ELSE 
			(cntr_value - LAG(cntr_value,  1, 0) OVER (PARTITION BY counter_name ORDER BY end_date ASC)) / DATEDIFF(SECOND, LAG(end_date,  1, end_date) OVER (PARTITION BY counter_name ORDER BY end_date ASC) ,	end_date)
	END AS cntr_value_diff
FROM 
	Simple_Monitor
WHERE 
	end_date >= DATEADD(HOUR, @TargetHour * -1, DATEADD(HOUR, 9, GETUTCDATE()))
	AND
	(Object_name LIKE '%HTTP Storage%' AND instance_name LIKE '%rs%windows.net%' AND counter_name IN ('Read Bytes/sec', 'Write Bytes/sec', 'Reads/sec', 'Writes/sec'))

) AS T	

PIVOT(
	SUM(cntr_value_diff)
	FOR counter_name IN
	(
		[avg_cpu_percent], [avg_data_io_percent], [avg_log_write_percent], [avg_memory_usage_percent], [xtp_storage_percent], [max_worker_percent], [max_session_percent],
		[CPU usage %],[CPU usage % base],
		[Database Cache Memory (KB)],
		[Batch Requests/sec],
		[User Connections],
		[active_workers_count],
		[allocated_extent_megabytes],
		[Disk Read Bytes/sec],[Disk Reads/sec],[Disk Write Bytes/sec],[Disk Writes/sec],
		[Checkpoint pages/sec], [Log Flushes/sec], [Log Writer Writes/sec], [Log Bytes Flushed/sec],
		[Page writes/sec], [Background writer pages/sec],
		[Read Bytes/Sec], [Reads/Sec], [Write Bytes/Sec], [Writes/Sec]
	) 
) AS PT

ORDER BY 
	end_date DESC
GO
