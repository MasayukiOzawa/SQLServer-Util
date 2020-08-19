-- master で実行

-- デッドロック
SELECT 
    object_name,
    timestamp_utc,
    CAST(event_data as xml) AS event_data
FROM 
    sys.fn_xe_telemetry_blob_target_read_file('dl', null, null, null) AS f
WHERE
    CAST(timestamp_utc AS datetime) >= DATEADD(day, -10, GETDATE())

-- リソース統計 (sys.resource_stats 相当 : 5 分間隔 / 14 日間分)
SELECT
    *,
    event_data.value('(/event/data[@name="start_time"]/value)[1]', 'datetime2(0)') AS start_time,
    event_data.value('(/event/data[@name="end_time"]/value)[1]', 'datetime2(0)') AS end_time,
    event_data.value('(/event/data[@name="storage_in_megabytes"]/value)[1]', 'float') AS storage_in_megabytes,
    event_data.value('(/event/data[@name="avg_cpu_percent"]/value)[1]', 'float') AS avg_cpu_percent,
    event_data.value('(/event/data[@name="avg_data_io_percent"]/value)[1]', 'float') AS avg_data_io_percent,
    event_data.value('(/event/data[@name="avg_log_write_percent"]/value)[1]', 'float') AS avg_log_write_percent,
    event_data.value('(/event/data[@name="server_name"]/value)[1]', 'varchar(255)') AS server_name,
    event_data.value('(/event/data[@name="database_name"]/value)[1]', 'varchar(255)') AS database_name,
    event_data.value('(/event/data[@name="sku"]/value)[1]', 'varchar(255)') AS sku,
    event_data.value('(/event/data[@name="logical_database_guid"]/value)[1]', 'uniqueidentifier') AS logical_database_guid,
    event_data.value('(/event/data[@name="service_level_objective"]/value)[1]', 'varchar(255)') AS service_level_objective,
    event_data.value('(/event/data[@name="max_worker_percent"]/value)[1]', 'float') AS max_worker_percent,
    event_data.value('(/event/data[@name="max_session_percent"]/value)[1]', 'float') AS max_session_percent,
    event_data.value('(/event/data[@name="dtu_limit"]/value)[1]', 'float') AS dtu_limit,
    event_data.value('(/event/data[@name="xtp_storage_percent"]/value)[1]', 'float') AS xtp_storage_percent,
    event_data.value('(/event/data[@name="avg_login_rate_percent"]/value)[1]', 'float') AS avg_login_rate_percent,
    event_data.value('(/event/data[@name="avg_instance_cpu_percent"]/value)[1]', 'float') AS avg_instance_cpu_percent,
    event_data.value('(/event/data[@name="avg_instance_memory_percent"]/value)[1]', 'float') AS avg_instance_memory_percent,
    event_data.value('(/event/data[@name="cpu_limit"]/value)[1]', 'float') AS cpu_limit,
    event_data.value('(/event/data[@name="allocated_storage_in_megabytes"]/value)[1]', 'float') AS allocated_storage_in_megabytes
FROM
(
    SELECT
        object_name,
        timestamp_utc,
        CAST(event_data as xml) AS event_data
    FROM 
        sys.fn_xe_telemetry_blob_target_read_file('rs', null, null, null) AS f
    WHERE
        CAST(timestamp_utc AS datetime) >= DATEADD(day, -1, GETDATE())

) AS T
ORDER BY timestamp_utc ASC


-- リソース使用状況 (データベースストレージの使用状況 : 1 時間間隔 / 1 ヶ月分)
SELECT
    *,
    event_data.value('(/event/data[@name="end_time"]/value)[1]', 'datetime2(0)') AS end_time,
    event_data.value('(/event/data[@name="storage_in_megabytes"]/value)[1]', 'float') AS storage_in_megabytes,
    event_data.value('(/event/data[@name="server_name"]/value)[1]', 'varchar(255)') AS server_name,
    event_data.value('(/event/data[@name="database_name"]/value)[1]', 'varchar(255)') AS server_name,
    event_data.value('(/event/data[@name="sku"]/value)[1]', 'varchar(255)') AS sku
FROM
(
    SELECT
        object_name,
        timestamp_utc,
        CAST(event_data as xml) AS event_data
    FROM 
        sys.fn_xe_telemetry_blob_target_read_file('ru', null, null, null) AS f
    WHERE
        CAST(timestamp_utc AS datetime) >= DATEADD(day, -1, GETDATE())
) AS T
ORDER BY timestamp_utc ASC



-- イベントログ (1 ヶ月分object_name : lock_deadlock / login_event / process_killed_by_abort_blockers)
-- https://docs.microsoft.com/ja-jp/azure/azure-sql/database/troubleshoot-common-connectivity-issues#diagnostics-search-for-problem-events-in-the-sql-database-log
SELECT
    *
FROM
(
    SELECT
        object_name,
        timestamp_utc,
        CAST(event_data as xml) AS event_data
    FROM 
        sys.fn_xe_telemetry_blob_target_read_file('el', null, null, null) AS f
    WHERE
        object_name <> 'login_event' --ログインイベントは数が多いため除外
) AS T
ORDER BY timestamp_utc ASC