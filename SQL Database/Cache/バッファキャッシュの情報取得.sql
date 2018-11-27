SET NOCOUNT ON
GO

/********************************************/
-- バッファキャッシュの情報取得
/********************************************/
SELECT 
	GETDATE() AS DATE, 
	database_id,
	CASE database_id 
		WHEN 32767 THEN 'ResourceDb' 
		ELSE db_name(database_id) 
	END AS [Database_name], 
	count(*) AS [Page Count], 
	count(*) * 8.0 AS [Page Size (KB)]
FROM
	[sys].[dm_os_buffer_descriptors] WITH (NOLOCK)
GROUP BY
	db_name(database_id), 
	[database_id]
UNION
SELECT
	GETDATE(),
	0,
	'ALL', 
	count(*),
	count(*) * 8.0
FROM
	[sys].[dm_os_buffer_descriptors] WITH (NOLOCK)
ORDER BY 
	[database_id] ASC
OPTION (RECOMPILE)


/********************************************/
-- バッファキャッシュの情報取得 (詳細)
/********************************************/
SELECT 
	GETDATE() AS DATE, 
	CASE database_id 
		WHEN 32767 THEN 'ResourceDb' 
		ELSE db_name(database_id) 
	END AS [Database_name],
	OBJECT_NAME(p.object_id) AS object_name,
	p.index_id,
	p.partition_number, 
	count(*) AS [Page Count], 
	count(*) * 8.0 AS [Page Size (KB)]
FROM
	[sys].[dm_os_buffer_descriptors] bd WITH (NOLOCK)
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
	OBJECT_SCHEMA_NAME(object_id) <> 'sys'
GROUP BY
	[database_id],
	p.object_id,
	index_id,
	partition_number
ORDER BY 
	[database_id] ASC
OPTION (RECOMPILE)
