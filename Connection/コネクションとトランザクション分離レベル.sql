SELECT 
	ec.session_id,
	es.host_name,
	es.status,
	CASE es.transaction_isolation_level
		WHEN 0 THEN 'Unspecified'
		WHEN 1 THEN 'ReadUncomitted'
		WHEN 2 THEN 'ReadCommitted'
		WHEN 3 THEN 'Repeatable'
		WHEN 4 THEN 'Serializable'
		WHEN 5 THEN 'Snapshot'
	END AS transaction_isolation_level,
	es.program_name,
	es.client_interface_name,
	DATEDIFF(ss, ec.connect_time,GETDATE()) AS con_keep_sec,
	DATEDIFF(ss, es.login_time,GETDATE()) AS con_reuse_sec,
	ec.connect_time,
	es.login_time,
	es.last_request_start_time,
	es.last_request_end_time,
	ec.net_transport,
	ec.protocol_type,
	ec.last_read,
	ec.last_write,
	ec.client_net_address,
	ec.client_tcp_port,
	es.client_version,
	es.context_info,
	es.lock_timeout,
	es.open_transaction_count -- SQL Server 2012 以降
FROM 
	sys.dm_exec_connections AS ec
	LEFT JOIN sys.dm_exec_sessions AS es
		ON es.session_id = ec.session_id
WHERE
	es.is_user_process = 1
ORDER BY
	session_id
