SET NOCOUNT ON
GO

/*********************************************/
-- ロック情報の取得
/*********************************************/
SELECT DISTINCT
   [Session ID]    = s.session_id, 
   [User Process]  = CONVERT(CHAR(1), s.is_user_process),
   [Login]         = s.login_name,   
   [Database]      = ISNULL(db_name(p.dbid), N''), 
   [Task State]    = ISNULL(t.task_state, N''), 
   [Command]       = ISNULL(r.command, N''), 
   resource_associated_entity_id, 
   [Resource Type] = ISNULL(l.resource_type, N''), 
   [Lock Mode] = ISNULL(l.request_mode, N''),
   [Lock Type] = ISNULL(l.request_type, N''), 
   [Application]   = ISNULL(s.program_name, N''), 
   [Wait Time (ms)]     = ISNULL(w.wait_duration_ms, 0),
   [Wait Type]     = ISNULL(w.wait_type, N''),
   [Wait Resource] = ISNULL(w.resource_description, N''), 
   [Blocked By]    = ISNULL(CONVERT (varchar, w.blocking_session_id), ''),
   [Head Blocker]  = 
        CASE 
            WHEN r2.session_id IS NOT NULL AND (r.blocking_session_id = 0 OR r.session_id IS NULL) THEN '1' 
            ELSE ''
        END, 
   [Total CPU (ms)] = s.cpu_time, 
   [Total Physical I/O (MB)]   = (s.reads + s.writes) * 8 / 1024, 
   [Memory Use (KB)]  = s.memory_usage * 8192 / 1024, 
   [Open Transactions] = ISNULL(r.open_transaction_count,0), 
   [Login Time]    = s.login_time, 
   [Last Request Start Time] = s.last_request_start_time,
   [Host Name]     = ISNULL(s.host_name, N''),
   [Net Address]   = ISNULL(c.client_net_address, N''), 
   [Execution Context ID] = ISNULL(t.exec_context_id, 0),
   [Request ID] = ISNULL(r.request_id, 0),
   [Workload Group] = N''
FROM 
	[sys].[dm_exec_sessions] [s]  WITH (NOLOCK) 
	LEFT OUTER JOIN 
		[sys].[dm_exec_connections] [c] WITH (NOLOCK)
	ON
		([s].[session_id] = [c].[session_id])
	LEFT OUTER JOIN
		[sys].[dm_exec_requests] [r]  WITH (NOLOCK)
	ON
		([s].[session_id] = [r].[session_id])
	LEFT OUTER JOIN
		[sys].[dm_os_tasks] [t] WITH (NOLOCK)
	ON 
		([r].[session_id] = [t].[session_id]
		AND
		[r].[request_id] = [t].[request_id])
	LEFT OUTER JOIN 
	(
    SELECT 
		*, 
		ROW_NUMBER() OVER (PARTITION BY waiting_task_address ORDER BY wait_duration_ms DESC) AS row_num
    FROM 
		[sys].[dm_os_waiting_tasks] 
	) [w] 
	ON 
		([t].[task_address] = [w].[waiting_task_address]) 
		AND [w].[row_num] = 1
	LEFT OUTER JOIN
		[sys].[dm_exec_requests] [r2] WITH (NOLOCK)
	ON 
		([s].[session_id] = [r2].[blocking_session_id])
	LEFT OUTER JOIN 
		[sys].[sysprocesses] [p] WITH (NOLOCK)
	ON 
		([s].[session_id] = [p].[spid])
	LEFT OUTER JOIN 
		[sys].[dm_tran_locks] [l] WITH (NOLOCK)
	ON ([s].[session_id] = [l].[request_session_id])
WHERE
	[s].[session_id] > 50
ORDER BY
	[s].[session_id]
OPTION (RECOMPILE)

-- ブロッキング発生時にチェック 
-- DBCC INPUTBUFFER (53) (Blocked BY が発生している Session ID)
-- DBCC INPUTBUFFER (53) (Blocked BY の Session ID)
-- SELECT * FROM sys.partitions WHERE hobt_id = <resource_associated_entity_id>

