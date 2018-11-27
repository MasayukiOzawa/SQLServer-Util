SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP PROCEDURE IF EXISTS [dbo].[usp_LiveMonitor]
GO

CREATE PROCEDURE [dbo].[usp_LiveMonitor]
AS
BEGIN

SET NOCOUNT ON
DROP TABLE IF EXISTS #Results
DROP TABLE IF EXISTS #T1
DROP TABLE IF EXISTS #T2

CREATE TABLE #Results(
	counter_name sysname,
	cntr_value float
)

/********************************************************/
SELECT
	GETDATE() AS counter_date,
	*
INTO #T1
FROM 
	sys.dm_os_performance_counters
WHERE
	(counter_name IN('Page lookups/sec', 'Batch Requests/sec', 'Page reads/sec', 'Readahead pages/sec', 'Page writes/sec','Checkpoint pages/sec', 'Background writer pages/sec'))
	OR
	(object_name LIKE '%:Databases%'
	AND
	counter_name IN ('Log Flushes/sec', 'Log Bytes Flushed/sec', 'Log Flush Waits/sec', 'Log Flush Wait Time')
	AND
	instance_name NOT IN ('master', '_Total','msdb', 'model', 'mssqlsystemresource', 'model_userdb', 'tempdb', 'model_masterdb'))
	OR
	(counter_name IN ('SQL Compilations/sec', 'SQL Re-Compilations/sec'))

WAITFOR DELAY '00:00:01'

SELECT
	GETDATE() AS counter_date,
	*
INTO #T2
FROM 
	sys.dm_os_performance_counters
WHERE
	(counter_name IN('Page lookups/sec', 'Batch Requests/sec', 'Page reads/sec', 'Readahead pages/sec', 'Page writes/sec','Checkpoint pages/sec', 'Background writer pages/sec'))
	OR
	(object_name LIKE '%:Databases%'
	AND
	counter_name IN ('Log Flushes/sec', 'Log Bytes Flushed/sec', 'Log Flush Waits/sec', 'Log Flush Wait Time')
	AND
	instance_name NOT IN ('master', '_Total','msdb', 'model', 'mssqlsystemresource', 'model_userdb', 'tempdb', 'model_masterdb'))
	OR
	(counter_name IN ('SQL Compilations/sec', 'SQL Re-Compilations/sec'))

