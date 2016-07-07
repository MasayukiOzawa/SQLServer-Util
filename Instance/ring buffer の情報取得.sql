-- Scheduler Info
-- https://gallery.technet.microsoft.com/how-to-find-the-cpu-4f178605
-- https://troubleshootingsql.com/2009/12/30/how-to-find-out-the-cpu-usage-information-for-the-sql-server-process-using-ring-buffers/
DECLARE @ts_now BIGINT = (SELECT ms_ticks FROM sys.dm_os_sys_info)

SELECT
record.value('(./Record/@id)[1]', 'int') AS record_id
,DATEADD(ms, -1 * (@ts_now - timestamp), GETDATE()) AS timestamp
,record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]','int') AS SystemIdle
,record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]','int') AS SQLProcessUtilization
,record.value('(./Record/SchedulerMonitorEvent/SystemHealth/UserModeTime)[1]','bigint') AS UserModeTime
,record.value('(./Record/SchedulerMonitorEvent/SystemHealth/KernelModeTime)[1]','bigint') AS KernelModeTime
FROM
(
	SELECT
	TIMESTAMP
	,CONVERT(XML, record) AS record
	FROM
	sys.dm_os_ring_buffers
	WHERE
	ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
) tbl
ORDER BY timestamp DESC;


-- Memory Info
-- https://blogs.msdn.microsoft.com/mvpawardprogram/2012/06/04/using-sys-dm_os_ring_buffers-to-diagnose-memory-issues-in-sql-server/
-- https://blogs.msdn.microsoft.com/psssql/2009/09/17/how-it-works-what-are-the-ring_buffer_resource_monitor-telling-me/

-- XML の操作
-- http://stackoverflow.com/questions/1393250/getting-multiple-records-from-xml-column-with-value-in-sql-server
-- http://stackoverflow.com/questions/23973418/select-multiple-values-in-xml-file-and-concatenation-them-with-xquery

-- 全体のメモリ使用量
WITH RingBuffer
AS (
	SELECT CAST(dorb.record AS XML) AS xRecord,
	dorb.timestamp
	FROM sys.dm_os_ring_buffers AS dorb
	WHERE dorb.ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR'
)
SELECT 
	DATEADD(ms, -1 * (dosi.ms_ticks - rb.timestamp), GETDATE()) AS RmDateTime,
	xr.value('(@id)[1]', 'varchar(75)') AS record_id,
	xr.value('(ResourceMonitor/Notification)[1]', 'varchar(75)') AS RmNotification,
	xr.value('(ResourceMonitor/IndicatorsProcess)[1]','tinyint') AS IndicatorsProcess,
	xr.value('(ResourceMonitor/IndicatorsSystem)[1]','tinyint') AS IndicatorsSystem,
	xr.value('(MemoryRecord/MemoryUtilization)[1]','bigint') AS MemoryUtilization,
	xr.value('(MemoryRecord/TotalPhysicalMemory)[1]','bigint') AS TotalPhysicalMemory,
	xr.value('(MemoryRecord/AvailablePhysicalMemory)[1]','bigint') AS AvailablePhysicalMemory,
	xr.value('(MemoryRecord/TotalPageFile)[1]','bigint') AS TotalPageFile,
	xr.value('(MemoryRecord/AvailablePageFile)[1]','bigint') AS AvailablePageFile,
	xr.value('(MemoryRecord/TotalVirtualAddressSpace)[1]','bigint') AS TotalVirtualAddressSpace,
	xr.value('(MemoryRecord/AvailableVirtualAddressSpace)[1]','bigint') AS AvailableVirtualAddressSpace,
	xr.value('(MemoryRecord/AvailableExtendedVirtualAddressSpace)[1]','bigint') AS AvailableExtendedVirtualAddressSpace
FROM 
	RingBuffer AS rb
	CROSS APPLY rb.xRecord.nodes('Record') record(xr)
	CROSS JOIN sys.dm_os_sys_info AS dosi
ORDER BY 
	RmDateTime DESC;

-- ノードごとのメモリ使用量
WITH RingBuffer
AS (
	SELECT CAST(dorb.record AS XML) AS xRecord,
	dorb.timestamp
	FROM sys.dm_os_ring_buffers AS dorb
	WHERE dorb.ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR'
)
SELECT 
	DATEADD(ms, -1 * (dosi.ms_ticks - rb.timestamp), GETDATE()) AS RmDateTime,
	xr.value('(@id)[1]', 'int') AS node_id,
	xr.value('(TargetMemory)[1]','bigint') AS TargetMemory,
	xr.value('(ReservedMemory)[1]','bigint') AS ReservedMemory,
	xr.value('(CommittedMemory)[1]','bigint') AS CommittedMemory,
	xr.value('(SharedMemory)[1]','bigint') AS SharedMemory,
	xr.value('(AWEMemory)[1]','bigint') AS AWEMemory,
	xr.value('(PagesMemory)[1]','bigint') AS PagesMemory
FROM 
	RingBuffer AS rb
	CROSS APPLY rb.xRecord.nodes('Record/MemoryNode') record(xr)
	CROSS JOIN sys.dm_os_sys_info AS dosi
ORDER BY 
	RmDateTime DESC
