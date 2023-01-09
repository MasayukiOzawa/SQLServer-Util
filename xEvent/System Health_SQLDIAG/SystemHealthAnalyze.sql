/*
DROP TABLE IF EXISTS  [system_health_yyyymmdd];

SELECT
	DATEADD(hour, 9, CAST(event_data as XML).value('(//@timestamp)[1]', 'datetime2')) AS timestamp,
	CAST(event_data as XML).value('(/event/@name)[1]', 'varchar(100)') AS name,
	CAST(event_data as XML) AS event_data
INTO  [system_health_yyyymmdd]
FROM 
	sys.fn_xe_file_target_read_file('D:\work_yyyymmdd\system_health*.xel', NULL, NULL, NULL)
ORDER BY 1
GO
*/

DECLARE @start_time datetime2(3) = '2022-01-01 00:00:00'
DECLARE @end_time  datetime2(3)  = '2023-01-01 00:00:00'

/********************************************************************************************/
-- error_reported
SELECT
	timestamp, 
	name,
	CAST(event_data as XML).value('(/event/data[@name="error_number"]/value)[1]', 'int') AS error_number,
	CAST(event_data as XML).value('(/event/data[@name="severity"]/value)[1]', 'int') AS severity,
	CAST(event_data as XML).value('(/event/data[@name="state"]/value)[1]', 'int') AS state,
	CAST(event_data as XML).value('(/event/data[@name="user_defined"]/value)[1]', 'varchar(100)') AS user_defined,
	CAST(event_data as XML).value('(/event/data[@name="category"]/text)[1]', 'varchar(100)') AS category,
	CAST(event_data as XML).value('(/event/data[@name="destination"]/text)[1]', 'varchar(100)') AS destination,
	CAST(event_data as XML).value('(/event/data[@name="is_intercepted"]/value)[1]', 'varchar(100)') AS is_intercepted,
	CAST(event_data as XML).value('(/event/data[@name="message"]/value)[1]', 'nvarchar(max)') AS is_intercepted,
	CAST(event_data as XML).value('(/event/action[@name="database_id"]/value)[1]', 'int') AS database_id,
	CAST(event_data as XML).value('(/event/action[@name="session_id"]/value)[1]', 'int') AS session_id,
	CAST(event_data as XML).value('(/event/action[@name="callstack"]/value)[1]', 'varchar(max)') AS callstack,
	event_data
FROM
	 [system_health_yyyymmdd]
WHERE
	name = 'error_reported'
	AND timestamp >= @start_time AND timestamp < @end_time
ORDER BY 
	timestamp ASC

/********************************************************************************************/
-- nonyield_copiedstack_ring_buffer_recorded
SELECT
	timestamp, 
	name,
	CAST(event_data as XML).value('(/event/data[@name="nonyield_type"]/value)[1]', 'int') AS nonyield_type,
	CAST(event_data as XML).value('(/event/data[@name="scheduler_id"]/value)[1]', 'int') AS scheduler_id,
	CAST(event_data as XML).value('(/event/data[@name="thread_id"]/value)[1]', 'int') AS thread_id,
	CAST(event_data as XML).value('(/event/data[@name="task"]/value)[1]', 'varchar(100)') AS task,
	CAST(event_data as XML).value('(/event/data[@name="worker"]/value)[1]', 'varchar(100)') AS worker,
	CAST(event_data as XML).value('(/event/data[@name="session_id"]/value)[1]', 'varchar(100)') AS session_id,
	CAST(event_data as XML).value('(/event/data[@name="request_id"]/value)[1]', 'varchar(100)') AS request_id,
	CAST(event_data as XML).value('(/event/data[@name="stack_frames"]/value)[1]', 'varchar(100)') AS stack_frames,
	CAST(event_data as XML).value('(/event/data[@name="call_stack"]/value)[1]', 'varchar(max)') AS call_stack,
	event_data
FROM
	 [system_health_yyyymmdd]
WHERE
	name = 'nonyield_copiedstack_ring_buffer_recorded'
	AND timestamp >= @start_time AND timestamp < @end_time
ORDER BY 
	timestamp ASC

/********************************************************************************************/
-- scheduler_monitor_non_yielding_ring_buffer_recorded
SELECT
	timestamp, name, id, opcode, node_id, scheduler, worker, yields, worker_utilization, process_utilization, system_idle, user_mode_time, kernel_mode_time, 
	CASE
		WHEN opcode = 'Begin' THEN 
			LEAD(kernel_mode_time, 1, NULL) OVER (ORDER BY worker ASC, timestamp, node_id, scheduler, opcode) - kernel_mode_time
		ELSE NULL
	END AS kernel_time_usage,
	CASE
		WHEN opcode = 'Begin' THEN 
			LEAD(yields, 1, NULL) OVER (ORDER BY worker ASC, timestamp, node_id, scheduler, opcode) - yields
		ELSE NULL
	END AS yield_occurrence,
	CASE
		WHEN opcode = 'Begin' THEN 
			datediff(ss, timestamp, LEAD(timestamp, 1, NULL) OVER(ORDER BY worker ASC, timestamp, node_id, scheduler, opcode))
		ELSE NULL
	END AS duration_sec,
	page_faults, working_set_delta, memory_utilization, call_stack, event_data
