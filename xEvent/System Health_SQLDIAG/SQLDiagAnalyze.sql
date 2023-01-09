/*
DROP TABLE IF EXISTS [sqldiag_yyyymmdd];

SELECT
	DATEADD(hour, 9, CAST(event_data as XML).value('(//@timestamp)[1]', 'datetime2')) AS timestamp,
	CAST(event_data as XML).value('(/event/@name)[1]', 'varchar(100)') AS name,
	CAST(event_data as XML) AS event_data
INTO [sqldiag_yyyymmdd]
FROM 
	sys.fn_xe_file_target_read_file('D:\work_yyyymmdd\*MSSQLSERVER_SQLDIAG*.xel', NULL, NULL, NULL)
ORDER BY 1
GO


SELECT
	T2_name,
	COUNT(*)
FROM(
	SELECT
	T.*,
	T2.node.value('(self::event/@name)[1]', 'varchar(100)') AS T2_name
	FROM
	(
		SELECT
			timestamp, 
			name,
			CAST(event_data as XML).value('(/event/data[@name="node_name"]/value)[1]', 'varchar(100)') AS node_name,
			CAST(event_data as XML).value('(/event/data[@name="instance_name"]/value)[1]', 'varchar(100)') AS instance_name,
			CAST(event_data as XML).value('(/event/data[@name="state"]/value)[1]', 'int') AS state,
			CAST(event_data as XML).value('(/event/data[@name="failure_condition_level"]/value)[1]', 'int') AS failure_condition_level,
			CAST(event_data as XML).value('(/event/data[@name="component_type"]/value)[1]', 'varchar(100)') AS component_type,
			CAST(event_data as XML).value('(/event/data[@name="state_desc"]/value)[1]', 'varchar(100)') AS state_desc,
			CAST(event_data as XML).query('(/event/data[@name="data"])') AS data,
			event_data
		FROM
			[sqldiag_yyyymmdd]
		WHERE
			name = 'component_health_result'
			AND CAST(event_data as XML).value('(/event/data[@name="state_desc"]/value)[1]', 'varchar(100)') = 'unknown'
	) AS T
	CROSS APPLY T.data.nodes('//event') AS T2(node)
) AS T3
GROUP BY 
	T2_name
*/

DECLARE @start_time datetime2(3) = '2022-01-01 00:00:00'
DECLARE @end_time  datetime2(3)  = '2023-01-01 00:00:00'

/*****************************************************************************************************************/
-- info_message
SELECT
	timestamp, 
	name,
	CAST(event_data as XML).value('(/event/data[@name="node_name"]/value)[1]', 'varchar(100)') AS node_name,
	CAST(event_data as XML).value('(/event/data[@name="instance_name"]/value)[1]', 'varchar(100)') AS instance_name,
	CAST(event_data as XML).value('(/event/data[@name="data"]/value)[1]', 'varchar(max)') AS data,
	event_data
FROM
	[sqldiag_yyyymmdd]
WHERE
	name = 'info_message'
	AND timestamp >= @start_time AND timestamp < @end_time
ORDER BY 
	timestamp ASC
/*****************************************************************************************************************/
-- component_health_result (warning)
SELECT
	timestamp, 
	name,
	CAST(event_data as XML).value('(/event/data[@name="node_name"]/value)[1]', 'varchar(100)') AS node_name,
	CAST(event_data as XML).value('(/event/data[@name="instance_name"]/value)[1]', 'varchar(100)') AS instance_name,
	CAST(event_data as XML).value('(/event/data[@name="state"]/value)[1]', 'int') AS state,
	CAST(event_data as XML).value('(/event/data[@name="failure_condition_level"]/value)[1]', 'int') AS failure_condition_level,
	CAST(event_data as XML).value('(/event/data[@name="component_type"]/value)[1]', 'varchar(100)') AS component_type,
	CAST(event_data as XML).value('(/event/data[@name="state_desc"]/value)[1]', 'varchar(100)') AS state_desc,
	CAST(event_data as XML).query('(/event/data[@name="data"])') AS data,
	event_data
FROM
	[sqldiag_yyyymmdd]
