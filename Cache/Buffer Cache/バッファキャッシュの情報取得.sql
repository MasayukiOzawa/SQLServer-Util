/*************************************************
SQL Server 2014 以降
**************************************************/

SET NOCOUNT ON
GO

/********************************************/
-- バッファキャッシュの情報取得 (2014 以降 BPE 情報取得)
/********************************************/
SELECT 
	GETDATE() AS DATE, 
	CASE database_id 
		WHEN 32767 THEN 'ResourceDb' 
		ELSE db_name(database_id) 
	END AS [Database_name], 
	[is_in_bpool_extension],
	count(*) AS [Page Count], 
	count(*) * 8.0 AS [Page Size (KB)]
FROM
	[sys].[dm_os_buffer_descriptors] WITH (NOLOCK)
GROUP BY
	db_name(database_id), 
	[database_id],
	[is_in_bpool_extension]
ORDER BY 
	[database_id] ASC,
	[is_in_bpool_extension] ASC
OPTION (RECOMPILE)


/********************************************/
-- バッファキャッシュの情報取得 (詳細)
/********************************************/
SELECT 
	GETDATE() AS DATE, 
	CASE [database_id]
		WHEN 32767 THEN 'ResourceDb' 
		ELSE DB_NAME([database_id]) 
	END AS [Database_name], 
	[page_type], 
	count(*) AS [Page Count], 
	count(*) * 8.0 AS [Page Size (KB)]
FROM
	[sys].[dm_os_buffer_descriptors] WITH (NOLOCK)
GROUP BY
	DB_NAME([database_id]), 
	[database_id], 
	[page_type]
ORDER BY 
	[database_id] ASC
OPTION (RECOMPILE)
