-- データ同期状況の取得
SELECT 
	nip.ag_name
	, adc.database_name
	, ar.replica_server_name
	, drs.synchronization_health_desc
	, drs.last_commit_lsn
	, drs.last_commit_time
	, drs.last_redone_lsn
	, drs.last_redone_time
	, drs.recovery_lsn
	, log_send_queue_size -- KB
	, log_send_rate -- KB/sec
	, redo_queue_size -- KB
	, redo_rate -- KB/sec
FROM 
	sys.dm_hadr_database_replica_states AS drs
	LEFT JOIN
		sys.dm_hadr_name_id_map AS nip
	ON
		nip.ag_id = drs.group_id
	LEFT JOIN
		sys.availability_replicas AS ar
	ON
		ar.replica_id = drs.replica_id
	LEFT JOIN
		sys.availability_databases_cluster AS adc
	ON
		adc.group_database_id = drs.group_database_id
ORDER BY
	ar.replica_server_name
	, drs.database_id

-- 可用性グループの状態の取得
SELECT 
	ag.name,
	ar.replica_server_name,
	drs.is_primary_replica,
	ags.primary_replica,
	DB_NAME(drs.database_id) AS database_name,
	drs.database_state_desc,
	ags.secondary_recovery_health_desc, -- プライマリ以外は NULL
	ags.synchronization_health_desc, -- プライマリでは NOT_HEALTHY, セカンダリでは状態が取得される
	drs.synchronization_state_desc,
	drs.last_commit_time,
	drs.last_redone_time,
	drs.last_sent_time,
	drs.last_received_time,
	drs.last_hardened_time
FROM 
	sys.dm_hadr_availability_group_states ags
	LEFT JOIN
	sys.availability_groups ag
	ON
	ags.group_id = ag.group_id
	LEFT JOIN
	sys.dm_hadr_database_replica_states drs
	ON
	drs.group_id = ag.group_id
	LEFT JOIN
	sys.availability_replicas ar
	ON 
	ar.replica_id = drs.replica_id

-- 可用性レプリカの情報の取得
SELECT
	ag.name,
	rcs.replica_server_name,
	rcs.join_state_desc,
	rs.role_desc,
	rs.operational_state_desc,
	rs.connected_state_desc,
	rs.recovery_health_desc,
	rs.synchronization_health_desc,
	rs.last_connect_error_number,
	rs.last_connect_error_description,
	rs.last_connect_error_timestamp
FROM
	sys.dm_hadr_availability_replica_states rs
	LEFT JOIN
	sys.dm_hadr_availability_replica_cluster_states rcs
	ON
	rs.replica_id = rcs.replica_id
	AND
	rs.group_id = rcs.group_id
	LEFT JOIN
	sys.availability_groups ag
	on
	rs.group_id = ag.group_id

-- クラスターメンバーの取得
SELECT 
	* 
FROM 
	sys.dm_hadr_cluster_members