WHERE
	name = 'component_health_result'
	AND timestamp >= @start_time AND timestamp < @end_time
	AND CAST(event_data as XML).value('(/event/data[@name="state_desc"]/value)[1]', 'varchar(100)') = 'warning'
ORDER BY 
	timestamp ASC


/*****************************************************************************************************************/
-- component_health_result (unknown)
-- memory_broker_ring_buffer_recorded)
SELECT
	T.timestamp,
	T.name,
	T.node_name,
	T.state,
	T.failure_condition_level,
	T.component_type,
	T.state_desc,
	T2.node.value('(self::event/@name)[1]', 'varchar(100)') AS node_event_name,
	T2.node.value('(self::event/@timestamp)[1]', 'datetime2(3)') AS node_timestamp,
	T2.node.value('(self::event/data[@name="broker"])[1]', 'varchar(100)') AS node_broker,
	T2.node.value('(self::event/data[@name="notification"])[1]', 'varchar(100)') AS node_notification,
	T2.node.value('(self::event/data[@name="delta_time"])[1]', 'int') AS node_delta_time,
	T2.node.value('(self::event/data[@name="memory_ratio"])[1]', 'bigint') AS node_memory_ratio,
	T2.node.value('(self::event/data[@name="new_target"])[1]', 'bigint') AS node_new_target,
	T2.node.value('(self::event/data[@name="overall"])[1]', 'int') AS node_overall,
	T2.node.value('(self::event/data[@name="rate"])[1]', 'bigint') AS node_rate,
	T2.node.value('(self::event/data[@name="currently_predicated"])[1]', 'bigint') AS node_currently_predicated,
	T2.node.value('(self::event/data[@name="currently_allocated"])[1]', 'bigint') AS node_currently_predicated,
	T2.node.value('(self::event/data[@name="previously_allocated"])[1]', 'bigint') AS node_previously_allocated,
	T2.node.query('.') AS node
FROM
(
	SELECT
		timestamp, 
		name,
		CAST(event_data as XML).value('(/event/data[@name="node_name"]/value)[1]', 'varchar(100)') AS node_name,
		CAST(event_data as XML).value('(/event/data[@name="instance_name"]/value)[1]', 'varchar(100)') AS instance_name,
		CAST(event_data as XML).value('(/event/data[@name="state"]/value)[1]', 'int') AS state,
		CAST(event_data as XML).value('(/event/data[@name="failure_condition_level"]/value)[1]', 'int') AS failure_condition_level,
		CAST(event_data as XML).value('(/event/data[@name="component_type"]/value)[1]', 'varchar(100)') AS component_type,
		CAST(event_data as XML).value('(/event/data[@name="state_desc"]/value)[1]', 'varchar(100)') AS state_desc,
		CAST(event_data as XML).query('(/event/data[@name="data"])') AS data,
		event_data
	FROM
		[sqldiag_yyyymmdd]
	WHERE
		name = 'component_health_result'
		AND timestamp >= @start_time AND timestamp < @end_time
		AND CAST(event_data as XML).value('(/event/data[@name="state_desc"]/value)[1]', 'varchar(100)') = 'unknown'
) AS T
	CROSS APPLY data.nodes('//event[@name="memory_broker_ring_buffer_recorded"]') AS T2(node)
ORDER BY 
	timestamp ASC

