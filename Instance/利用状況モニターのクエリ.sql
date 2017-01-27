/*****************************************************/
-- 概要
/*****************************************************/
EXEC #am_generate_waitstats

SELECT 
    SUM (interval_wait_time_per_sec) / 1000 AS avg_waiting_task_count
FROM #am_resource_mon_snap;


SET NOCOUNT ON;

DECLARE @previous_collection_time datetime;
DECLARE @previous_total_io_mb numeric (28, 1);
DECLARE @current_collection_time datetime;
DECLARE @current_total_io_mb numeric (28, 1);
DECLARE @mb_per_sec numeric (20, 1);

-- Get the previous snapshot's total I/O
SELECT TOP 1 @previous_collection_time = collection_time, @previous_total_io_mb = total_io_bytes 
FROM #am_dbfileio
ORDER BY collection_time DESC;

-- Get the current total I/O.  
SET @current_collection_time = GETDATE();
SELECT @current_total_io_mb = SUM(num_of_bytes_read + num_of_bytes_written) / 1024.0 / 1024.0
FROM sys.dm_io_virtual_file_stats(default, default);

-- Calc the total I/O rate (MB/sec) for the just-completed time interval. 
-- Round values larger than 2MB/sec to the nearest MB.
SET @mb_per_sec = (@current_total_io_mb - @previous_total_io_mb) / DATEDIFF (millisecond, @previous_collection_time, @current_collection_time) * 1000;
IF @mb_per_sec > 2 
BEGIN
  SET @mb_per_sec = ROUND (@mb_per_sec, 0);
END; 

-- Save off current total I/O
INSERT INTO #am_dbfileio (collection_time, total_io_bytes) 
VALUES (@current_collection_time, @current_total_io_mb);

-- Return the I/O rate for the just-completed time interval. 
SELECT ISNULL (@mb_per_sec, 0) AS mb_per_sec;

-- Get rid of all but the most recent snapshot's data
DELETE FROM #am_dbfileio WHERE collection_time < @current_collection_time;


SELECT 
    SUM (interval_wait_time_per_sec) / 1000 AS avg_waiting_task_count
FROM #am_resource_mon_snap;


SET NOCOUNT ON;

DECLARE @previous_collection_time datetime;
DECLARE @previous_request_count bigint;
DECLARE @current_collection_time datetime;
DECLARE @current_request_count bigint;
DECLARE @batch_requests_per_sec bigint;
DECLARE @interval_sec bigint;

-- Get the previous snapshot's time and batch request count
SELECT TOP 1 @previous_collection_time = collection_time, @previous_request_count = request_count 
FROM #am_request_count
ORDER BY collection_time DESC;

-- Get the current total time and batch request count
SET @current_collection_time = GETDATE();
SELECT @current_request_count = cntr_value 
FROM sys.sysperfinfo
WHERE counter_name = 'Batch Requests/sec' COLLATE Latin1_General_BIN;

SET @interval_sec = 
    -- Avoid divide-by-zero
    CASE
        WHEN DATEDIFF (second, @previous_collection_time, @current_collection_time) = 0 THEN 1
        ELSE DATEDIFF (second, @previous_collection_time, @current_collection_time)
    END;

-- Calc the Batch Requests/sec rate for the just-completed time interval. 
SET @batch_requests_per_sec = (@current_request_count - @previous_request_count) / @interval_sec;

-- Save off current batch count
INSERT INTO #am_request_count (collection_time, request_count) 
VALUES (@current_collection_time, @current_request_count);

-- Return the batch requests/sec rate for the just-completed time interval. 
SELECT ISNULL (@batch_requests_per_sec, 0) AS batch_requests_per_sec;

-- Get rid of all but the most recent snapshot's data
DELETE FROM #am_request_count WHERE collection_time < @current_collection_time;

