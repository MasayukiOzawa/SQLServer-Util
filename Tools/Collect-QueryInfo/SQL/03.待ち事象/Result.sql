SELECT
	*
FROM(
	SELECT
		server_name,
		db_name,
		DATEADD(HOUR, 9, collect_date) AS [time],
		wait_type,
		COALESCE(
			waiting_tasks_count - 
			LAG(waiting_tasks_count) OVER (PARTITION BY server_name, db_name, wait_type ORDER BY collect_date ASC) 
		, 0)
		AS waiting_tasks_count_diff,
		COALESCE(
			wait_time_ms - 
			LAG(wait_time_ms) OVER (PARTITION BY server_name, db_name, wait_type ORDER BY collect_date ASC) 
		, 0)
		AS wait_time_ms_diff,
		COALESCE(
			signal_wait_time_ms - 
			LAG(signal_wait_time_ms) OVER (PARTITION BY server_name, db_name, wait_type ORDER BY collect_date ASC) 
		, 0)
		AS signal_wait_time_ms_diff,
		max_wait_time_ms
	FROM
		[02_WaitStats]
	WHERE
	Wait_type Not IN(
		'BROKER_TASK_STOP',
		'BROKER_TO_FLUSH',
		'CHECKPOINT_QUEUE',
		'DIRTY_PAGE_POLL',
		'FT_IFTS_SCHEDULER_IDLE_WAIT',
		'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
		'LAZYWRITER_SLEEP',
		'LOGMGR_QUEUE',
		'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
		'REQUEST_FOR_DEADLOCK_SEARCH',
		'SLEEP_TASK',
		'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
		'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
		'XE_DISPATCHER_WAIT',
		'XE_TIMER_EVENT',
		'SP_SERVER_DIAGNOSTICS_SLEEP',
		'CLR_AUTO_EVENT'
	)
) AS T
WHERE
	waiting_tasks_count_diff > 0
ORDER BY
	[time] ASC,
	wait_type ASC