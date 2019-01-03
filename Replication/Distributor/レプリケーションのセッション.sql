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
	sys.dm_exec_sessions es
WHERE
	es.host_process_id IN 
(
	SELECT 
		host_process_id 
	FROM
		sys.dm_exec_sessions
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
	program_name ASC,
	database_name ASC