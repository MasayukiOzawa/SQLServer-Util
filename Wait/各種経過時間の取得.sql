DECLARE @system bit = 0							-- システムセッションを取得 (1: すべてのセッションを取得 / 0 : SPID >= 50 を取得)
DECLARE @elapsed_time_sec int = 1				-- 実行から何秒経過しているクエリを取得するか (0 : すべて)
DECLARE @wait_time_sec int = 1					-- 何秒待機が発生しているクエリを取得するか (0 : すべて)
DECLARE @transaction_elapsed_time_sec int = 1	-- トランザクション開始から何秒経過しているクエリを取得するか (0 : すべて)

SELECT * FROM(
SELECT 
	es.session_id,
	es.program_name,
	es.status,
	er.command,
	
	er.blocking_session_id,

	er.wait_type,
	er.last_wait_type,
	er.wait_resource,
	sp.open_tran,

	CASE er.start_time
		WHEN NULL THEN NULL
		ELSE COALESCE(DATEDIFF(SECOND, er.start_time, GETDATE()), 0) 
	END AS elapsed_time_sec, 
	COALESCE(er.wait_time, 0) / 1000 AS wait_time_sec,
	CASE tat.transaction_begin_time
		WHEN NULL THEN NULL
		ELSE COALESCE(DATEDIFF(SECOND, tat.transaction_begin_time, GETDATE()), 0) 
	END AS transaction_begin_elapsed_time_sec, 
	CASE es.login_time
		WHEN NULL THEN NULL
		ELSE COALESCE(DATEDIFF(SECOND, es.login_time, GETDATE()), 0) 
	END AS login_elapsed_time_sec, 
	CASE es.last_request_start_time
		WHEN NULL THEN NULL
		ELSE COALESCE(DATEDIFF(SECOND, es.last_request_start_time, GETDATE()), 0) 
	END AS last_request_start_elapsed_time_sec, 
	CASE es.last_request_end_time
		WHEN NULL THEN NULL
		ELSE COALESCE(DATEDIFF(SECOND, es.last_request_end_time, GETDATE()), 0) 
	END AS last_request_end_elapsed_time_sec, 

	CASE ec.connect_time
		WHEN NULL THEN NULL
		ELSE COALESCE(DATEDIFF(SECOND, ec.connect_time, GETDATE()), 0) 
	END AS connect_time_elapsed_time_sec, 

	CASE ec.last_read
		WHEN NULL THEN NULL
		ELSE COALESCE(DATEDIFF(SECOND, ec.last_read, GETDATE()), 0) 
	END AS last_read_elapsed_time_sec, 

	CASE ec.last_write
		WHEN NULL THEN NULL
		ELSE COALESCE(DATEDIFF(SECOND, ec.last_write, GETDATE()), 0) 
	END AS last_write_elapsed_time_sec, 

	es.login_time,
	es.last_request_start_time,
	es.last_request_end_time,
	er.start_time,
	tat.transaction_begin_time,

	ec.connect_time,
	ec.last_read,
	ec.last_write,
	
	DB_NAME(er.database_id) AS database_name,

	es.host_name,
	es.login_name,

	SUBSTRING(st.text, (er.statement_start_offset/2)+1,   
	((CASE er.statement_end_offset  
		WHEN -1 THEN DATALENGTH(st.text)  
		ELSE er.statement_end_offset  
		END - er.statement_start_offset)/2) + 1) AS statement_text ,
	st.text as st_text,
	ec_st.text AS ec_text,
	qp.query_plan

FROM
	sys.dm_exec_sessions AS es  WITH(NOLOCK)
	LEFT JOIN sys.dm_exec_connections AS ec WITH (NOLOCK) ON ec.session_id = es.session_id
	LEFT JOIN sys.dm_exec_requests AS er  WITH(NOLOCK) ON er.session_id = es.session_id
	LEFT JOIN sys.sysprocesses AS sp WITH(NOLOCK) ON sp.spid = es.session_id

	LEFT JOIN sys.dm_tran_session_transactions AS tst WITH(NOLOCK) ON tst.session_id = es.session_id
	LEFT JOIN sys.dm_tran_active_transactions AS tat WITH(NOLOCK) ON tat.transaction_id = tst.transaction_id

	OUTER APPLY sys.dm_exec_query_plan(er.plan_handle) AS qp  
	OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) AS st 
	OUTER APPLY sys.dm_exec_sql_text(ec.most_recent_sql_handle) AS ec_st

) AS T
WHERE
	session_id <> @@SPID
	AND
	session_id >= 
		CASE @system
			WHEN 0 THEN 50 -- ユーザーセッションものみを取得
			ELSE 0	-- システムセッションを併せて取得
		END
	AND
	(
		elapsed_time_sec >= @elapsed_time_sec
		OR
		transaction_begin_elapsed_time_sec >= @transaction_elapsed_time_sec
		OR
		wait_time_sec >= @wait_time_sec
	)
ORDER BY
	session_id
OPTION (RECOMPILE)