INSERT INTO #Results
SELECT 
	RTRIM(#T1.counter_name) counter_name,
	CAST((#T2.cntr_value - #T1.cntr_value) / (DATEDIFF (ms, #T1.counter_date,#T2.counter_date) / 1000.0) AS bigint) as cntr_value
FROM #T1
	LEFT JOIN
	#T2
	ON
	#T1.object_name = #T2.object_name
	AND
	#T1.counter_name = #T2.counter_name

/********************************************************/	
INSERT INTO #Results
SELECT
	counter_name,
	cntr_value
FROM 
	sys.dm_os_performance_counters
WHERE
	counter_name IN(
		'Database Cache Memory (KB)', 
		'Free Memory (KB)', 
		'Total Server Memory (KB)', 
		'Target Server Memory (KB)',
		'Granted Workspace Memory (KB)',
		'Memory Grants Outstanding',
		'Memory Grants Pending')
	OR
	(counter_name = 'Page life expectancy' AND object_name LIKE '%Buffer Manager%')
	OR
	(counter_name = 'Cache Pages' AND instance_name = '_Total')


/********************************************************/
INSERT INTO #Results
SELECT
	counter_name,
	cntr_value
FROM(
	SELECT
		CAST([CPU usage %] AS float) / CAST([CPU usage % base] AS float) * 100.0 AS [CPU Usage %],
		CAST([Buffer cache hit ratio] AS float) / CAST([Buffer cache hit ratio base] AS float) * 100.0 AS [Buffer Cache Hit %],
		CAST([Cache Hit Ratio] AS float) / CAST([Cache Hit Ratio Base] AS float) * 100.0 AS [Plan Cache Hit %]
	FROM
		(
		SELECT
			RTRIM(counter_name) AS counter_name,
			cntr_value
		FROM 
			sys.dm_os_performance_counters
		WHERE 
			(object_name like '%Resource Pool Stats%'
			AND
			counter_name IN ('CPU usage %', 'CPU usage % base')
			AND 
			(instance_name LIKE 'SloPool%' OR instance_name LIKE 'SloSharedPool%'))                                                                                                    
			OR
			(counter_name LIKE 'Cache Hit Ratio%' AND instance_name = '_Total' 
			AND
			object_name LIKE '%Plan Cache%')
			OR
			(counter_name LIKE 'Buffer cache hit_ratio%')
		) AS T
	PIVOT
	(
		SUM(cntr_value)
		FOR counter_name 
		IN( 
			[CPU usage %],
			[CPU usage % base],
			[Buffer cache hit ratio],
			[Buffer cache hit ratio base],
			[Cache Hit Ratio],
			[Cache Hit Ratio Base]
		)
	) AS PVT
) AS P
UNPIVOT(
	cntr_value
	FOR
	counter_name
	IN
	(
		[CPU Usage %],
		[Buffer Cache hit %],
		[Plan Cache Hit %]
	)
) AS UNPVOT


/********************************************************/
INSERT INTO #Results
SELECT
	counter_name, cntr_value
FROM
	(SELECT TOP 1 
	 avg_cpu_percent, avg_data_io_percent, avg_log_write_percent, avg_memory_usage_percent
	 FROM sys.dm_db_resource_stats
	 ORDER BY end_time DESC) P
UNPIVOT
	(cntr_value 
	FOR 
	counter_name 
	IN
	(avg_cpu_percent, 
	 avg_data_io_percent, 
	 avg_log_write_percent, 
	 avg_memory_usage_percent)
)AS UNPVOT


/********************************************************/
SELECT 
	GETDATE() AS [Counter Date],
	DB_NAME() AS [Database Name],
	[avg_cpu_percent] As [DTU CPU %],
	[avg_data_io_percent] AS [DTU DATA IO %],
	[avg_log_write_percent] AS [DTU LOG Write %],
	[avg_memory_usage_percent] AS [DTU Memory Usage %],
	CAST([CPU Usage %] AS numeric(5,2)) AS [CPU Usage %],
	CAST([Buffer Cache Hit %] AS numeric(5,2)) AS [Buffer Cache Hit %], 
	CAST([Plan Cache Hit %] AS numeric(5,2)) AS [Plan Cache Hit %],
	[Page life expectancy],
	CAST([Database Cache Memory (KB)] / 1024 AS bigint) AS [Database Cache Memory (MB)] ,
	CAST([Cache Pages] * 8 / 1024 AS bigint) AS [Plan Chache Memory (MB)],
	CAST([Free Memory (KB)] / 1024 AS bigint) AS [Free Memory (MB)], 
	CAST([Total Server Memory (KB)] / 1024  AS bigint) AS [Total Server Memory (MB)],
	CAST([Target Server Memory (KB)] / 1024 AS bigint) AS [Target Server Memory (MB)],
	CAST([Granted Workspace Memory (KB)] / 1024 AS bigint) AS [Granted Workspace Memory (MB)],
	[Memory Grants Outstanding],
	[Memory Grants Pending],
	[Batch Requests/sec],
	[Page lookups/sec] * 8 / 1024 AS [Page lookups (MB)/sec],
	[Readahead pages/sec] * 8 / 1024 AS [Readahead pages (MB)/sec],
	[Page reads/sec] * 8 / 1024 AS [Page reads (MB)/sec],
	[Page writes/sec] * 8  / 1024 AS [Page writes (MB)/sec],
	[Checkpoint pages/sec] * 8 / 1024 AS [Checkpoint pages (MB)/sec], 
	[Background writer pages/sec] * 8 / 1024 AS [Background writer pages (MB)/sec],
	[Log Flushes/sec],
	[Log Bytes Flushed/sec] / POWER(1024.0,2) AS [Log MBytes Flushed/sec],
	[Log Flush Waits/sec],
	[Log Flush Wait Time],
	[SQL Compilations/sec],
	[SQL Re-Compilations/sec]
FROM(
SELECT
	counter_name,
	cntr_value
FROM 
	#Results
) AS p
PIVOT
(
SUM(cntr_value)
FOR 
	counter_name IN (
		[CPU usage %],
		[Buffer Cache Hit %],
		[Page life expectancy],
		[Plan Cache Hit %],
		[Cache Pages],
		[Total Server Memory (KB)],
		[Database Cache Memory (KB)],
		[Free Memory (KB)], 
		[Target Server Memory (KB)],
		[Granted Workspace Memory (KB)],
		[Memory Grants Outstanding],
		[Memory Grants Pending],
		[Batch Requests/sec],
		[Page lookups/sec],
		[Readahead pages/sec],
		[Page reads/sec],
		[Page writes/sec],
		[Checkpoint pages/sec], 
		[Background writer pages/sec],
		[Log Flushes/sec],
		[Log Bytes Flushed/sec],
		[Log Flush Waits/sec],
		[Log Flush Wait Time],
		[SQL Compilations/sec],
		[SQL Re-Compilations/sec],
		[avg_cpu_percent],
		[avg_data_io_percent],
		[avg_log_write_percent],
		[avg_memory_usage_percent]
	)
) AS PVT
END
GO


