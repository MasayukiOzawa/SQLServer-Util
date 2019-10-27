/*
DROP TABLE IF EXISTS LockInfo
GO
*/
SELECT
	*
FROM(
	SELECT
		l.name,
		l.timestamp AT TIME ZONE 'Tokyo Standard Time' AS timestamp_jst,
		DB_NAME(l.database_id) AS database_name,
		l.resource_type,
		l.mode,
		CASE 
			WHEN resource_type IN ('KEY', 'PAGE', 'RID', 'HOBT') THEN OBJECT_SCHEMA_NAME(p.object_id, l.database_id)
			WHEN resource_type = 'OBJECT' THEN OBJECT_SCHEMA_NAME(l.object_id, l.database_id)
			ELSE NULL
		END AS schema_name,
		CASE 
			WHEN resource_type IN ('KEY', 'PAGE', 'RID', 'HOBT') THEN OBJECT_NAME(p.object_id, l.database_id)
			WHEN resource_type = 'OBJECT' THEN OBJECt_NAME(l.object_id, l.database_id)
			WHEN resource_type = 'DATABASE' THEN DB_NAME(l.database_id)
			ELSE NULL
		END AS object_name,
		l.owner_type,
		l.session_id,
		l.sql_text,
		l.client_app_name
	FROM
		LockInfo AS l
		LEFT JOIN
		sys.partitions AS p
		ON hobt_id = associated_object_id
	WHERE
		l.name IN('lock_acquired', 'lock_released')
) AS T
ORDER BY
	timestamp_jst ASC

