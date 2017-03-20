-- ===================================
-- SQL Server 2016 以降
-- ===================================

-- 行グループの状態の取得
SELECT
	OBJECT_NAME(csps.object_id) AS object_name,
	si.name,
	csps.partition_number,
	csps.row_group_id,
	si.type_desc,
	csps.state_desc,
	csps.total_rows,
	csps.size_in_bytes,
	csps.deleted_rows,
	csps.trim_reason_desc,
	csps.transition_to_compressed_state_desc,
	csps.generation,
	csps.created_time,
	csps.closed_time
FROM 
	sys.dm_db_column_store_row_group_physical_stats csps
	LEFT JOIN
	sys.indexes si
	ON
	si.object_id = csps.object_id
	AND
	si.index_id = csps.index_id
ORDER BY
	object_name ASC,
	name ASC,
	partition_number ASC,
	type_desc ASC,
	state_desc ASC,
	generation ASC
OPTION (RECOMPILE)

-- オブジェクトごとの行グループのサイズ取得
SELECT
	OBJECT_NAME(csps.object_id) AS object_name,
	si.name,
	si.type_desc,
	csps.state_desc,
	SUM(csps.total_rows) AS TotalRows,
	SUM(csps.size_in_bytes) / 1024.0 / 1024.0 AS TotalMBytes,
	SUM(csps.deleted_rows) AS TotalDeletedRows
FROM 
	sys.dm_db_column_store_row_group_physical_stats csps
	LEFT JOIN
	sys.indexes si
	ON
	si.object_id = csps.object_id
	AND
	si.index_id = csps.index_id
GROUP BY
	csps.object_id,
	si.name,
	si.type_desc,
	csps.state_desc
ORDER BY
	object_name ASC,
	name ASC,
	state_desc ASC
OPTION (RECOMPILE)

-- ===================================
-- 共通
-- ===================================

-- 列のセグメント単位のサイズの取得
SELECT 
	OBJECT_NAME(si.object_id) AS object_name,
	si.name,
	si.type_desc,
	css.column_id,
	css.segment_id,
	css.row_count,
	css.on_disk_size,
	css.min_data_id,
	css.max_data_id,
	css.null_value
FROM 
	sys.column_store_segments  css
	LEFT JOIN
	sys.partitions  sp
	ON
	sp.hobt_id = css.hobt_id
	LEFT JOIN sys.indexes si
	ON
	si.object_id = sp.object_id
	AND
	si.index_id = sp.index_id
ORDER BY
	object_name ASC,
	name ASC,
	type_desc ASC,
	column_id ASC
OPTION (RECOMPILE)

-- 列単位のサイズの取得
SELECT 
	OBJECT_NAME(si.object_id) AS object_name,
	si.name,
	si.type_desc,
	css.column_id,
	SUM(css.row_count) AS TotalRows,
	SUM(css.on_disk_size) / 1024.0 / 1024 AS TotalMBytes
FROM 
	sys.column_store_segments  css
	LEFT JOIN
	sys.partitions  sp
	ON
	sp.hobt_id = css.hobt_id
	LEFT JOIN sys.indexes si
	ON
	si.object_id = sp.object_id
	AND
	si.index_id = sp.index_id
GROUP BY
	OBJECT_NAME(si.object_id) ,
	si.name,
	si.type_desc,
	css.column_id
ORDER BY
	object_name ASC,
	name ASC,
	type_desc ASC,
	column_id ASC
OPTION (RECOMPILE)


/*
-- ===================================
-- SQL Server 2014
-- ===================================
-- 行グループの状態の取得
SELECT
	OBJECT_NAME(crg.object_id) AS object_name,
	si.name,
	si.type_desc,
	crg.partition_number,
	crg.row_group_id,
	crg.state_description,
	crg.total_rows,
	crg.deleted_rows,
	crg.size_in_bytes
FROM
	sys.column_store_row_groups crg
	LEFT JOIN
	sys.indexes si
	ON
	si.object_id = crg.object_id
	AND
	si.index_id = crg.index_id
ORDER BY
	object_name,
	name ASC,
	type_desc ASC,
	partition_number ASC,
	row_group_id ASC,
	state_description ASC
OPTION (RECOMPILE)
	

-- オブジェクトごとの行グループのサイズ取得
SELECT
	OBJECT_NAME(crg.object_id) AS object_name,
	si.name,
	si.type_desc,
	crg.state_description,
	SUM(crg.total_rows) AS TotalRows,
	SUM(crg.size_in_bytes) / 1024.0 / 1024.0 AS TotalMBytes
FROM
	sys.column_store_row_groups crg
	LEFT JOIN
	sys.indexes si
	ON
	si.object_id = crg.object_id
	AND
	si.index_id = crg.index_id
GROUP BY
	crg.object_id,
	si.name,
	si.type_desc,
	crg.state_description
*/