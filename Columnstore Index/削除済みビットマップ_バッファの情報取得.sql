-- 削除済みバッファ / ビットマップの情報取得
SELECT 
	OBJECT_NAME(ip.object_id) object_name,
	i.name,
	ip.partition_number,
	ip.internal_object_type_desc,
	ip.row_group_id,
	ip.rows,
	ip.data_compression_desc,
	au.type_desc,
	au.data_space_id,
	au.total_pages,
	au.used_pages,
	au.data_pages
FROM 
	sys.internal_partitions ip
	LEFT JOIN
	sys.indexes i
	ON
	i.object_id = ip.object_id
	AND
	i.index_id = ip.index_id
	LEFT JOIN
	sys.allocation_units au
	ON
	ip.hobt_id = au.container_id
WHERE
	rows > 0
ORDER BY
	OBJECT_NAME(ip.object_id),
	ip.partition_number

-- DMV から割り当てページを確認
SELECT 
	DB_NAME(pa.database_id) AS database_name,
	OBJECT_NAME(pa.object_id) AS object_name,
	i.name,
	p.internal_object_type_desc,
	p.rows,
	p.data_compression_desc,
	pa.partition_id,
	pa.allocated_page_file_id,
	pa.extent_page_id,
	pa.allocated_page_page_id,
	pa.allocation_unit_type_desc,
	pa.page_free_space_percent,
	pa.is_page_compressed,
	pa.allocated_page_iam_page_id,
	pa.rowset_id,
	pa.allocation_unit_id,
	pa.is_iam_page,
	pa.is_mixed_page_allocation,
	pa.next_page_file_id,
	pa.next_page_page_id,
	pa.previous_page_file_id,
	pa.previous_page_page_id

FROM
	sys.internal_partitions p
	LEFT JOIN
	sys.dm_db_database_page_allocations(
		DB_ID(), 
		OBJECT_ID('T1'), 
		NULL, -- index_id
		NULL, -- partition_id
		'DETAILED' -- 'LIMITED'
	) pa
	ON
	pa.object_id = p.object_id
	AND
	pa.rowset_id = p.hobt_id
	INNER JOIN
	sys.indexes i
	ON
	i.object_id = pa.object_id
	AND
	i.index_id = pa.index_id

/*
-- ページ情報
DBCC TRACEON(3604)
DBCC PAGE(N'tpch', 1, 188712, 3) WITH TABLERESULTS
DBCC PAGE(N'tpch', 1, 165288, 3) WITH TABLERESULTS
*/