/*****************************************************/
-- プロセス一覧
/*****************************************************/
WITH profiled_sessions as (
	SELECT DISTINCT session_id profiled_session_id from sys.dm_exec_query_profiles
)
SELECT 
   [Session ID]    = s.session_id, 
   [User Process]  = CONVERT(CHAR(1), s.is_user_process),
   [Login]         = s.login_name,   
   [Database]      = case when p.dbid=0 then N'' else ISNULL(db_name(p.dbid),N'') end, 
   [Task State]    = ISNULL(t.task_state, N''), 
   [Command]       = ISNULL(r.command, N''), 
   [Application]   = ISNULL(s.program_name, N''), 
   [Wait Time (ms)]     = ISNULL(w.wait_duration_ms, 0),
   [Wait Type]     = ISNULL(w.wait_type, N''),
   [Wait Resource] = ISNULL(w.resource_description, N''), 
   [Blocked By]    = ISNULL(CONVERT (varchar, w.blocking_session_id), ''),
   [Head Blocker]  = 
        CASE 
            -- session has an active request, is blocked, but is blocking others or session is idle but has an open tran and is blocking others
            WHEN r2.session_id IS NOT NULL AND (r.blocking_session_id = 0 OR r.session_id IS NULL) THEN '1' 
            -- session is either not blocking someone, or is blocking someone but is blocked by another party
            ELSE ''
        END, 
   [Total CPU (ms)] = s.cpu_time, 
   [Total Physical I/O (MB)]   = (s.reads + s.writes) * 8 / 1024, 
   [Memory Use (KB)]  = s.memory_usage * (8192 / 1024), 
   [Open Transactions] = ISNULL(r.open_transaction_count,0), 
   [Login Time]    = s.login_time, 
   [Last Request Start Time] = s.last_request_start_time,
   [Host Name]     = ISNULL(s.host_name, N''),
   [Net Address]   = ISNULL(c.client_net_address, N''), 
   [Execution Context ID] = ISNULL(t.exec_context_id, 0),
   [Request ID] = ISNULL(r.request_id, 0),
   [Workload Group] = ISNULL(g.name, N''),
   [Profiled Session Id] = profiled_session_id
FROM sys.dm_exec_sessions s LEFT OUTER JOIN sys.dm_exec_connections c ON (s.session_id = c.session_id)
LEFT OUTER JOIN sys.dm_exec_requests r ON (s.session_id = r.session_id)
LEFT OUTER JOIN sys.dm_os_tasks t ON (r.session_id = t.session_id AND r.request_id = t.request_id)
LEFT OUTER JOIN 
(
    -- In some cases (e.g. parallel queries, also waiting for a worker), one thread can be flagged as 
    -- waiting for several different threads.  This will cause that thread to show up in multiple rows 
    -- in our grid, which we don't want.  Use ROW_NUMBER to select the longest wait for each thread, 
    -- and use it as representative of the other wait relationships this thread is involved in. 
    SELECT *, ROW_NUMBER() OVER (PARTITION BY waiting_task_address ORDER BY wait_duration_ms DESC) AS row_num
    FROM sys.dm_os_waiting_tasks 
) w ON (t.task_address = w.waiting_task_address) AND w.row_num = 1
LEFT OUTER JOIN sys.dm_exec_requests r2 ON (s.session_id = r2.blocking_session_id)
LEFT OUTER JOIN sys.dm_resource_governor_workload_groups g ON (g.group_id = s.group_id)
LEFT OUTER JOIN sys.sysprocesses p ON (s.session_id = p.spid)
LEFT OUTER JOIN profiled_sessions ON profiled_session_id = s.session_id
ORDER BY s.session_id;

/*****************************************************/
-- リソースの待機
/*****************************************************/
SELECT 
    category_name AS [Wait Category], 
    SUM (interval_wait_time_per_sec) AS [Wait Time (ms/sec)], 
    SUM (weighted_average_wait_time_per_sec) AS [Recent Wait Time (ms/sec)], 
    SUM (interval_avg_waiter_count) AS [Average Waiter Count], 
    SUM (resource_wait_time_cumulative) /1000 AS [Cumulative Wait Time (sec)]
FROM #am_resource_mon_snap
GROUP BY category_name 
ORDER BY SUM (weighted_average_wait_time_per_sec) DESC;

/*****************************************************/
-- データベース ファイル I/O
/*****************************************************/
DECLARE @current_collection_time datetime;
SET @current_collection_time = GETDATE();

-- Grab a snapshot
INSERT INTO #am_dbfilestats
SELECT 
    @current_collection_time AS collection_time, 
    d.name AS [Database], 
    f.physical_name AS [File], 
    (fs.num_of_bytes_read / 1024.0 / 1024.0) [Total MB Read], 
    (fs.num_of_bytes_written / 1024.0 / 1024.0) AS [Total MB Written], 
    (fs.num_of_reads + fs.num_of_writes) AS [Total I/O Count], 
    fs.io_stall AS [Total I/O Wait Time (ms)], 
    fs.size_on_disk_bytes / 1024 / 1024 AS [Size (MB)]
FROM sys.dm_io_virtual_file_stats(default, default) AS fs
INNER JOIN sys.master_files f ON fs.database_id = f.database_id AND fs.file_id = f.file_id
INNER JOIN sys.databases d ON d.database_id = fs.database_id; 

-- Get the timestamp of the previous collection time
DECLARE @previous_collection_time datetime;
SELECT TOP 1 @previous_collection_time = collection_time 
FROM #am_dbfilestats 
WHERE collection_time < @current_collection_time
ORDER BY collection_time DESC;

