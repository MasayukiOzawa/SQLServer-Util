/********************************************/  
-- データキャッシュ状況の情報取得  
/********************************************/  
SELECT   
	GETDATE() AS DATE,   
	db_name(database_id) AS Database_name,  
	OBJECT_NAME(p.object_id) AS object_name,  
	p.index_id,  
	p.partition_number,   
	count(*) AS [Page Count],   
	count(*) * 8 / 1024 AS [Page Size (MB)]  
FROM  
	sys.dm_os_buffer_descriptors bd WITH (NOLOCK)  
	LEFT JOIN   
		sys.allocation_units au WITH (NOLOCK)  
	ON  
		bd.allocation_unit_id = au.allocation_unit_id  
	LEFT JOIN  
		sys.partitions p WITH (NOLOCK)  
	ON  
		p.hobt_id = au.container_id  
WHERE  
	database_id = DB_ID()  
	AND
	OBJECT_SCHEMA_NAME(p.object_id) <> 'sys'
	GROUP BY 
	database_id,
	p.object_id,
	p.index_id,
	p.partition_number
OPTION (RECOMPILE)

