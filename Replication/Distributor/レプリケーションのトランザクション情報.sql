-- 直近 6 時間の情報を取得
DECLARE @targetTime datetime
SET @targetTime = DATEADD(mm, -6, GETDATE())


SELECT
	dh.time,
	pd.publisher_db,
	CASE dh.runstatus
		WHEN 1 THEN '開始'
		WHEN 2 THEN '成功'
		WHEN 3 THEN '実行中'
		WHEN 4 THEN 'アイドル'
		WHEN 5 THEN '再試行'
		WHEN 6 THEN '失敗'
	END AS runstatus,
	rt.entry_time,
	dh.start_time,
	dh.xact_seqno,
	dh.comments,
	dh.duration,
	dh.current_delivery_rate,
	dh.current_delivery_latency,
	dh.delivered_commands,
	dh.average_commands,
	dh.delivery_latency,
	dh.total_delivered_commands,
	dh.error_id
FROM 
	distribution.dbo.MSrepl_transactions AS rt
	LEFT JOIN
	distribution.dbo.MSdistribution_history AS dh
	ON
	dh.xact_seqno = rt.xact_seqno
	LEFT JOIN
	distribution.dbo.MSpublisher_databases AS pd
	ON
	pd.id = rt.publisher_database_id
WHERE
	dh.time IS NOT NULL
	AND
	dh.time >= @targetTime
ORDER BY
	dh.time DESC