FROM
(
SELECT
	timestamp, 
	name,
	CAST(event_data as XML).value('(/event/data[@name="id"]/value)[1]', 'int') AS id,
	CAST(event_data as XML).value('(/event/data[@name="opcode"]/text)[1]', 'varchar(100)') AS opcode,
	CAST(event_data as XML).value('(/event/data[@name="node_id"]/value)[1]', 'int') AS node_id,
	CAST(event_data as XML).value('(/event/data[@name="scheduler"]/value)[1]', 'int') AS scheduler,
	CAST(event_data as XML).value('(/event/data[@name="worker"]/value)[1]', 'varchar(100)') AS worker,
	CAST(event_data as XML).value('(/event/data[@name="yields"]/value)[1]', 'int') AS yields,
	CAST(event_data as XML).value('(/event/data[@name="worker_utilization"]/value)[1]', 'int') AS worker_utilization,
	CAST(event_data as XML).value('(/event/data[@name="process_utilization"]/value)[1]', 'int') AS process_utilization,
	CAST(event_data as XML).value('(/event/data[@name="system_idle"]/value)[1]', 'int') AS system_idle,
	CAST(event_data as XML).value('(/event/data[@name="user_mode_time"]/value)[1]', 'int') AS user_mode_time,
	CAST(event_data as XML).value('(/event/data[@name="kernel_mode_time"]/value)[1]', 'int') AS kernel_mode_time,
	CAST(event_data as XML).value('(/event/data[@name="page_faults"]/value)[1]', 'int') AS page_faults,
	CAST(event_data as XML).value('(/event/data[@name="working_set_delta"]/value)[1]', 'int') AS working_set_delta,
	CAST(event_data as XML).value('(/event/data[@name="memory_utilization"]/value)[1]', 'int') AS memory_utilization,
	CAST(event_data as XML).value('(/event/data[@name="call_stack"]/value)[1]', 'varchar(max)') AS call_stack,
	event_data
FROM
	 [system_health_yyyymmdd]
WHERE
	name = 'scheduler_monitor_non_yielding_ring_buffer_recorded'
	AND timestamp >= @start_time AND timestamp < @end_time
) AS T
ORDER BY 
	--worker ASC, timestamp, node_id, scheduler, opcode
	timestamp

/********************************************************************************************/
-- wait_info
SELECT
	timestamp, 
	name,
	CAST(event_data as XML).value('(/event/data[@name="wait_type"]/text)[1]', 'varchar(100)') AS wait_type,
	CAST(event_data as XML).value('(/event/data[@name="opcode"]/text)[1]', 'varchar(100)') AS opcode,
	CAST(event_data as XML).value('(/event/data[@name="duration"]/value)[1]', 'int') AS duration,
	CAST(event_data as XML).value('(/event/data[@name="signal_duration"]/value)[1]', 'int') AS signal_duration,
	CAST(event_data as XML).value('(/event/data[@name="wait_resource"]/value)[1]', 'varchar(100)') AS wait_resource,
	CAST(event_data as XML).value('(/event/action[@name="sql_text"]/value)[1]', 'varchar(100)') AS sql_text,
	CAST(event_data as XML).value('(/event/action[@name="session_id"]/value)[1]', 'int') AS session_id,
	CAST(event_data as XML).value('(/event/action[@name="callstack"]/value)[1]', 'varchar(max)') AS callstack,
	HASHBYTES('SHA', CAST(event_data as XML).value('(/event/action[@name="callstack"]/value)[1]', 'varchar(max)')) AS callstack_hash,
	event_data
FROM
	 [system_health_yyyymmdd]
WHERE
	name IN('wait_info', 'wait_info_external')
	AND timestamp >= @start_time AND timestamp < @end_time
ORDER BY
	--timestamp ASC
	wait_type, callstack_hash, timestamp

