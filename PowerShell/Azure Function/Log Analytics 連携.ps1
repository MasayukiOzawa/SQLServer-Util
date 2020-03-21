# https://docs.microsoft.com/ja-jp/azure/log-analytics/log-analytics-data-collector-api

Param(
    $CustomerId = $ENV:WorkspaceID,　　　# Replace with your Workspace ID
    $SharedKey = $ENV:SharedKey,    # Replace with your Primary Key
    $ConnectionString = $ENV:SQLAZURECONNSTR_CollectTarget
)

# Create the function to create the authorization signature
Function Build-Signature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource)
{
    $xHeaders = "x-ms-date:" + $date
    $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource

    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($sharedKey)

    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    $authorization = 'SharedKey {0}:{1}' -f $customerId,$encodedHash
    return $authorization
}


# Create the function to create and post the request
Function Post-LogAnalyticsData($customerId, $sharedKey, $body, $logType)
{
    $method = "POST"
    $contentType = "application/json"
    $resource = "/api/logs"
    $rfc1123date = [DateTime]::UtcNow.ToString("r")
    $contentLength = $body.Length
    $signature = Build-Signature `
        -customerId $customerId `
        -sharedKey $sharedKey `
        -date $rfc1123date `
        -contentLength $contentLength `
        -method $method `
        -contentType $contentType `
        -resource $resource
    $uri = "https://" + $customerId + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"

    $headers = @{
        "Authorization" = $signature;
        "Log-Type" = $logType;
        "x-ms-date" = $rfc1123date;
    }

    $response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $body -UseBasicParsing
    return $response.StatusCode

}

$ErrorAction = "Stop"

$Con = New-Object System.Data.SqlClient.SqlConnection
$con.ConnectionString = $ConnectionString
$con.Open()

$cmd = $con.CreateCommand()
$cmd.CommandType = [System.Data.CommandType]::Text
$cmd.CommandText = @"
/*
-- ****************************************
-- ** Performance Counters
-- ****************************************
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

-- ****************************************
-- ** Session / Connection / Worker
-- ****************************************
SELECT
    @@SERVERNAME AS server_name,
	DB_NAME() AS db_name,
	(SELECT COUNT_BIG(*) FROM sys.dm_exec_sessions) AS total_sessions,
	(SELECT COUNT_BIG(*) FROM sys.dm_exec_connections) AS total_connections,
	(SELECT COUNT_BIG(*) FROM sys.dm_os_workers) AS total_workers,
	(SELECT COUNT_BIG(*) FROM sys.dm_os_tasks) AS total_tasks,
	(SELECT MAX(task) AS max_parallel
		FROM
		(
			SELECT session_id, request_id, COUNT(*) AS task 
			FROM sys.dm_os_tasks
			WHERE
			session_id IS NOT NULL
			GROUP BY session_id, request_id
		) AS T
	 ) AS max_parallel


-- ****************************************
-- ** File I/O
-- ****************************************
SELECT
    @@SERVERNAME AS server_name,
	DB_NAME() AS db_name,
	DB_NAME(database_id) AS database_name,
	file_id,
	num_of_reads,
	num_of_bytes_read,
	io_stall_read_ms,
	io_stall_queued_read_ms,
	num_of_writes,
	num_of_bytes_written,
	io_stall_write_ms,
	io_stall_queued_write_ms,
	io_stall,
	size_on_disk_bytes
FROM
	sys.dm_io_virtual_file_stats(NULL, NULL)
WHERE 
	DB_NAME(database_id) IS NOT NULL
	AND
	database_id NOT IN(1,3,4)

-- ****************************************
-- ** Scheduler
-- ****************************************
SELECT 
    @@SERVERNAME AS server_name,
	DB_NAME() AS db_name,
	scheduler_address,
	parent_node_id,
	scheduler_id,
	cpu_id,
	status,
	is_online,
	is_idle,
	preemptive_switches_count,
	context_switches_count,
	idle_switches_count,
	current_tasks_count,
	runnable_tasks_count,
	current_workers_count,
	active_workers_count,
	work_queue_count,
	pending_disk_io_count,
	load_factor,
	yield_count,
	last_timer_activity,
	failed_to_create_worker,
	active_worker_address,
	memory_object_address,
	task_memory_object_address,
	quantum_length_us,
	total_cpu_usage_ms,
	total_cpu_idle_capped_ms,
	total_scheduler_delay_ms
FROM 
	sys.dm_os_schedulers
WHERE
	is_online = 1
	AND
	scheduler_id < 1048576

-- ****************************************
-- ** Wait Stats
-- ****************************************
SELECT 
	@@SERVERNAME AS server_name,
	DB_NAME() AS db_name,
	wait_type,
	waiting_tasks_count,
	wait_time_ms,
	max_wait_time_ms,
	signal_wait_time_ms
FROM 
	sys.dm_os_wait_stats
WHERE
	waiting_tasks_count > 0
"@

$adapter = New-Object System.Data.SqlClient.SqlDataAdapter -ArgumentList $cmd
$ds = New-Object System.Data.DataSet
$adapter.Fill($ds) | Out-Null


$Con.Close()
$con.Dispose()


###########################################################
# Performance Counters
###########################################################
$ArrayList  = New-Object System.Collections.ArrayList

foreach ($row in $ds.Tables[0..2].Rows){
    $ArrayList.Add(
        [PSCustomObject]@{
            "Computer" = "$($row.server_name)"
            "db_name" =  "$($row.db_name)"
            "object_name" = "$($row.object_name)"
            "counter_name" = "$($row.counter_name)"
            "instance_name" = "$($row.instance_name)"
            "cntr_value" = $row.cntr_value
            "cntr_value_base" = $row.cntr_value_base
            "cntr_type" = $row.cntr_type
        }
    ) | Out-Null
}
$json = $ArrayList | ConvertTo-Json

$LogType = "SQLPerformance_Perf"
Post-LogAnalyticsData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($json)) -logType $logType


###########################################################
# Session / Connection / Worker
###########################################################
$ArrayList  = New-Object System.Collections.ArrayList

foreach ($row in $ds.Tables[3].Rows){
    $ArrayList.Add(
        [PSCustomObject]@{
            "Computer" = "$($row.server_name)"
            "db_name" =  "$($row.db_name)"
            "total_sessions" = $row.total_sessions
            "total_connections" = $row.total_connections
            "total_workers" = $row.total_workers
            "total_tasks" = $row.total_tasks
            "max_parallel" = $row.max_parallel
        }
    ) | Out-Null
}
$json = $ArrayList | ConvertTo-Json

$LogType = "SQLPerformance_Session"
Post-LogAnalyticsData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($json)) -logType $logType


###########################################################
# Session / Connection / Worker
###########################################################
$ArrayList  = New-Object System.Collections.ArrayList

foreach ($row in $ds.Tables[4].Rows){
    $ArrayList.Add(
        [PSCustomObject]@{
            "Computer" = "$($row.server_name)"
            "db_name" =  "$($row.db_name)"
            "database_name" =  "$($row.database_name)"
            "file_id" = $row.file_id
            "num_of_reads" = $row.num_of_reads
            "num_of_bytes_read" = $row.num_of_bytes_read
            "io_stall_read_ms" = $row.io_stall_read_ms
            "io_stall_queued_read_ms" = $row.io_stall_queued_read_ms
            "num_of_writes" = $row.num_of_writes
            "num_of_bytes_written" = $row.num_of_bytes_written
            "io_stall_write_ms" = $row.io_stall_write_ms
            "io_stall_queued_write_ms" = $row.io_stall_queued_write_ms
            "io_stall" = $row.io_stall
            "size_on_disk_bytes" = $row.size_on_disk_bytes
        } 
    ) | Out-Null
}
$json = $ArrayList | ConvertTo-Json

$LogType = "SQLPerformance_FileIO"
Post-LogAnalyticsData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($json)) -logType $logType


###########################################################
# Scheduler
###########################################################
$ArrayList  = New-Object System.Collections.ArrayList

foreach ($row in $ds.Tables[5].Rows){
    $ArrayList.Add(
        [PSCustomObject]@{
            "Computer" = "$($row.server_name)"
            "db_name" =  "$($row.db_name)"
            "scheduler_address" =  "$($row.scheduler_address)"
            "parent_node_id" = $row.parent_node_id
            "scheduler_id" = $row.scheduler_id
            "cpu_id" = $row.cpu_id
            "status" = "$($row.status)"
            "is_online" = $row.is_online
            "is_idle" = $row.is_idle
            "preemptive_switches_count" = $row.preemptive_switches_count
            "context_switches_count" = $row.context_switches_count
            "idle_switches_count" = $row.idle_switches_count
            "current_tasks_count" = $row.current_tasks_count
            "runnable_tasks_count" = $row.runnable_tasks_count
            "current_workers_count" = $row.current_workers_count
            "active_workers_count" = $row.active_workers_count
            "work_queue_count" = $row.work_queue_count
            "pending_disk_io_count" = $row.pending_disk_io_count
            "load_factor" = $row.load_factor
            "yield_count" = $row.yield_count
            "last_timer_activity" = $row.last_timer_activity
            "failed_to_create_worker" = $row.failed_to_create_worker
            "active_worker_address" = $($row.active_worker_address)
            "memory_object_address" = $($row.memory_object_address)
            "task_memory_object_address" = $($row.task_memory_object_address)
            "quantum_length_us" = $row.quantum_length_us
            "total_cpu_usage_ms" = $row.total_cpu_usage_ms
            "total_cpu_idle_capped_ms" = $row.total_cpu_idle_capped_ms
            "total_scheduler_delay_ms" = $row.total_scheduler_delay_ms
        } 
    ) | Out-Null
}
$json = $ArrayList | ConvertTo-Json

$LogType = "SQLPerformance_Scheduler"
Post-LogAnalyticsData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($json)) -logType $logType

###########################################################
# Wait Stats
###########################################################
$ArrayList  = New-Object System.Collections.ArrayList

foreach ($row in $ds.Tables[6].Rows){
    $ArrayList.Add(
        [PSCustomObject]@{
            "Computer" = "$($row.server_name)"
            "db_name" =  "$($row.db_name)"
            "wait_type" =  "$($row.wait_type)"
            "waiting_tasks_count" = $row.waiting_tasks_count
            "wait_time_ms" = $row.wait_time_ms
            "max_wait_time_ms" = $row.max_wait_time_ms
            "signal_wait_time_ms" = $row.signal_wait_time_ms
        } 
    ) | Out-Null
}
$json = $ArrayList | ConvertTo-Json

$LogType = "SQLPerformance_WaitStats"
Post-LogAnalyticsData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($json)) -logType $logType

$ds.Dispose()