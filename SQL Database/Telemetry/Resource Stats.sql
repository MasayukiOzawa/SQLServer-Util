DROP TABLE IF EXISTS #resource_stats
GO

CREATE TABLE #resource_stats(
	timestamp_utc datetime2(3) NOT NULL,
	object_name nvarchar(120),
	module_guid uniqueidentifier,
	package_guid uniqueidentifier,
	event_data xml,
	database_name varchar(50) NOT NULL,
	file_name nvarchar(520),
	file_offset bigint NOT NULL
)
ALTER TABLE #resource_stats ADD CONSTRAINT PK_resource_stats

PRIMARY KEY CLUSTERED (timestamp_utc, database_name, file_offset)
CREATE PRIMARY XML INDEX XML_event_data_resource_stats ON #resource_stats(event_data)
GO

INSERT INTO #resource_stats
SELECT
	timestamp_utc,
	object_name,
	module_guid,
	package_guid,
	CAST(event_data AS xml) AS event_data,
	COALESCE(
		CAST(event_data AS xml).value('(//data[@name="database_name"])[1]', 'varchar(255)')
		, 'N/A')
	AS database_name,
	file_name,
	file_offset
FROM
(
	SELECT * 
	FROM sys.fn_xe_telemetry_blob_target_read_file('rs', null, null, null)  
	-- ru ‚àŽw’è‰Â”\
) AS T
ORDER BY 
	timestamp_utc DESC
GO

SELECT
	timestamp_utc,
	object_name,
	database_name,
	event_data.value('(//data[@name="start_time"])[1]', 'datetime2(3)') AS start_time,
	event_data.value('(//data[@name="end_time"])[1]', 'datetime2(3)') AS end_time,
	event_data.value('(//data[@name="storage_in_megabytes"])[1]', 'float') AS storage_in_megabytes,
	event_data.value('(//data[@name="avg_cpu_percent"])[1]', 'float') AS avg_cpu_percent,
	event_data.value('(//data[@name="avg_data_io_percent"])[1]', 'float') AS avg_data_io_percent,
	event_data.value('(//data[@name="avg_log_write_percent"])[1]', 'float') AS avg_log_write_percent,
	event_data.value('(//data[@name="sku"])[1]', 'varchar(50)') AS sku,
	event_data.value('(//data[@name="service_level_objective"])[1]', 'varchar(50)') AS service_level_objective,
	event_data.value('(//data[@name="max_worker_percent"])[1]', 'float') AS max_worker_percent,
	event_data.value('(//data[@name="max_session_percent"])[1]', 'float') AS max_session_percent,
	event_data.value('(//data[@name="dtu_limit"])[1]', 'float') AS dtu_limit,
	event_data.value('(//data[@name="xtp_storage_percent"])[1]', 'float') AS xtp_storage_percent,
	event_data.value('(//data[@name="avg_login_rate_percent"])[1]', 'float') AS avg_login_rate_percent,
	event_data.value('(//data[@name="avg_instance_cpu_percent"])[1]', 'float') AS avg_instance_cpu_percent,
	event_data.value('(//data[@name="avg_log_write_percent"])[1]', 'float') AS avg_log_write_percent,
	event_data.value('(//data[@name="avg_instance_memory_percent"])[1]', 'float') AS avg_instance_memory_percent,
	event_data.value('(//data[@name="cpu_limit"])[1]', 'float') AS cpu_limit,
	event_data.value('(//data[@name="allocated_storage_in_megabytes"])[1]', 'float') AS allocated_storage_in_megabytes
FROM
	#resource_stats 
ORDER BY
	timestamp_utc DESC