-- component_health_result (unknown)
-- resource_monitor_ring_buffer_recorded
SELECT
	T.timestamp,
	T.name,
	T.node_name,
	T.state,
	T.failure_condition_level,
	T.component_type,
	T.state_desc,
	T2.node.value('(self::event/@name)[1]', 'varchar(100)') AS node_event_name,
	T2.node.value('(self::event/@timestamp)[1]', 'datetime2(3)') AS node_timestamp,
	T2.node.value('(self::event/data[@name="memory_utilization_pct"])[1]', 'int') AS node_memory_utilization_pct,
	T2.node.value('(self::event/data[@name="total_physical_memory_kb"])[1]', 'bigint') / 1024 AS node_total_physical_memory_mb,
	T2.node.value('(self::event/data[@name="available_physical_memory_kb"])[1]', 'bigint') / 1024 AS node_available_physical_memory_mb,
	T2.node.value('(self::event/data[@name="total_page_file_kb"])[1]', 'bigint') / 1024 AS node_total_page_file_mb,
	T2.node.value('(self::event/data[@name="available_page_file_kb"])[1]', 'bigint') / 1024 AS node_available_page_file_mb,
	T2.node.value('(self::event/data[@name="total_virtual_address_space_kb"])[1]', 'bigint') / 1024 AS node_total_virtual_address_space_mb,
	T2.node.value('(self::event/data[@name="available_virtual_address_space_kb"])[1]', 'bigint') / 1024 AS node_available_virtual_address_space_mb,
	T2.node.value('(self::event/data[@name="available_extended_virtual_address_space_kb"])[1]', 'bigint') / 1024 AS node_available_extended_virtual_address_space_mb,
	T2.node.value('(self::event/data[@name="memory_node_id"])[1]', 'int') AS node_memory_node_id,
	T2.node.value('(self::event/data[@name="target_kb"])[1]', 'bigint') / 1024 AS node_target_mb,
	T2.node.value('(self::event/data[@name="reserved_kb"])[1]', 'bigint') / 1024 AS node_reserved_mb,
	T2.node.value('(self::event/data[@name="committed_kb"])[1]', 'bigint') / 1024 AS node_committed_mb,
	T2.node.value('(self::event/data[@name="shared_committed_kb"])[1]', 'bigint') / 1024 AS node_shared_committed_mb,
	T2.node.value('(self::event/data[@name="awe_kb"])[1]', 'bigint') / 1024 AS node_awe_mb,
	T2.node.value('(self::event/data[@name="pages_kb"])[1]', 'bigint') / 1024 AS node_pages_mb,
	T2.node.value('(self::event/data[@name="notification"]/text)[1]', 'varchar(100)') AS node_notification,
	T2.node.value('(self::event/data[@name="process_indicators"])[1]', 'int') AS node_process_indicators,
	T2.node.value('(self::event/data[@name="system_indicators"])[1]', 'int') AS node_system_indicators,
	T2.node.value('(self::event/data[@name="pool_indicators"])[1]', 'int') AS node_pool_indicators,
	T2.node.value('(self::event/data[@name="node_id"])[1]', 'int') AS node_node_id,
	T2.node.value('(self::event/data[@name="apply_low_pm"]/text)[1]', 'varchar(100)') AS node_apply_low_pm,
	T2.node.value('(self::event/data[@name="apply_high_pm"]/text)[1]', 'varchar(100)') AS node_apply_high_pm,
	T2.node.value('(self::event/data[@name="revert_high_pm"]/text)[1]', 'varchar(100)') AS node_revert_high_pm,
	T2.node.value('(self::event/data[@name="job_object_limit_job_mem_kb"])[1]', 'bigint') / 1024 AS node_job_object_limit_job_mem_mb,
	T2.node.value('(self::event/data[@name="job_object_limit_process_mem_kb"])[1]', 'bigint') / 1024 AS node_job_object_limit_process_mem_mb,
	T2.node.value('(self::event/data[@name="peak_job_memory_used_kb"])[1]', 'bigint') / 1024 AS node_peak_job_memory_used_mb,
	T2.node.value('(self::event/data[@name="peak_process_memory_used_kb"])[1]', 'bigint') / 1024 AS node_peak_process_memory_used_mb,
	T2.node.value('(self::event/data[@name="is_system_physical_memory_high"])[1]', 'varchar(10)') AS node_is_system_physical_memory_high,
	T2.node.value('(self::event/data[@name="is_system_physical_memory_low"])[1]', 'varchar(10)') AS node_is_system_physical_memory_low,
	T2.node.value('(self::event/data[@name="is_process_physical_memory_low"])[1]', 'varchar(10)') AS node_is_process_physical_memory_low,
	T2.node.value('(self::event/data[@name="is_process_virtual_memory_low"])[1]', 'varchar(10)') AS node_is_process_virtual_memory_low,
	T2.node.query('.') AS node
