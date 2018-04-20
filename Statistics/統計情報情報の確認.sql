SELECT
	OBJECT_NAME(s.object_id) AS object_name,
	s.*,
	SUBSTRING(sc.column_name, 1, LEN(sc.column_name) -1) AS column_name,
	sp.*,
	CASE sp.rows
		WHEN 0 THEN 0
		ELSE
			CAST(CAST(sp.rows_sampled AS float) / sp.rows * 100 AS numeric(5,2)) 
	END AS sampling_percent,
	CASE sp.rows
		WHEN 0 THEN 0
		ELSE
			CAST(CAST(sp.modification_counter AS float) / sp.rows * 100 AS numeric(5,2)) 
	END AS modification_percent,
	isp.*
FROM
	sys.stats AS s
	CROSS APPLY
		sys.dm_db_stats_properties(s.object_id, s.stats_id) AS sp
	OUTER APPLY
		sys.dm_db_incremental_stats_properties(s.object_id, s.stats_id) AS isp
	LEFT JOIN
		sys.objects AS o
	ON
		o.object_id = s.object_id
	CROSS APPLY
	(
		(SELECT 
			CAST(c.name AS varchar(255)) + ','
			FROM 
			sys.stats_columns AS sc
			LEFT JOIN
				sys.columns AS c
			ON
				sc.object_id = c.object_id
				AND
				sc.column_id = c.column_id
			WHERE
			sc.object_id = s.object_id
			AND
			sc.stats_id = s.stats_id
			FOR XML PATH ('')
		)
	) AS sc(column_name)
WHERE
	o.is_ms_shipped = 0
