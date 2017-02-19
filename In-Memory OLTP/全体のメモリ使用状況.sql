-- 詳細なメモリ使用量 (DB 単位)
SELECT 
	OBJECT_NAME(object_id) AS object_name,
	* 
FROM 
	sys.dm_db_xtp_memory_consumers
WHERE
	object_id >= 0
ORDER BY
	memory_consumer_id ASC
GO

-- 詳細なメモリ使用量 (システムレベル)
SELECT 
	* 
FROM 
	sys.dm_xtp_system_memory_consumers
ORDER BY
	memory_consumer_id ASC
GO