FROM
(
	SELECT
		timestamp, 
		name,
		CAST(event_data as XML).value('(/event/data[@name="node_name"]/value)[1]', 'varchar(100)') AS node_name,
		CAST(event_data as XML).value('(/event/data[@name="instance_name"]/value)[1]', 'varchar(100)') AS instance_name,
		CAST(event_data as XML).value('(/event/data[@name="state"]/value)[1]', 'int') AS state,
		CAST(event_data as XML).value('(/event/data[@name="failure_condition_level"]/value)[1]', 'int') AS failure_condition_level,
		CAST(event_data as XML).value('(/event/data[@name="component_type"]/value)[1]', 'varchar(100)') AS component_type,
		CAST(event_data as XML).value('(/event/data[@name="state_desc"]/value)[1]', 'varchar(100)') AS state_desc,
		CAST(event_data as XML).query('(/event/data[@name="data"])') AS data,
		event_data
	FROM
		[sqldiag_yyyymmdd]
	WHERE
		name = 'component_health_result'
		AND timestamp >= @start_time AND timestamp < @end_time
		AND CAST(event_data as XML).value('(/event/data[@name="state_desc"]/value)[1]', 'varchar(100)') = 'unknown'
) AS T
	CROSS APPLY data.nodes('//event[@name="resource_monitor_ring_buffer_recorded"]') AS T2(node)
ORDER BY 
	timestamp ASC,node_timestamp, node_memory_node_id


-- component_health_result (unknown)
-- error_reported
SELECT
	T.timestamp,
	T.name,
	T.node_name,
	T.state,
	T.failure_condition_level,
	T.component_type,
	T.state_desc,
	T2.node.value('(self::event/@name)[1]', 'varchar(100)') AS node_event_name,
	T2.node.value('(self::event/@timestamp)[1]', 'datetime2(3)') AS node_timestamp,
	T2.node.value('(self::event/data[@name="error_number"])[1]', 'int') AS node_error_number,
	T2.node.value('(self::event/data[@name="severity"])[1]', 'int') AS node_error_severity,
	T2.node.value('(self::event/data[@name="state"])[1]', 'int') AS node_state,
	T2.node.value('(self::event/data[@name="user_defined"])[1]', 'varchar(10)') AS node_state,
	T2.node.value('(self::event/data[@name="category"]/text)[1]', 'varchar(10)') AS node_category,
	T2.node.value('(self::event/data[@name="destination"]/text)[1]', 'varchar(100)') AS node_destination,
	T2.node.value('(self::event/data[@name="is_intercepted"])[1]', 'varchar(10)') AS node_is_intercepted,
	T2.node.value('(self::event/data[@name="message"])[1]', 'nvarchar(max)') AS node_message,
	T2.node.value('(self::event/data[@name="state"])[1]', 'int') AS node_state,
	T2.node.query('.') AS node
FROM
(
	SELECT
		timestamp, 
		name,
		CAST(event_data as XML).value('(/event/data[@name="node_name"]/value)[1]', 'varchar(100)') AS node_name,
		CAST(event_data as XML).value('(/event/data[@name="instance_name"]/value)[1]', 'varchar(100)') AS instance_name,
		CAST(event_data as XML).value('(/event/data[@name="state"]/value)[1]', 'int') AS state,
		CAST(event_data as XML).value('(/event/data[@name="failure_condition_level"]/value)[1]', 'int') AS failure_condition_level,
		CAST(event_data as XML).value('(/event/data[@name="component_type"]/value)[1]', 'varchar(100)') AS component_type,
		CAST(event_data as XML).value('(/event/data[@name="state_desc"]/value)[1]', 'varchar(100)') AS state_desc,
		CAST(event_data as XML).query('(/event/data[@name="data"])') AS data,
		event_data
	FROM
		[sqldiag_yyyymmdd]
	WHERE
		name = 'component_health_result'
		AND CAST(event_data as XML).value('(/event/data[@name="state_desc"]/value)[1]', 'varchar(100)') = 'unknown'
		AND timestamp >= @start_time AND timestamp < @end_time
) AS T
	CROSS APPLY data.nodes('//event[@name="error_reported"]') AS T2(node)
ORDER BY 
	timestamp ASC

