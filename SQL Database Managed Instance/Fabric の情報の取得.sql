-- Fabric の情報の取得
SELECT 
	fr.node_name,
	fr.replica_address,
	-- fp.service_name , 
	fs.service_type_name,
	fp.partition_kind_desc, 
	fp.partition_health_state_desc,
	fr.service_kind_desc,
	fr.replica_status_desc,
	fr.replica_health_state_desc,
	fr.replica_role_desc,
	d.name,
	d.physical_database_name
FROM 
	sys.dm_hadr_fabric_partitions AS fp
	LEFT JOIN
	sys.dm_hadr_fabric_replicas  AS fr
	ON
	fp.partition_id = fr.partition_id
	LEFT JOIN
	sys.dm_hadr_fabric_services AS fs
	ON
	fp.service_name = fs.service_name
	LEFT JOIN
	sys.databases AS d
	ON
	SUBSTRING(fs.service_name, LEN(fs.service_name) - CHARINDEX('/', REVERSE(TRIM(fs.service_name))) + 2, LEN(fs.service_name)) = d.physical_database_name
	AND
	service_type_name = 'SQL.ManagedUserDb.RS'