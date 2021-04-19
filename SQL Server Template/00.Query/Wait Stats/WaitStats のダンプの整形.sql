WITH wait_time
AS
(
    SELECT
        ROW_NUMBER() OVER (ORDER BY collect_date ASC) AS no,
        collect_date,
        [backup] - LAG([backup],1,0) OVER(ORDER BY collect_date ASC) AS [backup_time],
        [buffer_io] - LAG([buffer_io],1,0) OVER(ORDER BY collect_date ASC) AS [buffer_io_time],
        [buffer_latch] - LAG([buffer_latch],1,0) OVER(ORDER BY collect_date ASC) AS [buffer_latch_time],
        [compilation] - LAG([compilation],1,0) OVER(ORDER BY collect_date ASC) AS [compilation_time],
        [cpu] - LAG([cpu],1,0) OVER(ORDER BY collect_date ASC) AS [cpu_time],
        [full_text_search] - LAG([full_text_search],1,0) OVER(ORDER BY collect_date ASC) AS [full_text_search_time],
        [hs_remote_block_io] - LAG([hs_remote_block_io],1,0) OVER(ORDER BY collect_date ASC) AS [hs_remote_block_io_time],
        [latch] - LAG([latch],1,0) OVER(ORDER BY collect_date ASC) AS [latch_time],
        [lock] - LAG([lock],1,0) OVER(ORDER BY collect_date ASC) AS [lock_time],
        [log_rate_governor] - LAG([log_rate_governor],1,0) OVER(ORDER BY collect_date ASC) AS [log_rate_governor_time],
        [memory] - LAG([memory],1,0) OVER(ORDER BY collect_date ASC) AS [memory_time],
        [mirroring] - LAG([mirroring],1,0) OVER(ORDER BY collect_date ASC) AS [mirroring_time],
        [network_io] - LAG([network_io],1,0) OVER(ORDER BY collect_date ASC) AS [network_io_time],
        [other_disk_io] - LAG([other_disk_io],1,0) OVER(ORDER BY collect_date ASC) AS [other_disk_io_time],
        [parallelism] - LAG([parallelism],1,0) OVER(ORDER BY collect_date ASC) AS [parallelism_time],
        [preemptive] - LAG([preemptive],1,0) OVER(ORDER BY collect_date ASC) AS [preemptive_time],
        [replication] - LAG([replication],1,0) OVER(ORDER BY collect_date ASC) AS [replication_time],
        [service_broker] - LAG([service_broker],1,0) OVER(ORDER BY collect_date ASC) AS [service_broker_time],
        [sql_clr] - LAG([sql_clr],1,0) OVER(ORDER BY collect_date ASC) AS [sql_clr_time],
        [tracing] - LAG([tracing],1,0) OVER(ORDER BY collect_date ASC) AS [tracing_time],
        [tran_log_io] - LAG([tran_log_io],1,0) OVER(ORDER BY collect_date ASC) AS [tran_log_io_time],
        [transaction] - LAG([transaction],1,0) OVER(ORDER BY collect_date ASC) AS [transaction_time],
        [worker_thread] - LAG([worker_thread],1,0) OVER(ORDER BY collect_date ASC) AS [worker_thread_time],
        [idle] - LAG([idle],1,0) OVER(ORDER BY collect_date ASC) AS [idle_time],
        [user_wait] - LAG([user_wait],1,0) OVER(ORDER BY collect_date ASC) AS [user_wait_time],
        [unknown] - LAG([unknown],1,0) OVER(ORDER BY collect_date ASC) AS [unknown_time]
        FROM
    (
    SELECT
        collect_date,
        wait_time_ms,
        -- waiting_tasks_count,
        CASE
            WHEN wait_type = 'SOS_SCHEDULER_YIELD' THEN 'cpu'
            WHEN wait_type = 'THREADPOOL' THEN 'worker_thread'
            WHEN wait_type LIKE 'LCK_M_%' THEN 'lock'
            WHEN wait_type LIKE 'LATCH_%' THEN 'latch'
            WHEN wait_type LIKE 'PAGELATCH_%' THEN 'buffer_latch'
            WHEN wait_type LIKE 'PAGEIOLATCH_%' THEN 'buffer_io'
            WHEN wait_type ='RESOURCE_SEMAPHORE_QUERY_COMPILE' THEN 'compilation'
            WHEN wait_type LIKE 'CLR%' or wait_type LIKE 'SQLCLR%' THEN 'sql_clr'
            WHEN wait_type LIKE 'DBMIRROR%' THEN 'mirroring'
            WHEN wait_type LIKE 'XACT%'
                    OR wait_type LIKE 'DTC%'
                    OR wait_type LIKE 'TRAN_MARKLATCH_%'
                    OR wait_type LIKE 'MSQL_XACT_%'
                    OR wait_type = 'TRANSACTION_MUTEX' THEN 'transaction'
            WHEN wait_type LIKE 'SLEEP_%'
                    OR wait_type IN(
                                'LAZYWRITER_SLEEP',
                                'SQLTRACE_BUFFER_FLUSH',
                                'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
                                'SQLTRACE_WAIT_ENTRIES',
                                'FT_IFTS_SCHEDULER_IDLE_WAIT',
                                'XE_DISPATCHER_WAIT',
                                'REQUEST_FOR_DEADLOCK_SEARCH',
                                'LOGMGR_QUEUE',
                                'ONDEMAND_TASK_QUEUE',
                                'CHECKPOINT_QUEUE',
                                'XE_TIMER_EVENT'
                            ) THEN 'idle'
            WHEN wait_type LIKE 'PREEMPTIVE_%' THEN 'preemptive'
            WHEN wait_type LIKE 'BROKER_%'
                    AND wait_type <> 'BROKER_RECEIVE_WAITFOR' THEN 'service_broker'
            WHEN wait_type IN(
                                'LOGMGR',
                                'LOGBUFFER',
                                'LOGMGR_RESERVE_APPEND',
                                'LOGMGR_FLUSH',
                                'LOGMGR_PMM_LOG',
                                'CHKPT',
                                'WRITELOG'
                            ) THEN 'tran_log_io'
            WHEN wait_type IN(
                                'ASYNC_NETWORK_IO',
                                'NET_WAITFOR_PACKET',
                                'PROXY_NETWORK_IO',
                                'EXTERNAL_SCRIPT_NETWORK_IOF') THEN 'network_io'
            WHEN wait_type IN(
                                'CXPACKET',
                                'CXSYNC_CONSUMER',
                                'CXSYNC_PORT',
                                'CXCONSUMER',
                                'CXROWSET_SYNC',
                                'EXCHANGE'
                            ) THEN 'parallelism'
            WHEN wait_type IN(
                                'RESOURCE_SEMAPHORE',
                                'CMEMTHREAD',
                                'CMEMPARTITIONED',
                                'EE_PMOLOCK',
                                'MEMORY_ALLOCATION_EXT',
                                'RESERVED_MEMORY_ALLOCATION_EXT',
                                'MEMORY_GRANT_UPDATE'
                            ) THEN 'memory'
            WHEN wait_type IN(
                                'WAITFOR',
                                'WAIT_FOR_RESULTS',
                                'BROKER_RECEIVE_WAITFOR'
                            ) THEN 'user_wait'
            WHEN wait_type IN(
                                'TRACEWRITE',
                                'SQLTRACE_LOCK',
                                'SQLTRACE_FILE_BUFFER',
                                'SQLTRACE_FILE_WRITE_IO_COMPLETION',
                                'SQLTRACE_FILE_READ_IO_COMPLETION',
                                'SQLTRACE_PENDING_BUFFER_WRITERS',
                                'SQLTRACE_SHUTDOWN',
                                'QUERY_TRACEOUT',
                                'TRACE_EVTNOTIFF'
                            ) THEN 'tracing'
            WHEN wait_type IN(
                                'FT_RESTART_CRAWL',
                                'FULLTEXT GATHERER',
                                'MSSEARCH',
                                'FT_METADATA_MUTEX',
                                'FT_IFTSHC_MUTEX',
                                'FT_IFTSISM_MUTEX',
                                'FT_IFTS_RWLOCK',
                                'FT_COMPROWSET_RWLOCK',
                                'FT_MASTER_MERGE',
                                'FT_PROPERTYLIST_CACHE',
                                'FT_MASTER_MERGE_COORDINATOR',
                                'PWAIT_RESOURCE_SEMAPHORE_FT_PARALLEL_QUERY_SYNC'
                            ) THEN 'full_text_search'
            WHEN wait_type IN(
                                'ASYNC_IO_COMPLETION',
                                'IO_COMPLETION',
                                'BACKUPIO',
                                'WRITE_COMPLETION',
                                'IO_QUEUE_LIMIT',
                                'IO_RETRY'
                                ) THEN 'other_disk_io'
            WHEN wait_type LIKE 'SE_REPL_%' 
                    OR (wait_type LIKE 'HADR%' AND wait_type <> 'HADR_THROTTLE_LOG_RATE_GOVERNOR')
                    OR wait_type LIKE 'PWAIT_HADR_%'
                    OR wait_type LIKE 'REPL_%'
                    OR wait_type IN(
                                'REPLICA_WRITES',
                                'FCB_REPLICA_WRITE',
                                'FCB_REPLICA_READ',
                                'PWAIT_HADRSIM'
                            ) THEN 'replication'
            WHEN wait_type IN(
                                'LOG_RATE_GOVERNOR',
                                'POOL_LOG_RATE_GOVERNOR',
                                'HADR_THROTTLE_LOG_RATE_GOVERNOR',
                                'INSTANCE_LOG_RATE_GOVERNOR'
                            ) THEN 'log_rate_governor'
            WHEN wait_type LIKE 'BACKUP%' AND wait_type <> 'BACKUPBUFFER' THEN 'backup'
            WHEN wait_Type LIKE 'WAIT_RBIO%' THEN 'hs_remote_block_io'
            ELSE 'unknown'
        END AS wait_category
    FROM
    dm_os_wait_stats_dump_20210101_error
    ) AS T
    PIVOT(
        SUM(wait_time_ms)
        -- SUM(waiting_tasks_count)
        FOR wait_category
       IN(
            [backup],
            [buffer_io],
            [buffer_latch],
            [compilation],
            [cpu],
            [full_text_search],
            [hs_remote_block_io],
            [latch],
            [lock],
            [log_rate_governor],
            [memory],
            [mirroring],
            [network_io],
            [other_disk_io],
            [parallelism],
            [preemptive],
            [replication],
            [service_broker],
            [sql_clr],
            [tracing],
            [tran_log_io],
            [transaction],
            [worker_thread],
            [idle],
            [user_wait],
            [unknown]
        )
    ) AS PVT
)
,wait_count
AS
(
    SELECT
        ROW_NUMBER() OVER (ORDER BY collect_date ASC) AS no,
        collect_date,
        [backup] - LAG([backup],1,0) OVER(ORDER BY collect_date ASC) AS [backup_count],
        [buffer_io] - LAG([buffer_io],1,0) OVER(ORDER BY collect_date ASC) AS [buffer_io_count],
        [buffer_latch] - LAG([buffer_latch],1,0) OVER(ORDER BY collect_date ASC) AS [buffer_latch_count],
        [compilation] - LAG([compilation],1,0) OVER(ORDER BY collect_date ASC) AS [compilation_count],
        [cpu] - LAG([cpu],1,0) OVER(ORDER BY collect_date ASC) AS [cpu_count],
        [full_text_search] - LAG([full_text_search],1,0) OVER(ORDER BY collect_date ASC) AS [full_text_search_count],
        [hs_remote_block_io] - LAG([hs_remote_block_io],1,0) OVER(ORDER BY collect_date ASC) AS [hs_remote_block_io_count],
        [latch] - LAG([latch],1,0) OVER(ORDER BY collect_date ASC) AS [latch_count],
        [lock] - LAG([lock],1,0) OVER(ORDER BY collect_date ASC) AS [lock_count],
        [log_rate_governor] - LAG([log_rate_governor],1,0) OVER(ORDER BY collect_date ASC) AS [log_rate_governor_count],
        [memory] - LAG([memory],1,0) OVER(ORDER BY collect_date ASC) AS [memory_count],
        [mirroring] - LAG([mirroring],1,0) OVER(ORDER BY collect_date ASC) AS [mirroring_count],
        [network_io] - LAG([network_io],1,0) OVER(ORDER BY collect_date ASC) AS [network_io_count],
        [other_disk_io] - LAG([other_disk_io],1,0) OVER(ORDER BY collect_date ASC) AS [other_disk_io_count],
        [parallelism] - LAG([parallelism],1,0) OVER(ORDER BY collect_date ASC) AS [parallelism_count],
        [preemptive] - LAG([preemptive],1,0) OVER(ORDER BY collect_date ASC) AS [preemptive_count],
        [replication] - LAG([replication],1,0) OVER(ORDER BY collect_date ASC) AS [replication_count],
        [service_broker] - LAG([service_broker],1,0) OVER(ORDER BY collect_date ASC) AS [service_broker_count],
        [sql_clr] - LAG([sql_clr],1,0) OVER(ORDER BY collect_date ASC) AS [sql_clr_count],
        [tracing] - LAG([tracing],1,0) OVER(ORDER BY collect_date ASC) AS [tracing_count],
        [tran_log_io] - LAG([tran_log_io],1,0) OVER(ORDER BY collect_date ASC) AS [tran_log_io_count],
        [transaction] - LAG([transaction],1,0) OVER(ORDER BY collect_date ASC) AS [transaction_count],
        [worker_thread] - LAG([worker_thread],1,0) OVER(ORDER BY collect_date ASC) AS [worker_thread_count],
        [idle] - LAG([idle],1,0) OVER(ORDER BY collect_date ASC) AS [idle_count],
        [user_wait] - LAG([user_wait],1,0) OVER(ORDER BY collect_date ASC) AS [user_wait_count],
        [unknown] - LAG([unknown],1,0) OVER(ORDER BY collect_date ASC) AS [unknown_count]
        FROM
    (
    SELECT
        collect_date,
        waiting_tasks_count,
        CASE
            WHEN wait_type = 'SOS_SCHEDULER_YIELD' THEN 'cpu'
            WHEN wait_type = 'THREADPOOL' THEN 'worker_thread'
            WHEN wait_type LIKE 'LCK_M_%' THEN 'lock'
            WHEN wait_type LIKE 'LATCH_%' THEN 'latch'
            WHEN wait_type LIKE 'PAGELATCH_%' THEN 'buffer_latch'
            WHEN wait_type LIKE 'PAGEIOLATCH_%' THEN 'buffer_io'
            WHEN wait_type ='RESOURCE_SEMAPHORE_QUERY_COMPILE' THEN 'compilation'
            WHEN wait_type LIKE 'CLR%' or wait_type LIKE 'SQLCLR%' THEN 'sql_clr'
            WHEN wait_type LIKE 'DBMIRROR%' THEN 'mirroring'
            WHEN wait_type LIKE 'XACT%'
                    OR wait_type LIKE 'DTC%'
                    OR wait_type LIKE 'TRAN_MARKLATCH_%'
                    OR wait_type LIKE 'MSQL_XACT_%'
                    OR wait_type = 'TRANSACTION_MUTEX' THEN 'transaction'
            WHEN wait_type LIKE 'SLEEP_%'
                    OR wait_type IN(
                                'LAZYWRITER_SLEEP',
                                'SQLTRACE_BUFFER_FLUSH',
                                'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
                                'SQLTRACE_WAIT_ENTRIES',
                                'FT_IFTS_SCHEDULER_IDLE_WAIT',
                                'XE_DISPATCHER_WAIT',
                                'REQUEST_FOR_DEADLOCK_SEARCH',
                                'LOGMGR_QUEUE',
                                'ONDEMAND_TASK_QUEUE',
                                'CHECKPOINT_QUEUE',
                                'XE_TIMER_EVENT'
                            ) THEN 'idle'
            WHEN wait_type LIKE 'PREEMPTIVE_%' THEN 'preemptive'
            WHEN wait_type LIKE 'BROKER_%'
                    AND wait_type <> 'BROKER_RECEIVE_WAITFOR' THEN 'service_broker'
            WHEN wait_type IN(
                                'LOGMGR',
                                'LOGBUFFER',
                                'LOGMGR_RESERVE_APPEND',
                                'LOGMGR_FLUSH',
                                'LOGMGR_PMM_LOG',
                                'CHKPT',
                                'WRITELOG'
                            ) THEN 'tran_log_io'
            WHEN wait_type IN(
                                'ASYNC_NETWORK_IO',
                                'NET_WAITFOR_PACKET',
                                'PROXY_NETWORK_IO',
                                'EXTERNAL_SCRIPT_NETWORK_IOF') THEN 'network_io'
            WHEN wait_type IN(
                                'CXPACKET',
                                'CXSYNC_CONSUMER',
                                'CXSYNC_PORT',
                                'CXCONSUMER',
                                'CXROWSET_SYNC',
                                'EXCHANGE'
                            ) THEN 'parallelism'
            WHEN wait_type IN(
                                'RESOURCE_SEMAPHORE',
                                'CMEMTHREAD',
                                'CMEMPARTITIONED',
                                'EE_PMOLOCK',
                                'MEMORY_ALLOCATION_EXT',
                                'RESERVED_MEMORY_ALLOCATION_EXT',
                                'MEMORY_GRANT_UPDATE'
                            ) THEN 'memory'
            WHEN wait_type IN(
                                'WAITFOR',
                                'WAIT_FOR_RESULTS',
                                'BROKER_RECEIVE_WAITFOR'
                            ) THEN 'user_wait'
            WHEN wait_type IN(
                                'TRACEWRITE',
                                'SQLTRACE_LOCK',
                                'SQLTRACE_FILE_BUFFER',
                                'SQLTRACE_FILE_WRITE_IO_COMPLETION',
                                'SQLTRACE_FILE_READ_IO_COMPLETION',
                                'SQLTRACE_PENDING_BUFFER_WRITERS',
                                'SQLTRACE_SHUTDOWN',
                                'QUERY_TRACEOUT',
                                'TRACE_EVTNOTIFF'
                            ) THEN 'tracing'
            WHEN wait_type IN(
                                'FT_RESTART_CRAWL',
                                'FULLTEXT GATHERER',
                                'MSSEARCH',
                                'FT_METADATA_MUTEX',
                                'FT_IFTSHC_MUTEX',
                                'FT_IFTSISM_MUTEX',
                                'FT_IFTS_RWLOCK',
                                'FT_COMPROWSET_RWLOCK',
                                'FT_MASTER_MERGE',
                                'FT_PROPERTYLIST_CACHE',
                                'FT_MASTER_MERGE_COORDINATOR',
                                'PWAIT_RESOURCE_SEMAPHORE_FT_PARALLEL_QUERY_SYNC'
                            ) THEN 'full_text_search'
            WHEN wait_type IN(
                                'ASYNC_IO_COMPLETION',
                                'IO_COMPLETION',
                                'BACKUPIO',
                                'WRITE_COMPLETION',
                                'IO_QUEUE_LIMIT',
                                'IO_RETRY'
                                ) THEN 'other_disk_io'
            WHEN wait_type LIKE 'SE_REPL_%' 
                    OR (wait_type LIKE 'HADR%' AND wait_type <> 'HADR_THROTTLE_LOG_RATE_GOVERNOR')
                    OR wait_type LIKE 'PWAIT_HADR_%'
                    OR wait_type LIKE 'REPL_%'
                    OR wait_type IN(
                                'REPLICA_WRITES',
                                'FCB_REPLICA_WRITE',
                                'FCB_REPLICA_READ',
                                'PWAIT_HADRSIM'
                            ) THEN 'replication'
            WHEN wait_type IN(
                                'LOG_RATE_GOVERNOR',
                                'POOL_LOG_RATE_GOVERNOR',
                                'HADR_THROTTLE_LOG_RATE_GOVERNOR',
                                'INSTANCE_LOG_RATE_GOVERNOR'
                            ) THEN 'log_rate_governor'
            WHEN wait_type LIKE 'BACKUP%' AND wait_type <> 'BACKUPBUFFER' THEN 'backup'
            WHEN wait_Type LIKE 'WAIT_RBIO%' THEN 'hs_remote_block_io'
            ELSE 'unknown'
        END AS wait_category
    FROM
    dm_os_wait_stats_dump_20210101_error
    ) AS T
    PIVOT(
        SUM(waiting_tasks_count)
        FOR wait_category
       IN(
            [backup],
            [buffer_io],
            [buffer_latch],
            [compilation],
            [cpu],
            [full_text_search],
            [hs_remote_block_io],
            [latch],
            [lock],
            [log_rate_governor],
            [memory],
            [mirroring],
            [network_io],
            [other_disk_io],
            [parallelism],
            [preemptive],
            [replication],
            [service_broker],
            [sql_clr],
            [tracing],
            [tran_log_io],
            [transaction],
            [worker_thread],
            [idle],
            [user_wait],
            [unknown]
        )
    ) AS PVT
)

