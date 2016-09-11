SET NOCOUNT ON
GO

/********************************************/
-- バッファキャッシュの情報取得 (特定データベースのオブジェクト単位)
-- データベース単位で実行する
/********************************************/
SELECT 
	GETDATE() AS DATE,
	DB_NAME(bd.database_id) AS database_name,
	OBJECT_NAME(sp.object_id) AS object_name,
	page_type,
	SUM(row_count) AS row_count,
	SUM(free_space_in_bytes) AS free_space_in_bytes,
	is_modified
FROM 
	sys.dm_os_buffer_descriptors  bd
LEFT JOIN
	sys.allocation_units au
ON
	bd.allocation_unit_id = au.allocation_unit_id
LEFT JOIN
	sys.partitions sp
ON
	au.container_id = sp.hobt_id
WHERE
	bd.database_id = DB_ID()
GROUP BY
	object_id,
	database_id,
	page_type,
	is_modified
ORDER BY 
	database_id,
	page_type,
	object_id
OPTION (RECOMPILE)