-- component_health_result (unknown)
-- scheduler_monitor_system_health_ring_buffer_recorded
SELECT
	T.timestamp,
	T.name,
	T.node_name,
	T.state,
	T.failure_condition_level,
	T.component_type,
	T.state_desc,
	T2.node.value('(self::event/@name)[1]', 'varchar(100)') AS node_event_name,
	T2.node.value('(self::event/@timestamp)[1]', 'datetime2(3)') AS node_timestamp,
	T2.node.value('(self::event/data[@name="process_utilization"])[1]', 'int') AS node_process_utilization,
	T2.node.value('(self::event/data[@name="system_idle"])[1]', 'int') AS node_system_idle,
	T2.node.value('(self::event/data[@name="user_mode_time"])[1]', 'bigint') AS node_user_mode_time,
	T2.node.value('(self::event/data[@name="kernel_mode_time"])[1]', 'bigint') AS node_kernel_mode_time,
	T2.node.value('(self::event/data[@name="page_faults"])[1]', 'int') AS node_page_faults,
	T2.node.value('(self::event/data[@name="working_set_delta"])[1]', 'bigint') AS node_working_set_delta,
	T2.node.value('(self::event/data[@name="memory_utilization"])[1]', 'int') AS node_memory_utilization,
	T2.node.query('.') AS node
FROM
(
	SELECT
		timestamp, 
		name,
		CAST(event_data as XML).value('(/event/data[@name="node_name"]/value)[1]', 'varchar(100)') AS node_name,
		CAST(event_data as XML).value('(/event/data[@name="instance_name"]/value)[1]', 'varchar(100)') AS instance_name,
		CAST(event_data as XML).value('(/event/data[@name="state"]/value)[1]', 'int') AS state,
		CAST(event_data as XML).value('(/event/data[@name="failure_condition_level"]/value)[1]', 'int') AS failure_condition_level,
		CAST(event_data as XML).value('(/event/data[@name="component_type"]/value)[1]', 'varchar(100)') AS component_type,
		CAST(event_data as XML).value('(/event/data[@name="state_desc"]/value)[1]', 'varchar(100)') AS state_desc,
		CAST(event_data as XML).query('(/event/data[@name="data"])') AS data,
		event_data
	FROM
		[sqldiag_yyyymmdd]
	WHERE
		name = 'component_health_result'
		AND CAST(event_data as XML).value('(/event/data[@name="state_desc"]/value)[1]', 'varchar(100)') = 'unknown'
		AND timestamp >= @start_time AND timestamp < @end_time
) AS T
	CROSS APPLY data.nodes('//event[@name="scheduler_monitor_system_health_ring_buffer_recorded"]') AS T2(node)
ORDER BY 
	timestamp ASC

-- component_health_result (unknown)
-- scheduler_monitor_system_health_ring_buffer_recorded
SELECT
	T.timestamp,
	T.name,
	T.node_name,
	T.state,
	T.failure_condition_level,
	T.component_type,
	T.state_desc,
	T2.node.value('(self::event/@name)[1]', 'varchar(100)') AS node_event_name,
	T2.node.value('(self::event/@timestamp)[1]', 'datetime2(3)') AS node_timestamp,
	T2.node.value('(self::event/data[@name="opcode"]/text)[1]', 'varchar(10)') AS node_opcode,
	T2.node.value('(self::event/data[@name="node_id"])[1]', 'smallint') AS node_node_id,
	T2.node.value('(self::event/data[@name="scheduler"])[1]', 'int') AS node_scheduler,
	T2.node.value('(self::event/data[@name="worker"])[1]', 'varchar(100)') AS node_worker,
	T2.node.value('(self::event/data[@name="yields"])[1]', 'bigint') AS node_yields,
	T2.node.value('(self::event/data[@name="worker_utilization"])[1]', 'int') AS node_worker_utilization,
	T2.node.value('(self::event/data[@name="process_utilization"])[1]', 'int') AS node_process_utilization,
	T2.node.value('(self::event/data[@name="system_idle"])[1]', 'int') AS node_system_idle,
	T2.node.value('(self::event/data[@name="user_mode_time"])[1]', 'bigint') AS node_user_mode_time,
	T2.node.value('(self::event/data[@name="kernel_mode_time"])[1]', 'bigint') AS node_kernel_mode_time,
	T2.node.value('(self::event/data[@name="page_faults"])[1]', 'int') AS node_page_faults,
	T2.node.value('(self::event/data[@name="working_set_delta"])[1]', 'bigint') AS node_working_set_delta,
	T2.node.value('(self::event/data[@name="memory_utilization"])[1]', 'int') AS node_memory_utilization,
	T2.node.query('.') AS node
