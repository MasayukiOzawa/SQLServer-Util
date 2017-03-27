-- 現状のクエリでは列ストアインデックスのサイズについては、列ストアインデックス情報をベースにした情報から取得する
SELECT
	OBJECT_NAME(i.object_id) AS object_name,
	i.name,
	i.type,
	i.type_desc,
	ps.name,
	ps.type_desc,
	pf.name,
	rv.boundary_id,
	dps.partition_number,
	rv.value,
	rv2.range_value,
	dps.row_count,
	dps.used_page_count,
	dps.used_page_count * 8.0 AS used_page_size_kb
FROM
	sys.dm_db_partition_stats dps
	INNER JOIN
		sys.indexes i
	ON
		dps.object_id = i.object_id
		AND
		dps.index_id = i.index_id
	INNER JOIN
		sys.partition_schemes ps
	ON
		ps.data_space_id = i.data_space_id
	INNER JOIN
		sys.partition_functions pf
	ON
		pf.function_id = ps.function_id
	LEFT JOIN
		sys.partition_range_values rv
	ON
		rv.function_id = pf.function_id
		AND
		dps.partition_number = rv.boundary_id
	LEFT JOIN
		(
		 SELECT 
			boundary_id + 1 AS add_id, value AS range_value , function_id
		 FROM 
			sys.partition_range_values rv2 
		 ) AS rv2
	ON
		rv2.add_id = dps.partition_number
		AND
		rv2.function_id = pf.function_id
ORDER BY
	i.object_id ASC,
	i.name ASC,
	dps.partition_number ASC
