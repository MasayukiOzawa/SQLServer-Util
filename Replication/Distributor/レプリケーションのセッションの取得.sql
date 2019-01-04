SELECT 
	es.last_request_start_time,
	es.last_request_end_time,
	es.session_id,
	es.host_process_id,
	es.login_time,
	es.host_name,
	es.program_name,
	es.client_interface_name,
	DB_NAME(es.database_id) AS database_name
FROM
	sys.dm_exec_sessions es WITH(NOLOCK)
WHERE
	es.host_process_id IN 
(
	SELECT 
		host_process_id 
	FROM
		sys.dm_exec_sessions WITH(NOLOCK)
	WHERE
		(
			program_name LIKE '%LogReader%'
			OR
			database_id = DB_ID('distribution')
		)
		AND
		client_interface_name <> '.Net SqlClient Data Provider'
)
ORDER BY
	host_process_id ASC,
	program_name ASC,
	session_id ASC,
	database_name ASC
OPTION (RECOMPILE, MAXDOP 1)