FROM
(
	SELECT
		timestamp, 
		name,
		CAST(event_data as XML).value('(/event/data[@name="node_name"]/value)[1]', 'varchar(100)') AS node_name,
		CAST(event_data as XML).value('(/event/data[@name="instance_name"]/value)[1]', 'varchar(100)') AS instance_name,
		CAST(event_data as XML).value('(/event/data[@name="state"]/value)[1]', 'int') AS state,
		CAST(event_data as XML).value('(/event/data[@name="failure_condition_level"]/value)[1]', 'int') AS failure_condition_level,
		CAST(event_data as XML).value('(/event/data[@name="component_type"]/value)[1]', 'varchar(100)') AS component_type,
		CAST(event_data as XML).value('(/event/data[@name="state_desc"]/value)[1]', 'varchar(100)') AS state_desc,
		CAST(event_data as XML).query('(/event/data[@name="data"])') AS data,
		event_data
	FROM
		[sqldiag_yyyymmdd]
	WHERE
		name = 'component_health_result'
		AND CAST(event_data as XML).value('(/event/data[@name="state_desc"]/value)[1]', 'varchar(100)') = 'unknown'
		AND timestamp >= @start_time AND timestamp < @end_time
) AS T
	CROSS APPLY data.nodes('//event[@name="scheduler_monitor_non_yielding_ring_buffer_recorded"]') AS T2(node)
ORDER BY 
	timestamp ASC

-- component_health_result (unknown)
-- spinlock_backoff_warning
SELECT
	T.timestamp,
	T.name,
	T.node_name,
	T.state,
	T.failure_condition_level,
	T.component_type,
	T.state_desc,
	T2.node.value('(self::event/@name)[1]', 'varchar(100)') AS node_event_name,
	T2.node.value('(self::event/data[@name="spinlock_address"])[1]', 'varchar(100)') AS node_spinlock_address,
	T2.node.value('(self::event/data[@name="worker"])[1]', 'varchar(100)') AS node_worker,
	T2.node.value('(self::event/data[@name="backoffs"])[1]', 'bigint') AS node_backoffs,
	T2.node.value('(self::event/data[@name="type"])[1]', 'bigint') AS node_type,
	T2.node.value('(self::event/data[@name="category"]/text)[1]', 'varchar(100)') AS node_category,
	T2.node.value('(self::event/data[@name="description"])[1]', 'varchar(100)') AS node_description,
	T2.node.query('.') AS node
FROM
(
	SELECT
		timestamp, 
		name,
		CAST(event_data as XML).value('(/event/data[@name="node_name"]/value)[1]', 'varchar(100)') AS node_name,
		CAST(event_data as XML).value('(/event/data[@name="instance_name"]/value)[1]', 'varchar(100)') AS instance_name,
		CAST(event_data as XML).value('(/event/data[@name="state"]/value)[1]', 'int') AS state,
		CAST(event_data as XML).value('(/event/data[@name="failure_condition_level"]/value)[1]', 'int') AS failure_condition_level,
		CAST(event_data as XML).value('(/event/data[@name="component_type"]/value)[1]', 'varchar(100)') AS component_type,
		CAST(event_data as XML).value('(/event/data[@name="state_desc"]/value)[1]', 'varchar(100)') AS state_desc,
		CAST(event_data as XML).query('(/event/data[@name="data"])') AS data,
		event_data
	FROM
		[sqldiag_yyyymmdd]
	WHERE
		name = 'component_health_result'
		AND CAST(event_data as XML).value('(/event/data[@name="state_desc"]/value)[1]', 'varchar(100)') = 'unknown'
		AND timestamp >= @start_time AND timestamp < @end_time
) AS T
	CROSS APPLY data.nodes('//event[@name="spinlock_backoff_warning"]') AS T2(node)
ORDER BY 
	timestamp ASC