DECLARE @interval_ms int;
SET @interval_ms = DATEDIFF (millisecond, @previous_collection_time, @current_collection_time); 

-- Return the diff of this snapshot and last
SELECT 
    cur.[Database], 
    cur.[File] AS [File Name], 
    CONVERT (numeric(28,1), (cur.[Total MB Read] - prev.[Total MB Read]) * 1000 / @interval_ms) AS [MB/sec Read], 
    CONVERT (numeric(28,1), (cur.[Total MB Written] - prev.[Total MB Written]) * 1000 / @interval_ms) AS [MB/sec Written], 
    -- protect from div-by-zero
    CASE 
        WHEN (cur.[Total I/O Count] - prev.[Total I/O Count]) = 0 THEN 0
        ELSE
            (cur.[Total I/O Wait Time (ms)] - prev.[Total I/O Wait Time (ms)]) 
                / (cur.[Total I/O Count] - prev.[Total I/O Count])
    END AS [Response Time (ms)]
FROM #am_dbfilestats AS cur
INNER JOIN #am_dbfilestats AS prev ON prev.[Database] = cur.[Database] AND prev.[File] = cur.[File]
WHERE cur.collection_time = @current_collection_time 
    AND prev.collection_time = @previous_collection_time;

-- Delete the older snapshot
DELETE FROM #am_dbfilestats
WHERE collection_time != @current_collection_time;

/*****************************************************/
-- 最新のコストの高いクエリ
/*****************************************************/
WITH interval_fingerprint_stats AS
(
    SELECT 
        cur_stats.batch_text, 
        SUBSTRING (
            cur_stats.batch_text, 
            (cur_stats.sample_statement_start_offset/2) + 1, 
            (
                (
                    CASE cur_stats.sample_statement_end_offset 
                        WHEN -1 THEN DATALENGTH(cur_stats.batch_text)
                        WHEN 0 THEN DATALENGTH(cur_stats.batch_text)
                        ELSE cur_stats.sample_statement_end_offset 
                    END 
                    - cur_stats.sample_statement_start_offset
                )/2
            ) + 1
        ) AS statement_text, 
        -- If we don't have a prior snapshot, and if the plan has been around since before the start of the interval, 
        -- amortize the cost of the query over its lifetime so that we don't make the (typically incorrect) assumption 
        -- that the cost was all accumulated within the just-completed interval. 
        CASE 
            WHEN DATEDIFF (second, CASE WHEN (@previous_collection_time IS NULL) OR (prev_stats.plan_fingerprint IS NULL AND cur_stats.creation_time < @previous_collection_time) THEN cur_stats.creation_time ELSE @previous_collection_time END, @current_collection_time) > 0
            THEN DATEDIFF (second, CASE WHEN (@previous_collection_time IS NULL) OR (prev_stats.plan_fingerprint IS NULL AND cur_stats.creation_time < @previous_collection_time) THEN cur_stats.creation_time ELSE @previous_collection_time END, @current_collection_time)
            ELSE 1 -- protect from divide by zero
        END AS interval_duration_sec, 
        cur_stats.query_fingerprint, 
        cur_stats.plan_fingerprint, 
        cur_stats.sample_sql_handle, 
        cur_stats.sample_plan_handle, 
        cur_stats.sample_statement_start_offset, 
        cur_stats.sample_statement_end_offset, 
        cur_stats.plan_count, 
        -- If a plan is removed from cache, then reinserted, it is possible for it to seem to have negative cost.  The 
        -- CASE statements below handle this scenario. 
        CASE WHEN (cur_stats.execution_count - ISNULL (prev_stats.execution_count, 0)) < 0 
            THEN cur_stats.execution_count 
            ELSE (cur_stats.execution_count - ISNULL (prev_stats.execution_count, 0)) 
        END AS interval_executions, 
        cur_stats.execution_count AS total_executions, 
        CASE WHEN (cur_stats.total_worker_time_ms - ISNULL (prev_stats.total_worker_time_ms, 0)) < 0 
            THEN cur_stats.total_worker_time_ms
            ELSE (cur_stats.total_worker_time_ms - ISNULL (prev_stats.total_worker_time_ms, 0)) 
        END AS interval_cpu_ms, 
        CASE WHEN (cur_stats.total_physical_reads - ISNULL (prev_stats.total_physical_reads, 0)) < 0 
            THEN cur_stats.total_physical_reads
            ELSE (cur_stats.total_physical_reads - ISNULL (prev_stats.total_physical_reads, 0)) 
        END AS interval_physical_reads, 
        CASE WHEN (cur_stats.total_logical_writes - ISNULL (prev_stats.total_logical_writes, 0)) < 0 
            THEN cur_stats.total_logical_writes 
            ELSE (cur_stats.total_logical_writes - ISNULL (prev_stats.total_logical_writes, 0)) 
        END AS interval_logical_writes, 
        CASE WHEN (cur_stats.total_logical_reads - ISNULL (prev_stats.total_logical_reads, 0)) < 0 
            THEN cur_stats.total_logical_reads 
            ELSE (cur_stats.total_logical_reads - ISNULL (prev_stats.total_logical_reads, 0)) 
        END AS interval_logical_reads, 
        CASE WHEN (cur_stats.total_elapsed_time_ms - ISNULL (prev_stats.total_elapsed_time_ms, 0)) < 0 
            THEN cur_stats.total_elapsed_time_ms 
            ELSE (cur_stats.total_elapsed_time_ms - ISNULL (prev_stats.total_elapsed_time_ms, 0)) 
        END AS interval_elapsed_time_ms, 
        cur_stats.total_completed_execution_time_ms AS total_completed_execution_time_ms,
        cur_stats.dbname
    FROM #am_fingerprint_stats_snapshots AS cur_stats
    LEFT OUTER JOIN #am_fingerprint_stats_snapshots AS prev_stats
        ON prev_stats.collection_time = @previous_collection_time
        AND prev_stats.plan_fingerprint = cur_stats.plan_fingerprint AND prev_stats.query_fingerprint = cur_stats.query_fingerprint
    WHERE cur_stats.collection_time = @current_collection_time
)
SELECT 
    SUBSTRING (statement_text, 1, 200) AS [Query], 
    /* Begin hidden grid columns */
    statement_text, 
    -- We must convert these to a hex string representation because they will be stored in a DataGridView, which can't  
    -- handle binary cell values (assumes anything binary is an image) 
    master.dbo.fn_varbintohexstr(query_fingerprint) AS query_fingerprint, 
    master.dbo.fn_varbintohexstr(plan_fingerprint) AS plan_fingerprint,     
    master.dbo.fn_varbintohexstr(sample_sql_handle) AS sample_sql_handle,   
    master.dbo.fn_varbintohexstr(sample_plan_handle) AS sample_plan_handle, 
    sample_statement_start_offset,
    sample_statement_end_offset,  
    /* End hidden grid columns */
    interval_executions * 60 / interval_duration_sec AS [Executions/min], 
    interval_cpu_ms / interval_duration_sec AS [CPU (ms/sec)], 
    interval_physical_reads / interval_duration_sec AS [Physical Reads/sec], 
    interval_logical_writes / interval_duration_sec AS [Logical Writes/sec], 
    interval_logical_reads / interval_duration_sec AS [Logical Reads/sec], 
    CASE total_executions 
        WHEN 0 THEN 0
        ELSE total_completed_execution_time_ms / total_executions 
    END AS [Average Duration (ms)], 
    plan_count AS [Plan Count], 
    dbname AS [Database Name]