SELECT
    wt.collect_date,
    [backup_time], [backup_count], CASE WHEN [backup_count] = 0 THEN 0 ELSE [backup_time] / [backup_count] END AS [avg_backup_time],
    [buffer_io_time], [buffer_io_count], CASE WHEN [buffer_io_count] = 0 THEN 0 ELSE [buffer_io_time] / [buffer_io_count] END AS [avg_buffer_io_time],
    [buffer_latch_time], [buffer_latch_count], CASE WHEN [buffer_latch_count] = 0 THEN 0 ELSE [buffer_latch_time] / [buffer_latch_count] END AS [avg_buffer_latch_time],
    [compilation_time], [compilation_count], CASE WHEN [compilation_count] = 0 THEN 0 ELSE [compilation_time] / [compilation_count] END AS [avg_compilation_time],
    [cpu_time], [cpu_count], CASE WHEN [cpu_count] = 0 THEN 0 ELSE [cpu_time] / [cpu_count] END AS [avg_cpu_time],
    [full_text_search_time], [full_text_search_count], CASE WHEN [full_text_search_count] = 0 THEN 0 ELSE [full_text_search_time] / [full_text_search_count] END AS [avg_full_text_search_time],
    [hs_remote_block_io_time], [hs_remote_block_io_count], CASE WHEN [hs_remote_block_io_count] = 0 THEN 0 ELSE [hs_remote_block_io_time] / [hs_remote_block_io_count] END AS [avg_hs_remote_block_io_time],
    [latch_time], [latch_count], CASE WHEN [latch_count] = 0 THEN 0 ELSE [latch_time] / [latch_count] END AS [avg_latch_time],
    [lock_time], [lock_count], CASE WHEN [lock_count] = 0 THEN 0 ELSE [lock_time] / [lock_count] END AS [avg_lock_time],
    [log_rate_governor_time], [log_rate_governor_count], CASE WHEN [log_rate_governor_count] = 0 THEN 0 ELSE [log_rate_governor_time] / [log_rate_governor_count] END AS [avg_log_rate_governor_time],
    [memory_time], [memory_count], CASE WHEN [memory_count] = 0 THEN 0 ELSE [memory_time] / [memory_count] END AS [avg_memory_time],
    [mirroring_time], [mirroring_count], CASE WHEN [mirroring_count] = 0 THEN 0 ELSE [mirroring_time] / [mirroring_count] END AS [avg_mirroring_time],
    [network_io_time], [network_io_count], CASE WHEN [network_io_count] = 0 THEN 0 ELSE [network_io_time] / [network_io_count] END AS [avg_network_io_time],
    [other_disk_io_time], [other_disk_io_count], CASE WHEN [other_disk_io_count] = 0 THEN 0 ELSE [other_disk_io_time] / [other_disk_io_count] END AS [avg_other_disk_io_time],
    [parallelism_time], [parallelism_count], CASE WHEN [parallelism_count] = 0 THEN 0 ELSE [parallelism_time] / [parallelism_count] END AS [avg_parallelism_time],
    [preemptive_time], [preemptive_count], CASE WHEN [preemptive_count] = 0 THEN 0 ELSE [preemptive_time] / [preemptive_count] END AS [avg_preemptive_time],
    [replication_time], [replication_count], CASE WHEN [replication_count] = 0 THEN 0 ELSE [replication_time] / [replication_count] END AS [avg_replication_time],
    [service_broker_time], [service_broker_count], CASE WHEN [service_broker_count] = 0 THEN 0 ELSE [service_broker_time] / [service_broker_count] END AS [avg_service_broker_time],
    [sql_clr_time], [sql_clr_count], CASE WHEN [sql_clr_count] = 0 THEN 0 ELSE [sql_clr_time] / [sql_clr_count] END AS [avg_sql_clr_time],
    [tracing_time], [tracing_count], CASE WHEN [tracing_count] = 0 THEN 0 ELSE [tracing_time] / [tracing_count] END AS [avg_tracing_time],
    [tran_log_io_time], [tran_log_io_count], CASE WHEN [tran_log_io_count] = 0 THEN 0 ELSE [tran_log_io_time] / [tran_log_io_count] END AS [avg_tran_log_io_time],
    [transaction_time], [transaction_count], CASE WHEN [transaction_count] = 0 THEN 0 ELSE [transaction_time] / [transaction_count] END AS [avg_transaction_time],
    [worker_thread_time], [worker_thread_count], CASE WHEN [worker_thread_count] = 0 THEN 0 ELSE [worker_thread_time] / [worker_thread_count] END AS [avg_worker_thread_time],
    [idle_time], [idle_count], CASE WHEN [idle_count] = 0 THEN 0 ELSE [idle_time] / [idle_count] END AS [avg_idle_time],
    [user_wait_time], [user_wait_count], CASE WHEN [user_wait_count] = 0 THEN 0 ELSE [user_wait_time] / [user_wait_count] END AS [avg_user_wait_time],
    [unknown_time], [unknown_count], CASE WHEN [unknown_count] = 0 THEN 0 ELSE [unknown_time] / [unknown_count] END AS [avg_unknown_time]
FROM
    wait_time AS wt
    LEFT JOIN wait_count AS wc
        ON wc.collect_date = wt.collect_date