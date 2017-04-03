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
	CAST(BlockList.blocked_chain + CAST(r.spid AS varchar(10)) AS varchar(100)) AS blocked_chain,
	CAST(IIF(BlockList.blocked_path='', '', BlockList.blocked_path + '->') + CAST(r.blocked AS varchar(10)) AS varchar(100)) , 
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
SELECT level, spid, IIF(blocked_path = '', '', blocked_path + '->' + CAST(spid AS varchar(10))) AS blocked_path, cmd, lastwaittype, waitresource, status, text 
FROM BlockList
ORDER BY blocked_chain, level
OPTION (MAXRECURSION 100, RECOMPILE)