/********************************************************************************************/
-- sp_server_diagnostics_component_result
-- component: SYSTEM
SELECT 
	timestamp,
	name,
	CAST(event_data as XML).value('(/event/data[@name="component"]/text)[1]', 'varchar(100)') AS component,
	CAST(event_data as XML).value('(/event/data[@name="state"]/text)[1]', 'varchar(100)') AS state,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/system/@spinlockBackoffs)[1]', 'int') AS spinlockBackoffs,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/system/@latchWarnings)[1]', 'int') AS latchWarnings,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/system/@isAccessViolationOccurred)[1]', 'int') AS isAccessViolationOccurred,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/system/@writeAccessViolationCount)[1]', 'int') AS writeAccessViolationCount,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/system/@totalDumpRequests)[1]', 'int') AS totalDumpRequests,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/system/@intervalDumpRequests)[1]', 'int') AS intervalDumpRequests,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/system/@nonYieldingTasksReported)[1]', 'int') AS nonYieldingTasksReported,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/system/@pageFaults)[1]', 'int') AS pageFaults,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/system/@systemCpuUtilization)[1]', 'int') AS systemCpuUtilization,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/system/@sqlCpuUtilization)[1]', 'int') AS sqlCpuUtilization,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/system/@BadPagesDetected)[1]', 'int') AS BadPagesDetected,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/system/@BadPagesFixed)[1]', 'int') AS BadPagesFixed,
	event_data
FROM 
	 [system_health_yyyymmdd]
WHERE
	name = 'sp_server_diagnostics_component_result'
	AND CAST(event_data as XML).value('(/event/data/text)[1]', 'varchar(100)') = 'SYSTEM'
	AND timestamp >= @start_time AND timestamp < @end_time
ORDER BY 
	timestamp ASC


-- component: IO_SUBSYSTEM
SELECT 
	timestamp,
	name,
	CAST(event_data as XML).value('(/event/data[@name="component"]/text)[1]', 'varchar(100)') AS component,
	CAST(event_data as XML).value('(/event/data[@name="state"]/text)[1]', 'varchar(100)') AS state,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/ioSubsystem/@ioLatchTimeouts)[1]', 'int') AS ioLatchTimeouts,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/ioSubsystem/@intervalLongIos)[1]', 'int') AS intervalLongIos,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/ioSubsystem/@totalLongIos)[1]', 'int') AS totalLongIos,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/ioSubsystem/longestPendingRequests)[1]', 'varchar(max)') AS longestPendingRequests,
	event_data
FROM 
	 [system_health_yyyymmdd]
WHERE
	name = 'sp_server_diagnostics_component_result'
	AND	CAST(event_data as XML).value('(/event/data/text)[1]', 'varchar(100)') = 'IO_SUBSYSTEM'
	AND timestamp >= @start_time AND timestamp < @end_time
ORDER BY 
	timestamp ASC

-- component: QUERY_PROCESSING
SELECT 
	timestamp,
	name,
	CAST(event_data as XML).value('(/event/data[@name="component"]/text)[1]', 'varchar(100)') AS component,
	CAST(event_data as XML).value('(/event/data[@name="state"]/text)[1]', 'varchar(100)') AS state,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/queryProcessing/@maxWorkers)[1]', 'int') AS maxWorkers,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/queryProcessing/@workersCreated)[1]', 'int') AS workersCreated,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/queryProcessing/@workersIdle)[1]', 'int') AS workersIdle,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/queryProcessing/@tasksCompletedWithinInterval)[1]', 'int') AS tasksCompletedWithinInterval,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/queryProcessing/@pendingTasks)[1]', 'int') AS pendingTasks,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/queryProcessing/@oldestPendingTaskWaitingTime)[1]', 'int') AS oldestPendingTaskWaitingTime,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/queryProcessing/@hasUnresolvableDeadlockOccurred)[1]', 'int') AS hasUnresolvableDeadlockOccurred,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/queryProcessing/@hasDeadlockedSchedulersOccurred)[1]', 'int') AS hasDeadlockedSchedulersOccurred,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/queryProcessing/@trackingNonYieldingScheduler)[1]', 'varchar(10)') AS trackingNonYieldingScheduler,
	event_data
FROM 
	 [system_health_yyyymmdd]
WHERE
	name = 'sp_server_diagnostics_component_result'
	AND	CAST(event_data as XML).value('(/event/data/text)[1]', 'varchar(100)') = 'QUERY_PROCESSING'
	AND timestamp >= @start_time AND timestamp < @end_time
ORDER BY 
	timestamp ASC

