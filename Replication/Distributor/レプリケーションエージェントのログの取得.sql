-- 直近 6 時間の情報を取得
DECLARE @targetTime datetime
SET @targetTime = DATEADD(mm, -6, GETDATE())

-- エージェントの実行履歴の情報の取得
-- エージェントジョブは初回起動後、プロセスが常駐するため、ジョブの起動日ではなく、メッセージの出力日を起点に設定

-- ディストリビューション エージェントの履歴を取得
SELECT 
	'distribution_agent' AS log_type,
	dh.time, 
	dh.start_time, 
	da.name,
	da.publisher_db,
	da.publication,
	da.subscriber_db,
	dh.comments,
	CASE dh.runstatus
		WHEN 1 THEN '開始'
		WHEN 2 THEN '成功'
		WHEN 3 THEN '実行中'
		WHEN 4 THEN 'アイドル状態'
		WHEN 5 THEN '再試行'
		WHEN 6 THEN '失敗'
		ELSE CAST(dh.runstatus AS sysname)
	END AS runstatus,
	dh.duration,
	dh.current_delivery_rate,
	dh.current_delivery_latency,
	dh.delivered_transactions,
	dh.delivered_commands,
	dh.average_commands,
	dh.delivery_rate,
	dh.delivery_latency,
	dh.total_delivered_commands,
	dh.error_id,
	dh.updateable_row,
	dh.xact_seqno
FROM 
	distribution.dbo.MSdistribution_history AS dh WITH(NOLOCK)
	LEFT JOIN 
		distribution.dbo.MSdistribution_agents AS da WITH(NOLOCK)
	ON
		da.id = dh.agent_id
WHERE
	dh.time >= @targetTime 
ORDER BY 
	dh.time DESC
OPTION (RECOMPILE, MAXDOP 1)


-- ログリーダー エージェントの履歴を取得
SELECT 
	'logreader_agent' AS log_type,
	lh.time, 
	lh.start_time, 
	la.name,
	la.publisher_db,
	la.publication,
	lh.comments,
	CASE lh.runstatus
		WHEN 1 THEN '開始'
		WHEN 2 THEN '成功'
		WHEN 3 THEN '実行中'
		WHEN 4 THEN 'アイドル状態'
		WHEN 5 THEN '再試行'
		WHEN 6 THEN '失敗'
		ELSE CAST(lh.runstatus AS sysname)
	END as runstatus,
	lh.duration,
	lh.delivered_transactions,
	lh.delivered_commands,
	lh.average_commands,
	lh.delivery_rate,
	lh.delivery_latency,
	lh.error_id,
	lh.updateable_row,
	lh.xact_seqno
FROM 
	distribution.dbo.MSlogreader_history AS lh WITH(NOLOCK)
	LEFT JOIN
		distribution.dbo.MSlogreader_agents AS la WITH(NOLOCK)
	ON
		la.id = lh.agent_id
WHERE
	lh.time >= @targetTime
ORDER BY 
	lh.time DESC
OPTION (RECOMPILE, MAXDOP 1)

-- スナップショットエージェントの履歴を取得
SELECT 
	'snapshot_agent' AS log_type,
	sh.time, 
	sh.start_time, 
	sa.name,
	sa.publisher_db,
	sa.publication,
	sh.comments,
	CASE sh.runstatus
		WHEN 1 THEN '開始'
		WHEN 2 THEN '成功'
		WHEN 3 THEN '実行中'
		WHEN 4 THEN 'アイドル状態'
		WHEN 5 THEN '再試行'
		WHEN 6 THEN '失敗'
		ELSE CAST(sh.runstatus AS sysname)
	END as runstatus,
	sh.duration,
	sh.delivered_transactions,
	sh.delivered_commands,
	sh.delivery_rate,
	sh.error_id,*
FROM 
	distribution.dbo.MSsnapshot_history AS sh WITH (NOLOCK)
	LEFT JOIN
		distribution.dbo.MSsnapshot_agents AS sa WITH(NOLOCK)
	ON
		sa.id = sh.agent_id
WHERE
	sh.time >= @targetTime
ORDER BY 
	sh.time DESC
OPTION (RECOMPILE, MAXDOP 1)