FROM interval_fingerprint_stats

/*****************************************************/
-- アクティブなコストの高いクエリ
/*****************************************************/
WITH profiled_sessions as (
	SELECT DISTINCT session_id profiled_session_id from sys.dm_exec_query_profiles
)
SELECT TOP 10 SUBSTRING(qt.TEXT, (er.statement_start_offset/2)+1,
((CASE er.statement_end_offset
WHEN -1 THEN DATALENGTH(qt.TEXT)
ELSE er.statement_end_offset
END - er.statement_start_offset)/2)+1) as [Query],
er.session_id as [Session Id],
er.cpu_time as [CPU (ms/sec)],
db.name as [Database Name],
er.total_elapsed_time as [Elapsed Time],
er.reads as [Reads],
er.writes as [Writes],
er.logical_reads as [Logical Reads],
er.row_count as [Row Count],
mg.granted_memory_kb as [Allocated Memory],
mg.used_memory_kb as [Used Memory],
mg.required_memory_kb as [Required Memory],
/* We must convert these to a hex string representation because they will be stored in a DataGridView, which can't handle binary cell values (assumes anything binary is an image) */
master.dbo.fn_varbintohexstr(er.plan_handle) AS [sample_plan_handle], 
er.statement_start_offset as [sample_statement_start_offset],
er.statement_end_offset as [sample_statement_end_offset],
profiled_session_id as [Profiled Session Id]
FROM 
sys.dm_exec_requests er
LEFT OUTER JOIN sys.dm_exec_query_memory_grants mg 
	ON er.session_id = mg.session_id
LEFT OUTER JOIN profiled_sessions
	ON profiled_session_id = er.session_id
CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) qt,
sys.databases db
WHERE db.database_id = er.database_id
AND er.session_id  <> @@spid
