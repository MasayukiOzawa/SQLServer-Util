/*
Interpreting the counter values from sys.dm_os_performance_counters
https://blogs.msdn.microsoft.com/psssql/2013/09/23/interpreting-the-counter-values-from-sys-dm_os_performance_counters/

2.2.4.2 _PERF_COUNTER_REG_INFO
https://msdn.microsoft.com/en-us/library/cc238313.aspx
*/
-- PERF_COUNTER_LARGE_RAWCOUNT / PERF_COUNTER_COUNTER / PERF_COUNTER_BULK_COUNT
SELECT
        @@SERVERNAME AS server_name,
	DB_NAME() AS db_name,
        RTRIM(SUBSTRING(object_name, PATINDEX('%:%', object_name) + 1, 256)) AS object_name,
        RTRIM(counter_name) AS counter_name,
        CASE
                WHEN RTRIM(instance_name) = '' THEN 'None'
                ELSE RTRIM(instance_name)
        END AS instance_name,
        cntr_value,
        NULL AS cntr_value_base,
        cntr_type
FROM
        sys.dm_os_performance_counters
WHERE
        cntr_type IN (65792, 272696320, 272696576)

-- PERF_LARGE_RAW_FRACTION
SELECT
        @@SERVERNAME AS server_name,
	DB_NAME() AS db_name,
        RTRIM(SUBSTRING(T1.object_name, PATINDEX('%:%', T1.object_name) + 1, 256)) AS object_name,
        RTRIM(T1.counter_name) AS counter_name,
        CASE
                WHEN RTRIM(T1.instance_name) = '' THEN 'None'
                ELSE RTRIM(T1.instance_name)
        END AS instance_name,
        CASE
                WHEN T1.cntr_value = 0 THEN 0
                ELSE (T1.cntr_value * 1.0 / T2.cntr_value * 1.0) * 100
        END AS cntr_value,
        NULL AS cntr_value_base,
        T1.cntr_type
FROM
        sys.dm_os_performance_counters as T1
        LEFT JOIN
        sys.dm_os_performance_counters as T2
        ON
                T2.object_name = T1.object_name
                AND
                T2.instance_name = T1.instance_name
                AND
                (
                REPLACE(LOWER(RTRIM(T2.counter_name)), 'base', 'ratio') = LOWER(RTRIM(T1.counter_name))
                OR
                LOWER(RTRIM(T2.counter_name)) = LOWER(RTRIM(T1.counter_name)) + ' base'
                )
                AND
                T2.cntr_type = 1073939712
WHERE
        T1.cntr_type IN (537003264)

-- PERF_AVERAGE_BULK
SELECT
        @@SERVERNAME AS server_name,
	DB_NAME() AS db_name,
        RTRIM(SUBSTRING(T1.object_name, PATINDEX('%:%', T1.object_name) + 1, 256)) AS object_name,
        RTRIM(T1.counter_name) AS counter_name,
        CASE
                WHEN RTRIM(T1.instance_name) = '' THEN 'None'
                ELSE RTRIM(T1.instance_name)
        END AS instance_name,
        T1.cntr_value,
        T2.cntr_value AS cntr_value_base,
        T1.cntr_type
FROM
        sys.dm_os_performance_counters as T1
        LEFT JOIN
        sys.dm_os_performance_counters as T2
        ON
                T2.object_name = T1.object_name
                AND
                T2.instance_name = T1.instance_name
                AND
                (
                REPLACE(LOWER(RTRIM(T2.counter_name)), 'base', '(ms)') = LOWER(RTRIM(T1.counter_name))
                OR
                REPLACE(LOWER(RTRIM(T2.counter_name)), ' base', '/Fetch') = LOWER(RTRIM(T1.counter_name))
                OR
                LOWER(RTRIM(T2.counter_name)) = LOWER(RTRIM(T1.counter_name)) + ' base'
                )
                AND
                T2.cntr_type = 1073939712
WHERE
        T1.cntr_type = 1073874176
        AND
        T2.cntr_value IS NOT NULL
