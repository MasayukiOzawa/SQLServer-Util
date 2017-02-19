-- オブジェクト単位のメモリ使用量 (DB 単位)
SELECT 
	object_id,
	OBJECT_NAME(object_id) AS object_name,
	memory_allocated_for_table_kb,
	memory_used_by_table_kb,
	memory_allocated_for_indexes_kb,
	memory_used_by_indexes_kb
FROM 
	sys.dm_db_xtp_table_memory_stats

-- ハッシュインデックスの設定状況
SELECT
	DB_NAME() AS database_name,
	OBJECT_NAME(his.object_id) AS object_name,  
	i.name,
	i.type_desc,
	his.total_bucket_count,
	his.empty_bucket_count,
	his.avg_chain_length,
	his.max_chain_length
FROM 
	sys.dm_db_xtp_hash_index_stats his
	LEFT JOIN
	sys.indexes i
	ON
	i.object_id = his.object_id
	AND
	i.index_id = his.index_id

-- 非クラスター化インデックスの設定状況
SELECT
	DB_NAME() AS database_name,
	OBJECT_NAME(nis.object_id) AS object_name,
	i.name,
	i.type_desc,
	nis.delta_pages,
	nis.internal_pages,
	nis.leaf_pages,
	nis.outstanding_retired_nodes,
	nis.page_update_count,
	nis.page_update_retry_count,
	nis.page_consolidation_count,
	nis.page_consolidation_retry_count,
	nis.page_split_count,
	nis.page_split_retry_count,
	nis.key_split_count,
	nis.key_split_retry_count,
	nis.page_merge_count,
	nis.page_merge_retry_count,
	nis.key_merge_count,
	nis.key_merge_retry_count,
	nis.uses_key_normalization
FROM
	sys.dm_db_xtp_nonclustered_index_stats nis
	LEFT JOIN
	sys.indexes i
	ON
	i.object_id = nis.object_id
	AND
	i.index_id = nis.index_id

-- インデックスの統計情報
SELECT
	OBJECT_NAME(s.object_id) AS object_name,
	i.name,
	i.type_desc,
	s.scans_started,
	s.scans_retries,
	s.rows_returned,
	s.rows_touched,
	s.rows_expiring,
	s.rows_expired,
	s.rows_expired_removed,
	s.phantom_scans_started,
	s.phantom_scans_retries,
	s.phantom_rows_touched,
	s.phantom_expiring_rows_encountered,
	s.phantom_expired_removed_rows_encountered,
	s.phantom_expired_rows_removed,
	s.object_address
FROM
	sys.dm_db_xtp_index_stats AS s
	LEFT JOIN
	sys.indexes AS i
	ON
	i.object_id = s.object_id
	AND
	i.index_id = s.index_id

-- オブジェクトの操作統計
SELECT
	OBJECT_NAME(object_id) AS object_name,
	row_insert_attempts,
	row_update_attempts,
	row_delete_attempts,
	write_conflicts,
	unique_constraint_violations,
	object_address
FROM 
	sys.dm_db_xtp_object_stats
