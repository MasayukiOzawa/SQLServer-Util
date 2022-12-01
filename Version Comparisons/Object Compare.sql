SELECT 
	OBJECT_SCHEMA_NAME(o.object_id) AS schema_name, 
	o.name COLLATE JAPANESE_CI_AS AS name, 
	o.type_desc COLLATE JAPANESE_CI_AS AS type_desc, 
	ac.column_id, 
	ac.name COLLATE JAPANESE_CI_AS AS column_name
FROM 
	sys.all_objects  AS o
	LEFT JOIN sys.all_columns AS ac 
	ON ac.object_id = o.object_id
WHERE 
	OBJECT_SCHEMA_NAME(o.object_id) = 'sys'
EXCEPT
SELECT 
	OBJECT_SCHEMA_NAME(o.object_id) AS schema_name, 
	o.name COLLATE JAPANESE_CI_AS AS name, 
	o.type_desc COLLATE JAPANESE_CI_AS AS type_desc, 
	ac.column_id, 
	ac.name COLLATE JAPANESE_CI_AS AS column_name
FROM 
	[REMOTESERVER].[master].sys.all_objects AS o
	LEFT JOIN [REMOTESERVER].[master].sys.all_columns AS ac 
	ON ac.object_id = o.object_id
WHERE 
	OBJECT_SCHEMA_NAME(o.object_id) = 'sys'
ORDER BY 
	type_desc, schema_name,name, column_id