-- component: RESOURCE
SELECT 
	timestamp,
	name,
	CAST(event_data as XML).value('(/event/data[@name="component"]/text)[1]', 'varchar(100)') AS component,
	CAST(event_data as XML).value('(/event/data[@name="state"]/text)[1]', 'varchar(100)') AS state,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/@lastNotification)[1]', 'varchar(100)') AS [lastNotification],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="Available Physical Memory"]/@value)[1]', 'bigint') / POWER(1024, 2) AS [Available Physical Memory (MB)],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="Available Virtual Memory"]/@value)[1]', 'bigint') / POWER(1024, 2) AS [Available Virtual Memory (MB)],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="Available Paging File"]/@value)[1]', 'bigint') / POWER(1024, 2) AS [Available Paging File (MB)],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="Working Set"]/@value)[1]', 'bigint') / POWER(1024, 2) AS [Working Set (MB)],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="Percent of Committed Memory in WS"]/@value)[1]', 'bigint') / POWER(1024, 2) AS [Percent of Committed Memory in WS (MB)],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="Page Faults"]/@value)[1]', 'bigint') / POWER(1024, 2) AS [Page Faults (MB)],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="System physical memory high"]/@value)[1]', 'bigint') AS [System physical memory high],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="System physical memory low"]/@value)[1]', 'bigint') AS [System physical memory low],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="Process physical memory low"]/@value)[1]', 'bigint') AS [Process physical memory low],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="Process virtual memory low"]/@value)[1]', 'bigint') AS [Process virtual memory low],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="VM Reserved"]/@value)[1]', 'bigint') / POWER(1024, 1) AS [VM Reserved],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="VM Committed"]/@value)[1]', 'bigint') / POWER(1024, 1) AS [VM Committed],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="Locked Pages Allocated"]/@value)[1]', 'bigint') / POWER(1024, 1) AS [Locked Pages Allocated],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="Large Pages Allocated"]/@value)[1]', 'bigint') / POWER(1024, 1) AS [Large Pages Allocated],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="Emergency Memory"]/@value)[1]', 'bigint') AS [Emergency Memory],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="Emergency Memory In Use"]/@value)[1]', 'bigint') AS [Emergency Memory In Use],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="Target Committed"]/@value)[1]', 'bigint') / POWER(1024, 1) AS [Target Committed],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="Current Committed"]/@value)[1]', 'bigint') / POWER(1024, 1) AS [Current Committed],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="Pages Allocated"]/@value)[1]', 'bigint') / POWER(1024, 1) AS [Pages Allocated],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="Pages Reserved"]/@value)[1]', 'bigint') / POWER(1024, 1) AS [Pages Reserved],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="Pages Free"]/@value)[1]', 'bigint') / POWER(1024, 1) AS [Pages Free],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="Pages In Use"]/@value)[1]', 'bigint') / POWER(1024, 1) AS [Pages In Use],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="Page Alloc Potential"]/@value)[1]', 'bigint') / POWER(1024, 1) AS [Page Alloc Potential],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="NUMA Growth Phase"]/@value)[1]', 'bigint') AS [NUMA Growth Phase],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="Last OOM Factor"]/@value)[1]', 'bigint') AS [Last OOM Factor],
	CAST(event_data as XML).value('(/event/data[@name="data"]/value/resource/memoryReport/entry[@description="Last OS Error"]/@value)[1]', 'bigint') AS [Last OS Error],
	event_data
FROM 
	 [system_health_yyyymmdd]
WHERE
	name = 'sp_server_diagnostics_component_result'
	AND	CAST(event_data as XML).value('(/event/data/text)[1]', 'varchar(100)') = 'RESOURCE'
	AND timestamp >= @start_time AND timestamp < @end_time
ORDER BY 
	timestamp ASC

/********************************************************************************************/
-- scheduler_monitor_system_health_ring_buffer_recorded
SELECT
	timestamp, 
	name,
	CAST(event_data as XML).value('(/event/data[@name="id"]/value)[1]', 'int') AS id,
	CAST(event_data as XML).value('(/event/data[@name="process_utilization"]/value)[1]', 'int') AS process_utilization,
	CAST(event_data as XML).value('(/event/data[@name="system_idle"]/value)[1]', 'int') AS system_idle,
	CAST(event_data as XML).value('(/event/data[@name="user_mode_time"]/value)[1]', 'bigint') AS user_mode_time,
	CAST(event_data as XML).value('(/event/data[@name="kernel_mode_time"]/value)[1]', 'bigint') AS kernel_mode_time,
	CAST(event_data as XML).value('(/event/data[@name="user_mode_time"]/value)[1]', 'bigint') +
	CAST(event_data as XML).value('(/event/data[@name="kernel_mode_time"]/value)[1]', 'bigint') AS processor_time,
	CAST(event_data as XML).value('(/event/data[@name="page_faults"]/value)[1]', 'bigint') AS page_faults,
	CAST(event_data as XML).value('(/event/data[@name="working_set_delta"]/value)[1]', 'bigint') AS working_set_delta,
	CAST(event_data as XML).value('(/event/data[@name="memory_utilization"]/value)[1]', 'bigint') AS memory_utilization,
	CAST(event_data as XML).value('(/event/data[@name="call_stack"]/value)[1]', 'varchar(max)') AS call_stack,
	event_data
FROM
	 [system_health_yyyymmdd]
WHERE
	name = 'scheduler_monitor_system_health_ring_buffer_recorded'
	AND timestamp >= @start_time AND timestamp < @end_time
ORDER BY 
	timestamp ASC