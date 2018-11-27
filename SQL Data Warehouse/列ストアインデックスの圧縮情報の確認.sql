-- 列ストアインデックスの圧縮情報の確認
SELECT
	o.name,
	i.name AS index_name,
	im.physical_name,
	i.type_desc,
	rg.index_id,
	rg.partition_number,
	rg.row_group_id,
	rg.state_description,
	rg.total_rows,
	rg.deleted_rows,
	rg.size_in_bytes,
	rg.pdw_node_id,
	rg.distribution_id
FROM
	sys.pdw_nodes_column_store_row_groups rg
	LEFT JOIN
	sys.pdw_nodes_indexes ni
	ON
	rg.object_id = ni.object_id
	AND
	rg.index_id = ni.index_id
	AND
	rg.pdw_node_id = ni.pdw_node_id
	AND
	rg.distribution_id = ni.distribution_id
	LEFT JOIN
	sys.pdw_index_mappings im
	ON
	im.physical_name = ni.name
	LEFT JOIN sys.indexes i
	ON
	i.object_id = im.object_id
	AND
	i.index_id = im.index_id
	LEFT JOIN
	sys.objects o
	ON
	o.object_id = i.object_id
ORDER BY
	o.name, i.name, rg.partition_number, rg.distribution_id
