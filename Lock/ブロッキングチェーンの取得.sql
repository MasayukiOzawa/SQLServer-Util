DECLARE @headblocker bit = 0	-- Head Blocker のみを取得するか (0 : ブロッキングをすべて取得 / 1 : Head Blocker のみを取得)
DECLARE @level int = 100		-- 何レベルまで取得するか

;WITH 
-- プロセス一覧
sp AS(
	SELECT 
		spid, 
		blocked, 
		cmd, 
		lastwaittype,
		waitresource,
		status, 
		open_tran,
		text 
	FROM sys.sysprocesses 
	OUTER APPLY sys.dm_exec_sql_text(sql_handle)
	WHERE spid > 50 and spid <> blocked
),
-- ブロッキングリスト
BlockList AS(

--  Blocker
SELECT
	spid, 
	CAST(blocked AS varchar(100)) AS blocked,
	1 AS level, 
	1 AS is_HeadBlocker,
	CAST(RIGHT(REPLICATE('0', 8) + CAST(spid AS varchar(10)), 8) AS varchar(100)) AS blocked_chain,
	CAST('' AS varchar(100)) AS blocked_path, 
	RTRIM(cmd) AS cmd,
	RTRIM(lastwaittype) AS lastwaittype,
	RTRIM(waitresource) AS waitresource,
	RTRIM(status) AS status,
	open_tran,
	text
FROM
	sp
WHERE
	blocked = 0
	AND
	spid in (SELECT blocked FROM sp WHERE blocked <> 0)
UNION ALL

--  Blocked
SELECT
	r.spid, 
	CAST(r.blocked AS varchar(100)),
	BlockList.level + 1 AS level,
	0 AS is_HeadBlocker,
	CAST(BlockList.blocked_chain + CAST(r.spid AS varchar(10)) AS varchar(100)) AS blocked_chain,
	CAST(
		CASE BlockList.blocked_path 
		WHEN '' THEN CAST(BlockList.spid AS varchar(10))
		ELSE BlockList.blocked_path + '->' + CAST(r.blocked AS varchar(10)) 
		END
		AS varchar(100)
	) , 
	RTRIM(r.cmd) AS cmd,
	RTRIM(r.lastwaittype) AS lastwaittype,
	RTRIM(r.waitresource) AS waitresource,
	RTRIM(r.status) AS status,
	r.open_tran,
	r.text
FROM
	sp r
	INNER JOIN
	BlockList
	ON
	r.blocked = BlockList.spid
)
-- ブロッキング情報の取得
SELECT 
	BlockList.level, 
	BlockList.spid, 
	is_HeadBlocker,
	CASE 
		WHEN BlockList.blocked_path = '' THEN ''
		ELSE BlockList.blocked_path + '->' + CAST(BlockList.spid AS varchar(10))
	END	AS blocked_path,
	er.start_time,
	at.transaction_begin_time,
	datediff(SECOND, er.start_time,GETDATE()) AS elapsed_time_sec,
	at.name AS transaction_name,
	CASE at.transaction_type -- 読み取り専用トランザクションのトランザクション経過時間はトランザクション解析のノイズになる可能性があるため、Elapsed で判断
		WHEN 2 THEN NULL
		ELSE datediff(SECOND, at.transaction_begin_time, GETDATE())
	END AS transaction_elapsed_time_sec,
	er.wait_time,
	er.status AS er_status,
	BlockList.cmd, 
	er.wait_type,
	BlockList.lastwaittype, 
	er.wait_resource AS er_wait_resource,
	BlockList.waitresource AS BlockList_wait_resource, 
	BlockList.status AS blocklist_status, 
	es.host_name,
	es.program_name,
	es.login_name,
	er.open_transaction_count,
	BlockList.open_tran AS sysprocess_open_tran_count,
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
	END AS transaction_state,		
	at.transaction_id,
	at.transaction_uow,
	BlockList.text,
		SUBSTRING(st.text, (er.statement_start_offset/2)+1,   
	((CASE er.statement_end_offset  
		WHEN -1 THEN DATALENGTH(st.text)  
		ELSE er.statement_end_offset  
		END - er.statement_start_offset)/2) + 1) AS statement_text ,
	st.text AS exec_request_text,
	qp.query_plan

FROM 
	BlockList
	LEFT JOIN sys.dm_exec_requests AS er ON er.session_id = BlockList.spid
	LEFT JOIN sys.dm_exec_sessions as es ON es.session_id = BlockList.spid
	
	LEFT JOIN sys.dm_tran_session_transactions AS tst WITH(NOLOCK) ON tst.session_id = BlockList.spid
	LEFT JOIN sys.dm_tran_active_transactions AS at ON at.transaction_id = tst.transaction_id

	OUTER APPLY sys.dm_exec_query_plan(er.plan_handle) AS qp
	OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) AS st
WHERE
	is_HeadBlocker >= @headblocker
	AND
	level BETWEEN 1 AND @level
ORDER BY 
	level ASC,
	blocked_chain ASC,
	spid 
	ASC
OPTION (MAXRECURSION 100, RECOMPILE)
