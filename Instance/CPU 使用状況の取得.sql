-- https://github.com/Microsoft/azuredatastudio/tree/master/samples/serverReports
DECLARE @ts_now BIGINT = (
        SELECT cpu_ticks / (cpu_ticks / ms_ticks)
        FROM sys.dm_os_sys_info
        );

SELECT TOP (100) 
	'CPU%' AS [label]
    , DATEADD(ms, - 1 * (@ts_now - [timestamp]), GETDATE()) AS [Event Time]
    , SQLProcessUtilization AS [SQL Server Process CPU Utilization]
	, SystemIdle AS [System Idle Process] 
	, 100 - SystemIdle - SQLProcessUtilization AS [Other Process CPU Utilization]           
FROM (
    SELECT record.value('(./Record/@id)[1]', 'int') AS record_id
        , record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS [SystemIdle]
        , record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS [SQLProcessUtilization]
        , [timestamp]
    FROM (
        SELECT [timestamp]
            , convert(XML, record) AS [record]
        FROM sys.dm_os_ring_buffers
        WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
            AND record LIKE '%<SystemHealth>%'
        ) AS x
    ) AS y
--ORDER BY record_id DESC;
ORDER BY [Event Time] DESC;
GO

-- SQL Database 向け
DECLARE @ts_now BIGINT = 
    (
        SELECT TOP 1 worker_created_ms_ticks FROM sys.dm_os_workers order by worker_created_ms_ticks DESC
    )

SELECT TOP (100) 
	 'CPU%' AS [label]
    , record_id
    , CAST(DATEADD(ms, - 1 * (@ts_now - [timestamp]), GETDATE())  AS datetimeoffset) AT TIME ZONE 'Tokyo Standard Time' AS [Event Time] 
    , SQLProcessUtilization AS [SQL Server Process CPU Utilization]
	, SystemIdle AS [System Idle Process] 
	, 100 - SystemIdle - SQLProcessUtilization AS [Other Process CPU Utilization]
FROM (
    SELECT record.value('(./Record/@id)[1]', 'int') AS record_id
        , record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS [SystemIdle]
        , record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS [SQLProcessUtilization]
        , [timestamp]
    FROM (
        SELECT [timestamp]
            , convert(XML, record) AS [record]
        FROM sys.dm_os_ring_buffers
        WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
            AND record LIKE '%<SystemHealth>%'
        ) AS x
    ) AS y
--ORDER BY record_id DESC;
ORDER BY [Event Time] DESC;
