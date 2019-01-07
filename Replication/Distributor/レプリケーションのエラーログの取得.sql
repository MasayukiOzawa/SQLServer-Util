-- 直近 6 時間の情報を取得
DECLARE @targetTime datetime
SET @targetTime = DATEADD(mm, -6, GETDATE())

;WITH agent_info AS(
SELECT 'snapshot_agent' AS agent_type_desc, 1 AS agent_type, id, name, publisher_db, publication 
FROM distribution.dbo.MSsnapshot_agents WITH(NOLOCK)
UNION
SELECT 'logreader_agent' AS agent_type_desc, 2 AS agent_type, id, name, publisher_db, publication 
FROM distribution.dbo.MSlogreader_agents WITH(NOLOCK)
UNION
SELECT 'distribution_agent' AS agent_type_desc, 3 AS agent_type, id, name, publisher_db, publication 
FROM distribution.dbo.MSdistribution_agents WITH(NOLOCK)
), replicationalerts AS
(
SELECT 
	ra.alert_id,
	ra.error_id,
	ra.time,
	ra.publication,
	ra.publisher_db,
	ra.subscriber,
	ra.subscriber_db,
	ra.article,
	ra.destination_object,
	ra.source_object,
	ra.alert_error_text,
	ai.agent_type_desc
FROM 
	msdb.dbo.sysreplicationalerts AS ra WITH(NOLOCK)
	LEFT JOIN
		agent_info AS ai WITH (NOLOCK)
	ON
		ai.agent_type = ra.agent_type
		AND
		ai.id = ra.agent_id
WHERE
	ra.time >= @targetTime
)

-- レプリケーションのエラーを取得
SELECT 
	re.time,
	ra.agent_type_desc,
	ra.article,
	ra.publication,
	ra.publisher_db,
	ra.source_object,
	ra.subscriber_db,
	ra.destination_object,
	re.error_type_id,
	re.source_type_id,
	re.source_name,
	re.error_code,
	re.error_text,
	ra.alert_error_text,
	re.command_id,
	re.xact_seqno
FROM 
	distribution.dbo.MSrepl_errors AS re WITH(NOLOCK)
	LEFT JOIN 
		replicationalerts AS ra WITH(NOLOCK)
	ON
		ra.error_id = re.id
WHERE
	re.time >= @targetTime
ORDER BY 
	re.time DESC
OPTION (RECOMPILE, MAXDOP 1)
