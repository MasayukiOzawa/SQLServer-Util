-- https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-query-store-wait-stats-transact-sql

SELECT
    *
FROM
(
SELECT
    wait_time_ms,
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
sys.dm_os_wait_stats
) AS T
PIVOT(
    SUM(wait_time_ms)
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
OPTION(RECOMPILE, MAXDOP 1)