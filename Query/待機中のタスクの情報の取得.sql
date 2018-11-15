SELECT 
	wt.session_id,
	er.status,
	er.command,
	es.login_name,
	er.start_time,
	at.transaction_begin_time,
	datediff(MILLISECOND,  er.start_time, GETDATE()) AS elapsed_time_ms,
	datediff(MILLISECOND, at.transaction_begin_time, GETDATE()) AS transaction_elapsed_time_ms,
	er.wait_time,
	wt.wait_duration_ms,
	er.open_transaction_count,
	CASE at.transaction_type
		WHEN 1 THEN N'読み取り/書き込み'
		WHEN 2 THEN N'読み取り専用'
		WHEN 3 THEN N'システム'
		WHEN 4 THEN N'分散トランザクション'
		ELSE CAST(at.transaction_type AS nvarchar(50))
	END AS transaction_type,
	CASE at.transaction_state
		WHEN 1 THEN N'初期化待ち'
		WHEN 1 THEN N'開始待ち'
		WHEN 2 THEN N'アクティブ'
		WHEN 3 THEN N'終了'
		WHEN 4 THEN N'分散トランザクションコミット開始'
		WHEN 5 THEN N'解決待ち'
		WHEN 6 THEN N'コミット完了'
		WHEN 7 THEN N'ロールバック中'
		WHEN 8 THEN N'ロールバック完了'
		ELSE CAST(at.transaction_type AS nvarchar(50))
	END AS transaction_state,	at.dtc_state,
	at.dtc_status,
	er.transaction_id,
	CASE er.transaction_isolation_level
		WHEN 0 THEN 'Unspecified' 
		WHEN 1 THEN 'ReadUncommitted' 
		WHEN 2 THEN 'ReadCommitted' 
		WHEN 3 THEN 'Repeatable' 
		WHEN 4 THEN 'Serializable' 
		WHEN 5 THEN 'Snapshot' 
		ELSE CAST(er.transaction_isolation_level AS varchar(1))
	END AS transaction_isolation_level ,
	er.wait_type,
	er.last_wait_type,
	er.wait_resource,
	wt.resource_description,
	DB_NAME(er.database_id) AS database_name,
	wt.blocking_session_id AS wt_blocking_session_id,
	er.blocking_session_id AS er_blocking_session_id,
	es.host_name,
	es.program_name,
	es.login_name,
	es.client_interface_name,
	last_request_start_time,
	last_request_end_time,
	SUBSTRING(st.text, (er.statement_start_offset/2)+1,   
	((CASE er.statement_end_offset  
		WHEN -1 THEN DATALENGTH(st.text)  
		ELSE er.statement_end_offset  
		END - er.statement_start_offset)/2) + 1) AS statement_text ,
	st.text,
	qp.query_plan
FROM
	sys.dm_os_waiting_tasks AS wt
	LEFT JOIN sys.dm_exec_requests AS er ON	wt.session_id = er.session_id
	LEFT JOIN sys.dm_tran_active_transactions AS at ON at.transaction_id = er.transaction_id
	LEFT JOIN sys.dm_exec_sessions AS es ON es.session_id = er.session_id
	OUTER APPLY sys.dm_exec_query_plan(er.plan_handle) AS qp
	OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) AS st
ORDER BY
	wt.session_id