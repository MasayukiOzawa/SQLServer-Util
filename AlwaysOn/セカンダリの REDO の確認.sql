SELECT 
	tl.request_session_id,
	tl.resource_type,
	tl.request_mode,
	tl.request_type,
	tl.request_status,
	tl.request_owner_type,
	OBJECT_NAME(p.object_id) AS object_name,
	i.name,
	er.command,
	er.wait_type,
	COUNT(*) AS lock_count
FROM  
	sys.dm_tran_locks AS tl WITH(NOLOCK) 
	INNER JOIN
		sys.dm_exec_requests AS er WITH(NOLOCK) 
	ON
		er.session_id = tl.request_session_id
		AND
		er.wait_type LIKE 'REDO%'
	LEFT JOIN
		sys.partitions AS p WITH(NOLOCK) 
	ON
		p.hobt_id = tl.resource_associated_entity_id
	LEFT JOIN
		sys.indexes AS i WITH(NOLOCK) 
	ON
		i.object_id = p.object_id AND i.index_id = p.index_id
GROUP BY
	tl.request_session_id,
	tl.resource_type,
	tl.request_mode,
	tl.request_type,
	tl.request_status,
	tl.request_owner_type,
	p.object_id,
	i.name,
	er.command,
	er.wait_type
GO