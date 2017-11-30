/***********************************************************************************************************/
-- インデックス使用状況の取得
-- 列ストアインデックスは列ストアインデックス向けの情報から確認するため、サイズの計算値については 0 を設定
/***********************************************************************************************************/
SET NOCOUNT ON
GO
DECLARE @DB_ID int
SET @DB_ID = DB_ID()

SELECT 
	DB_NAME() as db_name
	, SCHEMA_NAME(so.schema_id) AS [schema_name]
	, OBJECT_NAME(si.object_id) AS [object_name]
	, si.name
	, si.index_id
	, ios.hobt_id
	, dps.partition_number
	, si.type
	, si.type_desc
	, sp.data_compression
	, sp.data_compression_desc
	, SUBSTRING(idxcolinfo.idxcolname,1,LEN(idxcolinfo.idxcolname) -1) AS idxcolname
	, SUBSTRING(idxinccolinfo.idxinccolname,1,LEN(idxinccolinfo.idxinccolname) -1) AS idxinccolname
	, dps.reserved_page_count
	, CASE
		WHEN si.type IN (5,6,7) THEN 0
		ELSE dps.reserved_page_count * 8.0 
	END AS reserved_page_size_kb
	, dps.row_count
	, CASE
		WHEN row_count = 0 OR si.type IN (5,6,7) THEN 0
		ELSE dps.reserved_page_count * 8.0 / row_count * 1024
	END AS avg_row_size_byte
	, ius.user_seeks
	, ius.last_user_seek
	, ius.user_scans
	, ius.last_user_scan
	, ius.user_lookups
	, ius.last_user_lookup
	, ios.leaf_insert_count
	, ios.leaf_delete_count
	, ios.leaf_ghost_count
	, ios.leaf_update_count
	, ios.page_io_latch_wait_count
	, ios.page_io_latch_wait_in_ms
	, ios.page_latch_wait_count
	, ios.page_latch_wait_in_ms
	, ios.row_lock_count
	, ios.row_lock_wait_count
	, ios.row_lock_wait_in_ms
	, ios.page_lock_count
	, ios.page_lock_wait_count
	, ios.page_lock_wait_in_ms
	, ss.name AS stats_name
	, STATS_DATE(si.object_id, si.index_id) AS [stats_date]
	, ss.auto_created
	, ss.user_created
	, ss.no_recompute
	, so.create_date
	, so.modify_date

FROM
	sys.indexes AS si
	LEFT JOIN
	sys.dm_db_index_usage_stats ius
	ON
	ius.object_id = si.object_id
	AND
	ius.index_id = si.index_id
	AND
	ius.database_id = DB_ID()
	LEFT JOIN
	sys.dm_db_partition_stats AS dps
	ON
	si.object_id = dps.object_id
	AND
	si.index_id = dps.index_id
	LEFT JOIN
		sys.objects so
	ON
		si.object_id = so.object_id
	LEFT JOIN
		sys.dm_db_index_operational_stats(@DB_ID, NULL, NULL, NULL) ios
	ON
		ios.object_id = si.object_id
	AND
		ios.index_id = si.index_id
	AND
		ios.partition_number = dps.partition_number
	LEFT JOIN
	sys.stats ss
	ON
	si.object_id = ss.object_id
	AND
	si.index_id = ss.stats_id
	LEFT JOIN
	sys.partitions sp
	ON
	sp.object_id = si.object_id
	AND
	sp.index_id = si.index_id
	AND
	sp.partition_number = dps.partition_number
	CROSS APPLY
	(SELECT 
		sc.name + '|'
	FROM
		sys.index_columns sic
		INNER JOIN
		sys.columns sc
		ON
		sic.object_id = sc.object_id
		AND
		sic.column_id = sc.column_id
	WHERE
		sic.object_id = si.object_id
		AND
		sic.index_id = si.index_id
		AND
		sic.is_included_column = 0
	FOR XML PATH('')
	) AS idxcolinfo(idxcolname)
	CROSS APPLY
	(SELECT 
		sc.name + '|'
	FROM
		sys.index_columns sic
		INNER JOIN
		sys.columns sc
		ON
		sic.object_id = sc.object_id
		AND
		sic.column_id = sc.column_id
	WHERE
		sic.object_id = si.object_id
		AND
		sic.index_id = si.index_id
		AND
		sic.is_included_column = 1
	FOR XML PATH('')
	) AS idxinccolinfo(idxinccolname)
WHERE
	(ius.database_id = DB_ID() OR ius.database_id IS NULL)
	AND
	so.schema_id <> SCHEMA_ID('sys')
	AND
	sp.data_compression IN(0, NULL)
ORDER BY
	dps.reserved_page_count DESC,
	object_name,
	si.index_id,
	dps.partition_number
OPTION (RECOMPILE)