SELECT 
    CONVERT(nvarchar,TODATETIMEOFFSET(CURRENT_TIMESTAMP,DATEPART(TZOFFSET,SYSDATETIMEOFFSET())),126) AS now,
    CONVERT(nvarchar,TODATETIMEOFFSET(req.start_time,DATEPART(TZOFFSET,SYSDATETIMEOFFSET())),126) AS query_start,
    sess.login_name AS user_name,
    sess.last_request_start_time AS last_request_start_time,
    sess.session_id AS id,
    DB_NAME(sess.database_id) AS database_name,
    sess.STATUS AS session_status,
    text.text AS text,
    c.client_tcp_port AS client_port,
    c.client_net_address AS client_address,
    sess.host_name AS host_name,
    req.command,
    req.blocking_session_id,
    req.wait_type,
    req.wait_time,
    req.last_wait_type,
    req.wait_resource,
    req.open_transaction_count,
    req.transaction_id,
    req.percent_complete,
    req.estimated_completion_time,
    req.cpu_time,
    req.total_elapsed_time,
    req.reads,
    req.writes,
    req.logical_reads,
    req.transaction_isolation_level,
    req.lock_timeout,
    req.deadlock_priority,
    req.row_count,
    req.query_hash,
    req.query_plan_hash
FROM 
     sys.dm_exec_sessions AS sess
     INNER JOIN sys.dm_exec_connections AS c
     ON sess.session_id = c.session_id
     INNER JOIN sys.dm_exec_requests AS req
     ON c.connection_id = req.connection_id
     CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) AS text
WHERE sess.session_id != @@spid
      AND sess.STATUS != 'sleeping';