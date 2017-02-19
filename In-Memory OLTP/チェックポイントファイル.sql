-- チェックポイントファイルの全体統計
SELECT
	*
FROM
	sys.dm_db_xtp_checkpoint_stats


-- チェックポイントファイル使用状況 (詳細)
SELECT 
	* 
FROM 
	sys.dm_db_xtp_checkpoint_files
ORDER BY
	container_guid ASC

-- チェックポイントファイルのペア情報
SELECT
	T1.checkpoint_file_id, T1.relative_file_path, T1.file_type_desc, T1.file_size_in_bytes, T1.file_size_used_in_bytes, T1.logical_row_count,
	T2.checkpoint_file_id, T2.relative_file_path, T2.file_type_desc, T2.file_size_in_bytes, T2.file_size_used_in_bytes, T2.logical_row_count
FROM
	sys.dm_db_xtp_checkpoint_files T1
	INNER JOIN
	sys.dm_db_xtp_checkpoint_files T2
	ON
	T1.checkpoint_file_id = T2.checkpoint_pair_file_id
	AND
	T2.file_type_desc = 'DELTA'
WHERE
	T1.file_type_desc = 'DATA'


/*
-- SQL Server 2016 以降は、内部マージポリシーにより自動的にファイルがマージされる
EXEC sys.sp_xtp_merge_checkpoint_files 
	@database_name = tpch, 
	@transaction_lower_bound=0, 
	@transaction_upper_bound = 100
*/
