WITH 
sp AS(
SELECT spid, blocked, cmd, lastwaittype,waitresource,status, text 
FROM sys.sysprocesses 
CROSS APPLY sys.dm_exec_sql_text(sql_handle)
WHERE spid > 50
),
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
	RTRIM(status) AS status
	,text
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
	r.text
FROM
	sp r
	INNER JOIN
	BlockList
	ON
	r.blocked = BlockList.spid
)
SELECT 
	BlockList.level, 
	BlockList.spid, 
	er.start_time,
	at.transaction_begin_time,
	datediff(MILLISECOND, er.start_time,GETDATE()) AS epalsed_time_ms,
	datediff(MILLISECOND, at.transaction_begin_time, GETDATE()) AS transaction_elapsed_time_ms,
	er.wait_time,
	is_HeadBlocker,
	CASE 
		WHEN BlockList.blocked_path = '' THEN ''
		ELSE BlockList.blocked_path + '->' + CAST(BlockList.spid AS varchar(10))
	END	AS blocked_path,
	er.status,
	BlockList.cmd, 
	er.wait_type,
	BlockList.lastwaittype, 
	er.wait_resource AS er_wait_resource,
	BlockList.waitresource AS BlockList_wait_resource, 
	BlockList.status, 
	BlockList.text,
		SUBSTRING(st.text, (er.statement_start_offset/2)+1,   
	((CASE er.statement_end_offset  
		WHEN -1 THEN DATALENGTH(st.text)  
		ELSE er.statement_end_offset  
		END - er.statement_start_offset)/2) + 1) AS statement_text ,
	st.text AS st_text,
	qp.query_plan,
	es.host_name,
	es.program_name,
	es.login_name
FROM 
	BlockList
	LEFT JOIN sys.dm_exec_requests AS er ON er.session_id = BlockList.spid
	LEFT JOIN sys.dm_tran_active_transactions AS at ON at.transaction_id = er.transaction_id
	LEFT JOIN sys.dm_exec_sessions as es ON es.session_id = BlockList.spid
	OUTER APPLY sys.dm_exec_query_plan(er.plan_handle) AS qp
	OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) AS st
ORDER BY 
	level ASC,
	blocked_chain ASC
OPTION (MAXRECURSION 100, RECOMPILE)