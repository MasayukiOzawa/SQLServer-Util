-- ディストリビューションの確認
SELECT
	* 
FROM 
	sys.dm_pdw_nodes n
	LEFT JOIN
	sys.pdw_distributions  d
	ON
	d.pdw_node_id = n.pdw_node_id
ORDER BY distribution_id
GO

-- オブジェクトのデータ格納状態の取得
SELECT
	ps.pdw_node_id,
	ps.distribution_id,
	SUM(ps.used_page_count) * 8.0 / 1024.0 AS used_page_MB,
	SUM(ps.row_count) AS row_count
FROM 
	sys.dm_pdw_nodes_db_partition_stats ps
	INNER JOIN
	sys.pdw_nodes_tables t
	ON
	ps.object_id = t.object_id
	AND
	ps.pdw_node_id = t.pdw_node_id
	AND
	ps.distribution_id = t.distribution_id
	LEFT JOIN
	sys.pdw_table_mappings m
	ON
	m.physical_name = t.name
	LEFT JOIN
	sys.objects o
	ON
	o.object_id = m.object_id
	LEFT JOIN
	sys.pdw_nodes_indexes ni
	ON
	ps.object_id = ni.object_id
	AND
	ps.index_id = ni.index_id
	AND
	ps.pdw_node_id = ni.pdw_node_id
	AND
	ps.distribution_id = ni.distribution_id
	LEFT JOIN
	sys.pdw_index_mappings im
	ON
	im.physical_name = ni.name
	LEFT JOIN sys.indexes i
	ON
	i.object_id = im.object_id
	AND
	i.index_id = im.index_id
GROUP BY
	ps.pdw_node_id,
	ps.distribution_id
ORDER BY
	ps.distribution_id
GO

-- オブジェクトのデータ格納状態の取得
SELECT
	ps.pdw_node_id,
	ps.distribution_id,
	o.name,
	i.type_desc,
	tdp.distribution_policy_desc,
	i.name,
	SUM(ps.used_page_count) * 8.0 / 1024.0 AS used_page_MB,
	SUM(ps.row_count) AS row_count
FROM 
	sys.dm_pdw_nodes_db_partition_stats ps
	INNER JOIN
		sys.pdw_nodes_tables t
	ON
		ps.object_id = t.object_id
		AND
		ps.pdw_node_id = t.pdw_node_id
		AND
		ps.distribution_id = t.distribution_id
	LEFT JOIN
		sys.pdw_table_mappings m
	ON
		m.physical_name = t.name
	LEFT JOIN
		sys.objects o
	ON
		o.object_id = m.object_id
	LEFT JOIN
		sys.pdw_nodes_indexes ni
	ON
		ps.object_id = ni.object_id
		AND
		ps.index_id = ni.index_id
		AND
		ps.pdw_node_id = ni.pdw_node_id
		AND
		ps.distribution_id = ni.distribution_id
	LEFT JOIN
		sys.pdw_index_mappings im
	ON
		im.physical_name = ni.name
	LEFT JOIN 
		sys.indexes i
	ON
		i.object_id = im.object_id
		AND
		i.index_id = im.index_id
	LEFT JOIN 
		sys.pdw_table_distribution_properties tdp
	ON
		tdp.object_id = o.object_id
GROUP BY
	ps.pdw_node_id,
	ps.distribution_id,
	o.name,
	i.name,
	i.type_desc,
	tdp.distribution_policy_desc
ORDER BY
	o.name,
	ps.distribution_id
GO

-- オブジェクトのデータ格納状態の取得
SELECT
	ps.pdw_node_id,
	SUM(ps.used_page_count) * 8.0 / 1024.0 AS used_page_MB,
	SUM(ps.row_count) AS row_count
FROM 
	sys.dm_pdw_nodes_db_partition_stats ps
	INNER JOIN
	sys.pdw_nodes_tables t
	ON
	ps.object_id = t.object_id
	AND
	ps.pdw_node_id = t.pdw_node_id
	AND
	ps.distribution_id = t.distribution_id
	LEFT JOIN
	sys.pdw_table_mappings m
	ON
	m.physical_name = t.name
	LEFT JOIN
	sys.objects o
	ON
	o.object_id = m.object_id
	LEFT JOIN
	sys.pdw_nodes_indexes ni
	ON
	ps.object_id = ni.object_id
	AND
	ps.index_id = ni.index_id
	AND
	ps.pdw_node_id = ni.pdw_node_id
	AND
	ps.distribution_id = ni.distribution_id
	LEFT JOIN
	sys.pdw_index_mappings im
	ON
	im.physical_name = ni.name
	LEFT JOIN sys.indexes i
	ON
	i.object_id = im.object_id
	AND
	i.index_id = im.index_id
GROUP BY
	ps.pdw_node_id
GO