-- component_health_result (unknown)
-- scheduler_monitor_non_yielding_iocp_ring_buffer_recorded
SELECT
	T.timestamp,
	T.name,
	T.node_name,
	T.state,
	T.failure_condition_level,
	T.component_type,
	T.state_desc,
	T2.node.value('(self::event/@name)[1]', 'varchar(100)') AS node_event_name,
	T2.node.value('(self::event/data[@name="opcode"])[1]', 'varchar(100)') AS node_opcode,
	T2.node.value('(self::event/data[@name="node_id"])[1]', 'smallint') AS node_node_id,
	T2.node.value('(self::event/data[@name="worker"])[1]', 'varchar(100)') AS node_worker,
	T2.node.value('(self::event/data[@name="yields"])[1]', 'bigint') AS node_yields,
	T2.node.value('(self::event/data[@name="worker_utilization"])[1]', 'int') AS node_worker_utilization,
	T2.node.value('(self::event/data[@name="process_utilization"])[1]', 'int') AS node_process_utilization,
	T2.node.value('(self::event/data[@name="system_idle"])[1]', 'int') AS node_system_idle,
	T2.node.value('(self::event/data[@name="user_mode_time"])[1]', 'bigint') AS node_user_mode_time,
	T2.node.value('(self::event/data[@name="kernel_mode_time"])[1]', 'bigint') AS node_kernel_mode_time,
	T2.node.value('(self::event/data[@name="page_faults"])[1]', 'int') AS node_page_faults,
	T2.node.value('(self::event/data[@name="working_set_delta"])[1]', 'bigint') AS node_working_set_delta,
	T2.node.value('(self::event/data[@name="memory_utilization"])[1]', 'int') AS node_memory_utilization,
	T2.node.query('.') AS node
FROM
(
	SELECT
		timestamp, 
		name,
		CAST(event_data as XML).value('(/event/data[@name="node_name"]/value)[1]', 'varchar(100)') AS node_name,
		CAST(event_data as XML).value('(/event/data[@name="instance_name"]/value)[1]', 'varchar(100)') AS instance_name,
		CAST(event_data as XML).value('(/event/data[@name="state"]/value)[1]', 'int') AS state,
		CAST(event_data as XML).value('(/event/data[@name="failure_condition_level"]/value)[1]', 'int') AS failure_condition_level,
		CAST(event_data as XML).value('(/event/data[@name="component_type"]/value)[1]', 'varchar(100)') AS component_type,
		CAST(event_data as XML).value('(/event/data[@name="state_desc"]/value)[1]', 'varchar(100)') AS state_desc,
		CAST(event_data as XML).query('(/event/data[@name="data"])') AS data,
		event_data
	FROM
		[sqldiag_yyyymmdd]
	WHERE
		name = 'component_health_result'
		AND CAST(event_data as XML).value('(/event/data[@name="state_desc"]/value)[1]', 'varchar(100)') = 'unknown'
		AND timestamp >= @start_time AND timestamp < @end_time
) AS T
	CROSS APPLY data.nodes('//event[@name="scheduler_monitor_non_yielding_iocp_ring_buffer_recorded"]') AS T2(node)
ORDER BY 
	timestamp ASC


-- component_health_result (unknown)
-- scheduler_monitor_non_yielding_iocp_ring_buffer_recorded
SELECT
	T.timestamp,
	T.name,
	T.node_name,
	T.state,
	T.failure_condition_level,
	T.component_type,
	T.state_desc,
	T2.node.value('(self::event/@name)[1]', 'varchar(100)') AS node_event_name,
	T2.node.value('(self::event/data[@name="opcode"]/text)[1]', 'varchar(100)') AS node_opcode,
	T2.node.value('(self::event/data[@name="node_id"])[1]', 'smallint') AS node_node_id,
	T2.node.value('(self::event/data[@name="worker"])[1]', 'varchar(100)') AS node_worker,
	T2.node.value('(self::event/data[@name="yields"])[1]', 'varchar(100)') AS node_yields,
	T2.node.value('(self::event/data[@name="worker_utilization"])[1]', 'int') AS node_worker_utilization,
	T2.node.value('(self::event/data[@name="process_utilization"])[1]', 'int') AS node_process_utilization,
	T2.node.value('(self::event/data[@name="system_idle"])[1]', 'int') AS node_system_idle,
	T2.node.value('(self::event/data[@name="user_mode_time"])[1]', 'bigint') AS node_user_mode_time,
	T2.node.value('(self::event/data[@name="kernel_mode_time"])[1]', 'bigint') AS node_kernel_mode_time,
	T2.node.value('(self::event/data[@name="page_faults"])[1]', 'int') AS node_page_faults,
	T2.node.value('(self::event/data[@name="working_set_delta"])[1]', 'bigint') AS node_working_set_delta,
	T2.node.value('(self::event/data[@name="memory_utilization"])[1]', 'int') AS node_memory_utilization,
	T2.node.query('.') AS node
