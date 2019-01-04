SELECT 
	si.publisher,
	si.subscriber,
	CASE type
		WHEN 0 THEN 'SQL Server Subscliber'
		WHEN 1 THEN 'ODBC Data Source'
	END AS type,
	si.login,
	CASE si.security_mode
		WHEN 0 THEN 'SQL Server Auth'
		WHEN 1 THEN 'Windows Auth'
	END AS security_mode,
	CASE ss.agent_type
		WHEN 0 THEN 'Distribution Agent'
		WHEN 1 THEN 'Merge Agent'
	END AS agent_type,
	CASE ss.frequency_type
		WHEN 1 THEN 'One Time'
		WHEN 2 THEN 'On demand'
		WHEN 4 THEN 'Daily'
		WHEN 8 THEN 'Weekly'
		WHEN 16 THEN 'Monthly'
		WHEN 32 THEN 'Monthly relative'
		WHEN 64 THEN 'Autostart'
		WHEN 128 THEN 'Recurring'
	END AS frequency_type,
	ss.frequency_interval
FROM 
	distribution.dbo.MSsubscriber_info AS si WITH(NOLOCK)
	LEFT JOIN
	distribution.dbo.MSsubscriber_schedule AS ss WITH(NOLOCK)
	ON
	si.publisher = ss.publisher
	AND
	si.subscriber = ss.subscriber
OPTION (RECOMPILE, MAXDOP 1)