SELECT
	DB_NAME() AS database_name,
	type_desc, 
	file_id,
	size * 8 / 1024 AS size_mb,
	FILEPROPERTY(name,'SpaceUsed') * 8  / 1024 AS space_used_mb, 
	(size - FILEPROPERTY(name,'SpaceUsed')) * 8  / 1024 AS unallocated_page_mb,
	CASE max_size
		WHEN -1 THEN -1
		ELSE max_size * 8  / 1024
	END AS max_size_mb
FROM
	sys.database_files
UNION ALL
SELECT
	database_name,
	type_desc,
	file_id,
	size_mb,
	size_mb - unallocated_page_mb AS space_used_mb,
	unallocated_page_mb,
	max_size_mb
FROM
(
	SELECT
		'tempdb' AS database_name,
		type_desc, 
		file_id,
		size * 8  / 1024 AS size_mb,
		(SELECT
			allocated_extent_page_count * 8 / 1024 AS allocated_extent_page_mb
		FROM
			tempdb.sys.dm_db_file_space_usage 
		WHERE
			file_id = T.file_id
		) AS unallocated_page_mb,
		CASE max_size
			WHEN -1 THEN -1
			ELSE max_size * 8  / 1024
		END AS max_size_mb
	FROM
		tempdb.sys.database_files AS T
) AS T2
