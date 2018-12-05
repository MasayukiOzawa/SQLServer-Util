/*
DROP TABLE IF EXISTS Simple_Monitor
CREATE TABLE Simple_Monitor (
	end_date datetime2(0),
	service_objective nvarchar(32), 
	object_name nvarchar(128),
	counter_name nvarchar(128),
	instance_name nvarchar(128),
	cntr_value float,
	cntr_type int,
	CONSTRAINT PK_Counter PRIMARY KEY CLUSTERED (end_date, object_name, counter_name, instance_name)
) WITH (DATA_COMPRESSION=PAGE)
GO
*/
-- Interval : 5 sec / Acquisition Time : 1 hour / Size : 5.5 MB (1 day : 135 MB)

SET NOCOUNT ON
GO

DECLARE @counter_date datetime2(0)
WHILE(0=0)
BEGIN
	SET @counter_date = DATEADD(HOUR, 9, GETUTCDATE())
	-- Batch Request / sec
	INSERT INTO 
		Simple_Monitor
	SELECT 
		@counter_date ,
		CAST(DATABASEPROPERTYEX(DB_NAME(), 'ServiceObjective') AS nvarchar(32)),
		TRIM(object_name) AS object_name,
		TRIM(counter_name) AS counter_name,
		TRIM(instance_name) AS instance_name,
		cntr_value,
		cntr_type
	FROM
		sys.dm_os_performance_counters 
	WHERE 
		counter_name = 'Batch Requests/sec';

	-- Resource Pool
	INSERT INTO 
		Simple_Monitor
	SELECT 
		@counter_date ,
		CAST(DATABASEPROPERTYEX(DB_NAME(), 'ServiceObjective') AS nvarchar(32)),
		TRIM(object_name) AS object_name,
		TRIM(counter_name) AS counter_name,
		TRIM(instance_name) AS instance_name,
		cntr_value,
		cntr_type
	FROM
		sys.dm_os_performance_counters 
	WHERE
		instance_name = (
			SELECT name FROM sys.dm_resource_governor_workload_groups WHERE group_id = 
			(SELECT group_id  FROM sys.dm_exec_sessions WHERE session_id = @@SPID)
		);

	-- Log
	INSERT INTO 
		Simple_Monitor
	SELECT 
		@counter_date ,
		CAST(DATABASEPROPERTYEX(DB_NAME(), 'ServiceObjective') AS nvarchar(32)),
		TRIM(object_name) AS object_name,
		TRIM(counter_name) AS counter_name,
		TRIM(instance_name) AS instance_name,
		cntr_value,
		cntr_type
	FROM
		sys.dm_os_performance_counters 
	WHERE
		object_name LIKE '%:Databases%' AND
		counter_name IN ('Log Flushes/sec', 'Log Bytes Flushed/sec','Log Writer Writes/sec' ) AND
		instance_name = (SELECT physical_database_name 
		FROM sys.databases WHERE name = DB_NAME())
	
	-- CheckPoint / Buffer Write
	INSERT INTO 
		Simple_Monitor
	SELECT 
		@counter_date ,
		CAST(DATABASEPROPERTYEX(DB_NAME(), 'ServiceObjective') AS nvarchar(32)),
		TRIM(object_name) AS object_name,
		TRIM(counter_name) AS counter_name,
		TRIM(instance_name) AS instance_name,
		cntr_value,
		cntr_type
	FROM
		sys.dm_os_performance_counters 
	WHERE
		counter_name IN('Page writes/sec', 'Background writer pages/sec', 'Checkpoint pages/sec', 'Database Cache Memory (KB)', 'User Connections')

	-- HTTP Storage
	INSERT INTO 
		Simple_Monitor
	SELECT 
		@counter_date ,
		CAST(DATABASEPROPERTYEX(DB_NAME(), 'ServiceObjective') AS nvarchar(32)),
		TRIM(object_name) AS object_name,
		TRIM(counter_name) AS counter_name,
		TRIM(instance_name) AS instance_name,
		cntr_value,
		cntr_type
	FROM
		sys.dm_os_performance_counters 
	WHERE
		Object_name LIKE '%HTTP Storage%' 
		AND 
		instance_name LIKE '%windows.net %'

	-- Worker Thread
	INSERT INTO 
		Simple_Monitor
	SELECT 
		@counter_date,
		CAST(DATABASEPROPERTYEX(DB_NAME(), 'ServiceObjective') AS nvarchar(32)) AS service_objective,
		'sys.dm_os_schedulers' AS object_name,
		'active_workers_count',
		'' AS instance_name,
		SUM(active_workers_count),
		65792 AS cntr_type
	FROM 
		sys.dm_os_schedulers 
	WHERE 
		status = 'VISIBLE ONLINE'

	-- Storage Usage
	INSERT INTO 
		Simple_Monitor
	SELECT 
		@counter_date,
		CAST(DATABASEPROPERTYEX(DB_NAME(), 'ServiceObjective') AS nvarchar(32)) AS service_objective,
		'sys.dm_db_file_space_usage' AS object_name,
		'allocated_extent_megabytes',
		'' AS instance_name,
		SUM(allocated_extent_page_count) * 8.0 / 1024 ,
		65792 AS cntr_type
	FROM 
		sys.dm_db_file_space_usage

	-- DTU
	INSERT INTO 
		Simple_Monitor
	SELECT
		@counter_date,
		CAST(DATABASEPROPERTYEX(DB_NAME(), 'ServiceObjective') AS nvarchar(32)) AS service_objective,
		'sys.dm_db_resource_stats' AS object_name,
		counter_name,
		'' AS instance_name,
		cntr_value,
		65792 AS cntr_type
	FROM 
	(SELECT	 TOP 1
		avg_cpu_percent,
		avg_data_io_percent,
		avg_log_write_percent,
		avg_memory_usage_percent,
		xtp_storage_percent,
		max_worker_percent,
		max_session_percent
	FROM
		sys.dm_db_resource_stats 
	ORDER BY
		end_time DESC
	)AS T
	UNPIVOT
	(
		cntr_value FOR counter_name 
		IN(
			[avg_cpu_percent],
			[avg_data_io_percent],
			[avg_log_write_percent],
			[avg_memory_usage_percent],
			[xtp_storage_percent],
			[max_worker_percent],
			[max_session_percent]
		)
	) AS PT

	-- Loop Wait
	WAITFOR DELAY '00:00:05'
END
