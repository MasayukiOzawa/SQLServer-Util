SELECT
	'distribution_agent' AS agent_type,
	da.publication,
	ap.profile_name,
	CASE da.subscription_type
		WHEN 0 THEN'Push'
		WHEN 1 THEN'Pull'
		WHEN 2 THEN'Anonymous'
		ELSE CAST(da.subscription_type AS sysname)
	END AS subscription_type,
	da.name AS sqlserver_agent_job_name,
	da.local_job,
	a.article,
	sr_p.msrs_srvname AS publisher_server,
	da.publisher_db,
	a.source_owner + '.' + a.source_object AS source_object,
	sr_s.msrs_srvname AS subscliber_server,
	da.subscriber_db,
	CASE
		WHEN a.destination_owner IS NULL THEN a.destination_object
		ELSE destination_owner + '.' + destination_object
	END AS destination_object
FROM
	distribution.dbo.MSdistribution_agents AS da WITH(NOLOCK)
	LEFT JOIN
		msdb.dbo.MSagent_profiles AS ap WITH(NOLOCK)
	ON
		ap.agent_type=3--1:snapshot_agent/2:logreader_agent/3:distribution_agent/4:merge_agent/9:queue_reader_agent
		AND
		ap.profile_id=da.profile_id
	LEFT JOIN
		distribution.dbo.MSsubscriptions AS s WITH(NOLOCK)
	ON
		s.publisher_id=da.publisher_id
		AND
		s.publisher_database_id=da.publisher_database_id
		AND
		s.publisher_db=da.publisher_db
		AND
		s.subscriber_db=da.subscriber_db
		AND
		s.subscriber_id=da.subscriber_id
		AND
		s.subscriber_id>0
	LEFT JOIN
		distribution.dbo.MSarticles AS a WITH(NOLOCK)
	ON
		a.article_id=s.article_id
		AND
		a.publisher_db=s.publisher_db
	LEFT JOIN
		distribution.dbo.MSsysservers_replservers AS sr_p WITH(NOLOCK)
	ON
		sr_p.msrs_srvid=s.publisher_id
	LEFT JOIN
		distribution.dbo.MSsysservers_replservers AS sr_s WITH(NOLOCK)
	ON
		sr_s.msrs_srvid=s.subscriber_id
WHERE
	da.subscriber_id>0
ORDER BY
	da.publication ASC,
	a.article ASC,
	s.subscriber_db ASC,
	sr_s.msrs_srvname ASC
OPTION(RECOMPILE,MAXDOP 1)

SELECT
	'logreader_agent' AS agent_type,
	la.publication,
	ap.profile_name,
	la.name AS sqlserver_agent_job_name,
	la.local_job,
	sr_p.msrs_srvname,
	la.publisher_db
FROM
	distribution.dbo.MSlogreader_agents AS la WITH(NOLOCK)
	LEFT JOIN
		msdb.dbo.MSagent_profiles AS ap WITH(NOLOCK)
	ON
		ap.agent_type=2--1:snapshot_agent/2:logreader_agent/3:distribution_agent/4:merge_agent/9:queue_reader_agent
		AND
		ap.profile_id=la.profile_id
	LEFT JOIN
		distribution.dbo.MSsysservers_replservers AS sr_p WITH(NOLOCK)
	ON sr_p.msrs_srvid=la.publisher_id
OPTION(RECOMPILE,MAXDOP 1)

SELECT
	'snapshot_agent' AS agent_type,
	sa.publication,
	ap.profile_name,
	sa.name AS sqlserver_agent_job_name,
	sa.local_job,
	a.article,
	sr_p.msrs_srvname AS publisher_server,
	sa.publisher_db,
	a.source_owner + '.' + a.source_object AS source_object,
	sr_s.msrs_srvname AS subscliber_server,
	s.subscriber_db,
	CASE
		WHEN a.destination_owner IS NULL THEN a.destination_object
		ELSE destination_owner + '.' + destination_object
	END AS destination_object
FROM
	distribution.dbo.MSsnapshot_agents AS sa WITH(NOLOCK)
	LEFT JOIN
		msdb.dbo.MSagent_profiles AS ap WITH(NOLOCK)
	ON
		ap.agent_type=1--1:snapshot_agent/2:logreader_agent/3:distribution_agent/4:merge_agent/9:queue_reader_agent
		AND
		ap.profile_id=sa.profile_id
	LEFT JOIN
		distribution.dbo.MSsubscriptions AS s WITH(NOLOCK)
	ON
		s.publisher_id=sa.publisher_id
		AND
		s.publisher_db=sa.publisher_db
		AND
		s.publication_id=sa.id
		AND
		s.subscriber_id>0
	LEFT JOIN
		distribution.dbo.MSarticles AS a WITH(NOLOCK)
	ON
		a.article_id=s.article_id
		AND
		a.publisher_db=s.publisher_db
	LEFT JOIN
		distribution.dbo.MSsysservers_replservers AS sr_p WITH(NOLOCK)
	ON
		sr_p.msrs_srvid=s.publisher_id
	LEFT JOIN
		distribution.dbo.MSsysservers_replservers AS sr_s WITH(NOLOCK)
	ON
		sr_s.msrs_srvid=s.subscriber_id
ORDER BY
	sa.publication ASC,
	a.article ASC,
	s.subscriber_db ASC,
	sr_s.msrs_srvname ASC
OPTION(RECOMPILE,MAXDOP 1)
