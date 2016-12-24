SELECT 
	ao.name, 
	ao.type_desc, 
	ao.type,
	ao.create_date,
	ao.modify_date,
	asm.definition,
	asm.*,
	-- インデックス付きビューの SET の条件についての確認
	CASE 
		WHEN type = 'P' THEN 
			CASE
				WHEN  asm.uses_ansi_nulls = 1  AND asm.uses_quoted_identifier = 1 THEN 1
				ELSE 0
			END
		WHEN type = 'V' THEN 
			CASE
				WHEN  asm.uses_ansi_nulls = 1 AND asm.uses_quoted_identifier = 1 AND asm.is_schema_bound = 1 THEN 1
				ELSE 0
			END		
		ELSE NULL
	END AS indexd_view_requirements
FROM
	sys.all_objects ao
	LEFT JOIN
	sys.all_sql_modules asm
	ON
	ao.object_id = asm.object_id
WHERE 
	is_ms_shipped = 0
ORDER BY name ASC