FROM
(
	SELECT
		timestamp, 
		name,
		CAST(event_data as XML).value('(/event/data[@name="node_name"]/value)[1]', 'varchar(100)') AS node_name,
		CAST(event_data as XML).value('(/event/data[@name="instance_name"]/value)[1]', 'varchar(100)') AS instance_name,
		CAST(event_data as XML).value('(/event/data[@name="state"]/value)[1]', 'int') AS state,
		CAST(event_data as XML).value('(/event/data[@name="failure_condition_level"]/value)[1]', 'int') AS failure_condition_level,
		CAST(event_data as XML).value('(/event/data[@name="component_type"]/value)[1]', 'varchar(100)') AS component_type,
		CAST(event_data as XML).value('(/event/data[@name="state_desc"]/value)[1]', 'varchar(100)') AS state_desc,
		CAST(event_data as XML).query('(/event/data[@name="data"])') AS data,
		event_data
	FROM
		[sqldiag_yyyymmdd]
	WHERE
		name = 'component_health_result'
		AND CAST(event_data as XML).value('(/event/data[@name="state_desc"]/value)[1]', 'varchar(100)') = 'unknown'
		AND timestamp >= @start_time AND timestamp < @end_time
) AS T
	CROSS APPLY data.nodes('//event[@name="scheduler_monitor_non_yielding_iocp_ring_buffer_recorded"]') AS T2(node)
ORDER BY 
	timestamp ASC

-- component_health_result (unknown)
-- stack_trace
SELECT
	T.timestamp,
	T.name,
	T.node_name,
	T.state,
	T.failure_condition_level,
	T.component_type,
	T.state_desc,
	T2.node.value('(self::event/@name)[1]', 'varchar(100)') AS node_event_name,
	T2.node.value('(self::event/data[@name="dump_options"]/text)[1]', 'varchar(100)') AS node_dump_options,
	T2.node.value('(self::event/data[@name="bucket_hint"]/text)[1]', 'varchar(100)') AS node_bucket_hint,
	T2.node.value('(self::event/data[@name="dump_class"]/text)[1]', 'varchar(100)') AS node_dump_class,
	T2.node.value('(self::event/data[@name="opcode"]/text)[1]', 'varchar(100)') AS node_opcode,
	T2.node.value('(self::event/data[@name="message"])[1]', 'varchar(100)') AS node_message,
	T2.node.query('.') AS node
FROM
(
	SELECT
		timestamp, 
		name,
		CAST(event_data as XML).value('(/event/data[@name="node_name"]/value)[1]', 'varchar(100)') AS node_name,
		CAST(event_data as XML).value('(/event/data[@name="instance_name"]/value)[1]', 'varchar(100)') AS instance_name,
		CAST(event_data as XML).value('(/event/data[@name="state"]/value)[1]', 'int') AS state,
		CAST(event_data as XML).value('(/event/data[@name="failure_condition_level"]/value)[1]', 'int') AS failure_condition_level,
		CAST(event_data as XML).value('(/event/data[@name="component_type"]/value)[1]', 'varchar(100)') AS component_type,
		CAST(event_data as XML).value('(/event/data[@name="state_desc"]/value)[1]', 'varchar(100)') AS state_desc,
		CAST(event_data as XML).query('(/event/data[@name="data"])') AS data,
		event_data
	FROM
		[sqldiag_yyyymmdd]
	WHERE
		name = 'component_health_result'
		AND CAST(event_data as XML).value('(/event/data[@name="state_desc"]/value)[1]', 'varchar(100)') = 'unknown'
		AND timestamp >= @start_time AND timestamp < @end_time
) AS T
	CROSS APPLY data.nodes('//event[@name="stack_trace"]') AS T2(node)
ORDER BY 
	timestamp ASC