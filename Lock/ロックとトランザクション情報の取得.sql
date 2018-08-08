-- ロック情報をベースとしたトランザクションの取得
SELECT
	er.blocking_session_id,
	tl.request_session_id,
	ec.protocol_type,
	SUBSTRING(CONVERT(BINARY(4),ec.protocol_version),1,1) AS tds_version,
	es.client_version,
	CASE es.transaction_isolation_level
		WHEN 0 THEN 'Unspecified'
		WHEN 1 THEN 'ReadUncomitted'
		WHEN 2 THEN 'ReadCommitted'
		WHEN 3 THEN 'Repeatable'
		WHEN 4 THEN 'Serializable'
		WHEN 5 THEN 'Snapshot'
	END AS transaction_isolation_level,
		es.host_name,
	ec.client_net_address,
	es.program_name,
	es.client_interface_name,
	er.command,
	er.status,
	DB_NAME(tl.resource_database_id) resource_database_name,
	tl.request_status,
	tl.resource_type,
	CASE 
		WHEN DB_ID() <> resource_database_id THEN NULL
		WHEN resource_type = 'OBJECT' THEN o.name
		ELSE NULL
	END AS object_name,
	tl.request_mode,
	tl.resource_description,
	tl.resource_subtype,
	tl.request_owner_type,
	er.cpu_time,
	er.total_elapsed_time,
	er.wait_type,
	er.last_wait_type,
	er.lock_timeout,
	tat.name AS transaction_name,
	tat.transaction_begin_time,
	CASE tat.transaction_type
		WHEN 1 THEN N'読み取り/書き込み'
		WHEN 2 THEN N'読み取り専用'
		WHEN 3 THEN N'システム'
		WHEN 4 THEN N'分散トランザクション'
		ELSE CAST(tat.transaction_type AS nvarchar(50))
	END AS transaction_type,
	CASE tat.transaction_state
		WHEN 1 THEN N'初期化待ち'
		WHEN 1 THEN N'開始待ち'
		WHEN 2 THEN N'アクティブ'
		WHEN 3 THEN N'終了'
		WHEN 4 THEN N'分散トランザクションコミット開始'
		WHEN 5 THEN N'解決待ち'
		WHEN 6 THEN N'コミット完了'
		WHEN 7 THEN N'ロールバック中'
		WHEN 8 THEN N'ロールバック完了'
		ELSE CAST(tat.transaction_type AS nvarchar(50))
	END AS transaction_state,
    SUBSTRING(est.text, (er.statement_start_offset/2)+1,   
        ((CASE er.statement_end_offset  
          WHEN -1 THEN DATALENGTH(est.text)  
         ELSE er.statement_end_offset  
         END - er.statement_start_offset)/2) + 1) AS statement_text,
	est.text
FROM 
	sys.dm_tran_locks AS tl WITH(NOLOCK)
	LEFT JOIN sys.dm_exec_requests AS er WITH(NOLOCK)
		ON er.session_id = tl.request_session_id
	LEFT JOIN sys.objects AS o WITH(NOLOCK)
		ON o.object_id = tl.resource_associated_entity_id
	OUTER APPLY	sys.dm_exec_sql_text (er.sql_handle) AS est
	LEFT JOIN sys.dm_exec_sessions AS es WITH(NOLOCK)
		ON es.session_id = tl.request_session_id 
	LEFT JOIN sys.dm_tran_active_transactions AS tat WITH (NOLOCK)
		ON tat.transaction_id = tl.request_owner_id
	LEFT JOIN sys.dm_exec_connections AS ec WITH (NOLOCK)
		ON ec.session_id = tl.request_session_id
WHERE
	tl.request_session_id <> @@SPID
ORDER BY
	tl.request_session_id,
	tl.request_status,
	tl.request_mode,
	tl.resource_type
OPTION (RECOMPILE)
GO
