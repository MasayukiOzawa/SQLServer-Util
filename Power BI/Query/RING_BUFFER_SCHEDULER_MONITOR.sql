-- https://github.com/Microsoft/azuredatastudio/tree/master/samples/serverReports
SELECT TOP (100) 
	'CPU%' AS [label]
    , [timestamp] AS [Event Time]
    , SQLProcessUtilization AS [SQL Server Process CPU Utilization]
	, SystemIdle AS [System Idle Process] 
	, 100 - SystemIdle - SQLProcessUtilization AS [Other Process CPU Utilization]
	, [MemoryUtilization]
FROM (
    SELECT record.value('(./Record/@id)[1]', 'int') AS record_id
        , record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS [SystemIdle]
        , record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS [SQLProcessUtilization]
		, record.value('(./Record/SchedulerMonitorEvent/SystemHealth/MemoryUtilization)[1]', 'int') AS [MemoryUtilization]
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
